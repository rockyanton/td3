
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ Includes ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#include "../inc/file_functions.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++ Obtener tamaño de archivo +++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
size_t getFileSize(char *fn){
  int retry=0, sz=0;
  FILE *fp;

  fp = fopen(fn,"r");

  if (fp == NULL){
    perror("[ERROR] HTTP SERVER: Can't read html file");
  } else {
    fseek(fp, 0L, SEEK_END);
    sz = ftell(fp);
    fclose (fp);
  }

  return sz;
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++ Obtener cantidad de lineas de archivo ++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int getFileLines (char *fn) {
  FILE *fp;
  int lines = 0;
  char ch;

  fp = fopen(fn,"r");

  if (fp == NULL){
    perror("[ERROR] HTTP SERVER: Can't read config file");
    return 0;
  } else {
    while(!feof(fp))
    {
      ch = fgetc(fp);
      if(ch == '\n')
      {
        lines++;
      }
    }
    return lines;
  }
}
