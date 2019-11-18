#include "../inc/query_accelerometer.h"

static uint8_t connect_error_msg = FALSE;

void update_http_file(sem_t *update_semaphore) {
  FILE *html_file;
  int acelerometer, retry=0;
  ssize_t readed;
  char measure[7];

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
    fprintf(html_file, "<p>Device ID= 0x%x</p><p>X= 0x%x%x</p><p>Y= 0x%x%x</p><p>Z= 0x%x%x</p></body></html>", measure[6], measure[1], measure[0], measure[3], measure[2], measure[5], measure[4]);

    // Agrego la fecha
    fprintf(html_file, "<br><br><p><i>Updated: %d-%d-%d %d:%d:%d</i></p></body></html>", local_time.tm_year + 1900, local_time.tm_mon + 1,local_time.tm_mday, local_time.tm_hour, local_time.tm_min, local_time.tm_sec);

    fclose (html_file);

  }

  sem_post (update_semaphore); // Libero el semaforo

  return;
}
