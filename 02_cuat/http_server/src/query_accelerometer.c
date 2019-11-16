#include "../inc/query_accelerometer.h"

void update_http_file() {
  float x, y, z;
  FILE *html_file;
  //char *html_content;
  //html_content = malloc(HTML_SIZE); // Pido 1000 caracteres en memoria
  int retry=0;

  printf("[LOG] QUERY ACCELEROMETER: Getting position\n");

  ////// TRAER ACA LOS VALORES /////
  srand(time(0));
  x=((float)rand())/((float)rand());
  y=((float)rand())/((float)rand());
  z=((float)rand())/((float)rand());
  /////////////////////////////////

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
    fprintf(html_file, "<body><h1>Driver de SPI TD3: Aceler&oacute;metro</h1><p><b>Rodrigo Ant&oacute;n - Leg:144.129-2</b></p><p>X=%f</p><p>Y=%f</p><p>Z=%f</p></body></html>", x, y, z);

    fclose (html_file);
  }

  return;
}
