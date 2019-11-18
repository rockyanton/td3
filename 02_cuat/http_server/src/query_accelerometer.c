#include "../inc/query_accelerometer.h"

void update_http_file() {
  FILE *html_file;
  int acelerometer, retry=0;
  ssize_t readed;
  char measure[7];

  //printf("[LOG] QUERY ACCELEROMETER: Getting position\n");

  acelerometer = open (DEVICE_NAME, O_RDWR);

  if (acelerometer < 0) {
    perror("[ERROR] QUERY ACCELEROMETER: Can't open device");
    close(acelerometer);
    return;
  }

  readed = read(acelerometer, measure, 7);
  close(acelerometer);

  if (readed < 7){
    perror("[ERROR] QUERY ACCELEROMETER: Nothing to read");
    return;
  }

  while (retry<50){ // Pruebo abrirlo 50 veces segidas
    html_file = fopen(HTML_FILE,"w");
    retry++;
    if ((html_file != NULL)){
      retry = 100; // Salgo del loop
    }
  }

  if (html_file == NULL){
    perror("[ERROR] QUERY ACCELEROMETER: Can't open html file for editing");
  } else {

    // Agrego los headers
    fprintf(html_file, "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\" http-equiv=\"refresh\" content=\"2\"><title>TD3 SPI</title></head>");

    // Agrego el mensaje
    fprintf(html_file, "<body><h1>Driver de SPI TD3: Aceler&oacute;metro</h1><p><b>Rodrigo Ant&oacute;n - Leg:144.129-2</b></p><p>Device ID= 0x%x</p><p>X= 0x%x%x</p><p>Y= 0x%x%x</p><p>Z= 0x%x%x</p></body></html>", measure[6], measure[5], measure[4], measure[3], measure[2], measure[1], measure[0]);

    fclose (html_file);
  }

  return;
}
