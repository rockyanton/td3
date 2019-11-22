//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ Includes ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#include "../inc/query_accelerometer.h"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++ Variables globales +++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
extern struct config_parameters_st *config_parameters;
extern sem_t *update_semaphore, *config_semaphore;

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++ Levantar datos del SPI ++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
void update_http_file(void) {
  float x_p, y_p, z_p, * values, secs_sleep = 0;
  short x_s, y_s, z_s;
  FILE *html_file;
  ssize_t readed;
  char measure[7], devid, connect_error_msg = FALSE;;
  int acelerometer, prom=0, not_equal=0, index=0, i, first_run=1;

  while (1) {


    sem_wait (config_semaphore);
    if (prom != config_parameters->prom){
      not_equal = 1;
      prom = config_parameters->prom;
    }

    if (secs_sleep != config_parameters->query_freq){
      secs_sleep = config_parameters->query_freq;
    }
    sem_post (config_semaphore);

    if (not_equal){
      if (!first_run){
        free(values);
      } else {
        first_run = 0;
      }
      values = calloc((size_t) 3*(prom+1), sizeof(float));
      not_equal=0;
      first_run = 0;
    }



    time_t time_seconds = time(NULL);
    struct tm local_time = *localtime(&time_seconds);

    //printf("[LOG] QUERY ACCELEROMETER: Getting position\n");

    acelerometer = open (DEVICE_NAME, O_RDWR);

    if (acelerometer < 0) {
      if (!connect_error_msg) // Para que muestre el error una sola vez
        perror("[ERROR] QUERY ACCELEROMETER: Can't open device");
      connect_error_msg = TRUE;
      close(acelerometer);
      return;
    } else {
      if (connect_error_msg) // Si hubo error muestro que se normalizó todo
        printf("[LOG] QUERY ACCELEROMETER: The connection was reestablished");
      connect_error_msg = FALSE; // Limpio el flag;
    }

    readed = read(acelerometer, measure, 7);
    close(acelerometer);

    if (readed < 7){
      perror("[ERROR] QUERY ACCELEROMETER: Nothing to read");
      return;
    }

    devid = measure[0];
    x_s = (short) ((measure[2] << 8) | measure[1]);
    y_s = (short) ((measure[4] << 8) | measure[3]);
    z_s = (short) ((measure[6] << 8) | measure[5]);

    index ++;
    if (index > prom){
      index = 1;
    }

    values[3*index + 0] = (float)(x_s) / (float)(255);
    values[3*index + 1] = (float)(y_s) / (float)(255);
    values[3*index + 2] = (float)(z_s) / (float)(255);

    x_p = 0;
    y_p = 0;
    z_p = 0;

    for (i=1; i<=prom; i++){
      x_p += values[3*i + 0];
      y_p += values[3*i + 1];
      z_p += values[3*i + 2];
    }

    x_p /= prom;
    y_p /= prom;
    z_p /= prom;

    values[0] = x_p;
    values[1] = y_p;
    values[2] = z_p;

    sem_wait (update_semaphore); // Trato de tomar el semaforo para hacer el update

    html_file = fopen(HTML_FILE,"w");

    if (html_file == NULL){
      perror("[ERROR] QUERY ACCELEROMETER: Can't open html file for editing");
    } else {

      // Agrego los headers
      fprintf(html_file, "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta http-equiv=\"refresh\" content=\"1\"><title>TD3 SPI</title></head>");

      //Agrego el título
      fprintf(html_file, "<body><h1>Driver de SPI TD3: Aceler&oacute;metro</h1><p><b>Rodrigo Ant&oacute;n - Leg:144.129-2</b></p>");

      // Agrego el mensaje
      //fprintf(html_file, "<p>Device ID= 0x%02x</p><p>X= %d</p><p>Y= %d</p><p>Z= %d</p>", devid, x_s, y_s, z_s);
      fprintf(html_file, "<p>Device ID= 0x%02x</p><p>X= %f g</p><p>Y= %f g</p><p>Z= %f g</p>", devid, x_p, y_p, z_p);
      //fprintf(html_file, "<p>Device ID= 0x%02x</p><p>X= %f g</p><p>Y= %f g</p><p>Z= %f g</p>", devid, values[3*index + 0], values[3*index + 1], values[3*index + 2]);
      // Agrego la fecha
      fprintf(html_file, "<br><br><p><i>Updated: %d-%d-%d %d:%d:%d</i></p></body></html>", local_time.tm_year + 1900, local_time.tm_mon + 1,local_time.tm_mday, local_time.tm_hour, local_time.tm_min, local_time.tm_sec);

      fclose (html_file);

    }

    sem_post (update_semaphore); // Libero el semaforo

    usleep((useconds_t) (secs_sleep*1000000));
  }

  return;
}
