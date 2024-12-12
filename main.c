#include <stdio.h>
#include <dirent.h>
#include <stdlib.h>
#include <string.h>
#include <linux/input.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <time.h>
#include <sys/wait.h>
int scandir_list(char*** list, char * dir_name){
    DIR *d;
    struct dirent *dir = NULL;
    d = opendir(dir_name);

    int num_files = 0;
    if (d) {
        while ((dir = readdir(d)) != NULL) {
            if (dir->d_type == DT_REG) { /* If the entry is a regular file */
                *list = realloc(*list, sizeof(char) * (num_files + 1));
                (*list)[num_files++] = strdup(dir->d_name);
            }
        }
        closedir(d);
      }
    return num_files;
}

int mouse(){
    int fd;
    if ((fd = open("/dev/input/mice", O_RDONLY)) < 0) {
        perror("evdev open");
        exit(1);
    }

    struct input_event ev;
    printf("right before mouse\n");
    read(fd, &ev, sizeof(struct input_event));
        
        //some action
    return 0;
}

int main(){
    char * dir_name = "videos/";
    pid_t m_pid = fork();
    if (m_pid == 0){
        char * args[5] = {"bash", "mpvplay.sh", dir_name, NULL};
        execvp("sh", args);
    }
    else{
        //while(1);
        mouse();
        printf("after mouse\n");
        kill(m_pid, SIGINT);
    }
}


