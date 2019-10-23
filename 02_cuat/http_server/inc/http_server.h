#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/sendfile.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>



#define CLIENT_MESSAGE_SIZE 65535

int http_server (int);
char * getMeFileMetaType(char *);
size_t getFileSize(char *);
int getIndex(char *);
