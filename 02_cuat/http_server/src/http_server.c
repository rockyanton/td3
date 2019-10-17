#include "../inc/http_server.h"

int http_server (int connection){

  char client_message[2000],header_response[256];
  char *server_message, *filename, *head_aux;
  int message_length, header_length;
  char    *method,    // "GET" or "POST"
          *uri,       // "/index.html" things before '?'
          *qs,        // "a=1&b=2"     things after  '?'
          *prot;      // "HTTP/1.1"
  int rcvd;

  while (1) {
    // Recibe el mensaje del cliente
    rcvd = recv(connection, client_message, sizeof(client_message), 0);
    if (rcvd < 0) {
      perror("Error en recv");
    } else if (rcvd==0){    // receive socket closed
      perror("Client disconnected upexpectedly.\n");
      return -1;
    } else {
      //printf("Recibido del cliente %s\n", client_message);

      method = strtok(client_message,  " \t\r\n");
      uri    = strtok(NULL, " \t");
      prot   = strtok(NULL, " \t\r\n");
      filename = malloc (strlen(uri) + 5);
      strcpy(filename, "./sup");
      strcpy(filename + 5, uri);

      printf ("Requested:%s\n", filename);

      if (strcmp(method,"[GET]")) {      // Chequeo si me mandó un GET


        FILE *html_file = fopen (filename, "r");
        if (html_file) {    // Me fijo si el archivo existe y puedo acceder

          fseek (html_file, 0, SEEK_END);
          message_length = ftell (html_file);
          fseek (html_file, 0, SEEK_SET);

          sprintf(header_response, "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\n\r\n\r\n", message_length);

          header_length = strlen(header_response);
          server_message = malloc (message_length + header_length);
          strcpy(server_message, header_response);
          if (server_message) {
            fread (server_message + header_length, 1, message_length, html_file);
          }
          fclose (html_file);

          if (send(connection, server_message, strlen(server_message), 0) == -1) { // Envío el header
            perror("Error en send");
          }
        } else{
          strcpy(header_response, "HTTP/1.1 404 Not Found\r\n\0");
          if (send(connection, header_response, strlen(header_response), 0) == -1) { // Envío el header
            perror("Error en send");
          }
        }
      } else {
        return 0;
      }
    }
  }
  return 0;
}
