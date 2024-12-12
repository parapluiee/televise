
while [[ true ]]; do
    sleep 10
    if [[ $(xprintidle) -gt 3000 ]]; then
        sh mpvplay.sh &
        echo -e "\e[?1000h"
        while read -n 12; do echo working; done
    fi
done



