#https://unix.stackexchange.com/questions/529416/in-mpv-how-can-i-start-playback-at-a-random-moment-of-a-playlist
#!/bin/bash
function trap_handler()
{
    killall mpv
    pgrep -f bspwm_unfocus | xargs kill -9 
    bspc config top_padding 60
    bspc desktop -l next
    exit
}
trap trap_handler SIGINT
#marker for first run
first=0

bspc config top_padding 0
bspc desktop -l next

#reading files
array=()
while IFS=  read -r -d $'\0'; do
    array+=("$REPLY")
done < <(find /home/gris/files/torrents/french_stuff \( -name *.mp4 -o -name *.mkv \) -print0)


#initial sockets
SOCKETON="/tmp/mpvsocket0"
SOCKETOFF="/tmp/mpvsocket1"


while [[ true ]]
do


#decide from list
rand=$[ $RANDOM % ${#array[@]} ]

#start socket
mpv --pause --input-ipc-server=$SOCKETOFF "${array[rand]}" &
# wait until socket exists
while [ ! -S $SOCKETOFF ]; do :; done


sleep .5 # hack: wait a little longer


# get duration of current title in seconds with fractional part, save as integer
duration=$(echo '{ "command": ["get_property", "duration"] }' | socat - $SOCKETOFF | 
    jq -r '.data | floor')

# get random start position of title
duration=$(shuf -n1 -i0-"$duration")

# seek to position
socat - $SOCKETOFF <<< '{ "command": [ "seek", "+'"$duration"'" ] }'

#unpause
socat - $SOCKETOFF <<< '{ "command": [ "set_property", "pause", false ] }'  

#kill current socket
pgrep -f $SOCKETON | xargs kill -9 

#swap sockets
temp=$SOCKETON
SOCKETON=$SOCKETOFF
SOCKETOFF=$temp
if [[ $first -eq 0 ]]; then
    #unfocuses new windows so they load before socketon is killed
    sh bspwm_unfocus.sh & 
    first=1
fi

#time allowed to run before switch
sleep 1 &
wait $!
done

