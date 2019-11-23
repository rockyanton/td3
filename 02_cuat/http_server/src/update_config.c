//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ Includes ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#include "../inc/update_config.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++ Variables globales +++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
extern struct config_parameters_st *config_parameters;
extern sem_t *signal_update, *config_semaphore;
FILE *config_file;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++ Actualizar configuracion ++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

void update_configuration () {
  int backlog = 2;
  int max_conn = 1000;
  float query_freq = 1.0;
  int prom = 5;
  char config_str[50], *value;
  char *options_ptr[50];
  size_t file_size;
  int cant_lineas, i;

  // Asigno la señal SIGINT al handler del update
  signal(SIGINT, handler_config_SIGINT);

  while (1){

    // Trato de tomar el semáforo que me va a liberar la interrupción
    sem_wait(signal_update);


    file_size = getFileSize (CFG_FILE);
    if (file_size < 50) { // Por si hay algún error

      cant_lineas = getFileLines(CFG_FILE);

      config_file = fopen(CFG_FILE,"r");
      if (config_file == NULL){
        perror("[ERROR] CONFIG UPDATE: Can't read config file");
        return;
      }

      printf("[LOG] CONFIG UPDATE: Updating configuration\n");

      fread(config_str, sizeof(char), file_size, config_file);

      fclose (config_file);
      config_file = NULL; // Para chequear si fue cerrado o no

      options_ptr[0] = strtok(config_str,"\r\n");
      for (i=1; i < cant_lineas; i++){
        options_ptr[i] = strtok(NULL,"\r\n");
      }

      for (i=0; i< cant_lineas; i++){
        if (value = strchr(options_ptr[i], '=')) {  // busco si hay algo despues de '='
          *value++ = '\0';   // si hay, separo la opcion y el valor

          switch (options_ptr[i][0]) {
            case 'b':
              backlog = atoi(value);
              break;
            case 'c':
              max_conn = atoi(value);
              break;
            case 'f':
              query_freq = atof(value);
              break;
            case 'p':
              prom = atoi(value);
              break;
          }
        }
      }

      //printf("b=%d -- c=%d -- f=%f -- p=%d\n", backlog,max_conn,query_freq, prom);

      sem_wait (config_semaphore);  // Tomo el semaforo de configuracion
      config_parameters->backlog = backlog;
      config_parameters->max_conn = max_conn;
      config_parameters->query_freq = query_freq;
      config_parameters->prom = prom;
      sem_post (config_semaphore);
    } else {
      printf("[ERROR] CONFIG UPDATE: Can't read config file: File too big\n");
    }
  }
}

void handler_config_SIGINT (int signbr){
  if (config_file != NULL){
    fclose(config_file);
  }
  printf("[LOG] CONFIG UPDATE: Exiting\n");
  exit(0);
}
