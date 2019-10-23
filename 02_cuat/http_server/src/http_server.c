#include "../inc/http_server.h"

int http_server (int connection){

  char *client_message, *server_message, *error_message, *filename, *content_type;
  char *method, *uri, *qs, *prot;
  size_t message_length;
  int requested_file;
  int rcvd;

  client_message = malloc (CLIENT_MESSAGE_SIZE);          // Reservo el espacio en memoria para el mensaje del cliente
  server_message = client_message;                        // Reuso el string
  error_message = client_message + CLIENT_MESSAGE_SIZE/2; // idem  pero, me voy bien arriba.

  while (1) {
    // Recibe el mensaje del cliente

    rcvd = recv(connection, client_message, CLIENT_MESSAGE_SIZE, 0);
    if (rcvd < 0) {
      perror("Error en recv");
    } else if (rcvd==0){    // receive socket closed
      perror("Client disconnected upexpectedly.\n");
      return -1;
    } else {

      method = strtok(client_message,  " \t\r\n");  // medodo solicitado ("GET" o "POST")
      uri    = strtok(NULL, " \t");                 // nombre del archivo solicitado, todo lo que está antes de '?' (ej: "/index.html")
      prot   = strtok(NULL, " \t\r\n");             // protocolo HHTP (ej: "HTTP/1.1")

      if (qs = strchr(uri, '?'))                    // busco si hay algo despues de '?' (ej: "a=1&b=2")
        *qs++ = '\0';   // si hay, separo el uti y qs

      if (!strcmp(method,"GET")) {      // Chequeo si me mandó un GET

        filename = malloc (strlen(uri) + 15);   // reservo la memoria correspondiente y le agrego la ruta al archivo
        sprintf(filename, "./sup%s",uri);

        if (uri[strlen(uri)-1] == '/')      //Si me pide la raiz, busco el index.html
          getIndex(filename);

            printf("FILENAME:%s\n",filename);
        requested_file = open (filename, O_RDONLY);  // Abro el archivo solicitado como lectura


        if (requested_file != -1) {    // Me fijo si el archivo existe y puedo acceder

          message_length = getFileSize (filename);

          content_type = getMeFileMetaType(filename);

          sprintf(server_message, "HTTP/1.1 200 OK\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n", content_type, (int) message_length);

          if (send(connection, server_message, strlen(server_message), 0) == -1) // Envío el header
            perror("Error enviando el header");
          if (sendfile(connection,requested_file,NULL,message_length) == -1)   // Envío el archivo
            perror("Error al enviar archivo");
          close (requested_file);

          printf ("Sent file:%s --- Content-Type: %s --- Content-Length: %d\n", filename, content_type, (int)message_length);

        } else{   // Si el archivo no existe -> 404 (Not Found)
          sprintf(error_message,"<!DOCTYPE html>\r\n<head><title>Error 404</title></head><body><h1>Error 404: Not Found</h1><br>No se encontr&oacute; el archivo &lt;<i>%s</i>&gt;</body></html>",uri);
          sprintf(server_message, "HTTP/1.1 404 Not Found\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s",(int)strlen(error_message),error_message);

          if (send(connection, server_message, strlen(server_message), 0) == -1) // Envío el header
            perror("Error enviando error 404 (Not Found)");
        }

        free (filename);
      } else {    // Si no es GET -> 405 (Method Not Allowed)
        sprintf(error_message,"<!DOCTYPE html>\r\n<head><title>Error 405</title></head><body><h1>Error 405: Method Not Allowed</h1><br>M&eacute;todo &lt;<i>%s</i>&gt; no soportado</body></html>",uri);
        sprintf(server_message, "HTTP/1.1 404 Not Found\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s",(int)strlen(error_message),error_message);

        if (send(connection, server_message, strlen(server_message), 0) == -1) // Envío el header
          perror("Error enviando error 405 (Method Not Allowed)");
      }
    }
  }
  free (client_message);
  return 0;
}

// <link rel="shortcut icon" href="data:image/gif;base64,R0lGODlhIAAgAOf/ADEzMDo0LjY2O9oNHS09P101P1c4NTBCR2A3KHQwO8QaK4otL88aJWw3LL4gJL4gKcAhH5osMT1HO8khKdIeLURGQ9wcJssiJCpOYNUhKVxEQ94gLklLSFNJTENOTnFIGk5ORsAvLWFLPmVLNcwwMzpYZrY3QURWYIBJPT1bUideeoJITU5VZ1pWVVtVXyJjhFxbU0xhSWVaStQ7PVtcZT1oTRlskkNjfAB1psJHOzJxR5tVTWplZLdSQGNndAB+tRqEPXBpUXJnaACBvllxXR6FRppgU1B5V1V5TMdYRGtwZwCGzMxXSySLQ8pYXF51hdZXUrNjWHd2XFmCYGOAZTmGpziQSS+TSn14ceFdWT6PT85kU4J7URePxzaSURqOzESOWrdtXjeWRzqZSb1vbaF/KJZ7elOSZclxXDSfTlGMtk6WXCyVzaKBONxsYchxbTiTxXiJdyaY1mmQZ0GfT0WUwkagSkCiWNl2ZD6nVV2eZEumUWecbWWeZcWAdDqg0kmqTF6iYVuZz0Ohx0esU3WaflWoWU6h3O9+d1CxUnCkdlOwWJudU0y1TpCbis+JhtuHeu2CeFil2pybd32kel6k4NeKgIGjiPODgFi1Y1q5WauhY2ur3G61c2K8Y2a7bbKgn5WskZKujG6y2/KUg7WnfG/AaMykmdyhirCrqXjDcs2vPpa2nc2yJdikkZ63kIjBg4bDe4G65cy1Spm+jtS4Nqa8nuWrnZC+5dS2b43Jhda6RZjEntS7Vcy8Z9u/NN6/NdG8gMLDh+HEMLLFsd/EQcXEldvFZ5vM5uLIUKHUmejKN7POstTIkq3RrOrML9rOeqfZpfDQKKjZq/TDuuvGvO7UK57Z8dzQlvHWIObPi+zUXMfXveHSpu3XU9jXlPbbJvTbR7fiuOLYpOrZg/vfHt/dk+ban/bhLeTZuPzgLvnjIMrixvXmIvziQPnlPObgsfTlV/nmR/XoR/rnUePkufvnYvnoafnocfbqfPHouvPsw//vqP/yt//2mJCRlCH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAP8ALAAAAAAgACAAAAj+AP8JHEiwoMGDCBMqXMiwoUOC1W6hQnWr2kOE1Pyg2cIkSZItW9A8snhR4KkeeB48cLByZYgQOd6ULCQCCgkGOC9cYEBhggIFEEw8hDUF1IwMGSZAiRTJTQgKGSxcmPCgIaxolFLNGJAFkpEVKHZYQnTBAgWpThby8jQtWpxHWfwUoPHEhwsDYUhZiLphgCuFnRZ9ikULFJkOL+ocEqRmCIsomDZItsAkITNDhDSp0uXIjIo/h0bJ4iSnSwcECRZEeDCjG0JFezKb0sUMho0uknBdkyVp0A1jpbjI0NCgDUI9dPYk8qSLV4XbuZHJkgPnxCZ86ML5GvEBYaAxdBL+aXYmQcUSOZxGVZJT5cAme+vKZStWxvsVOoCWs4vhwcaSL2x88UMJAYwzzzrgSPNMLcd5MYYdhDSizCUVpPACDj/ggIEAQfTTTjnoPDNMLfAcBMYVVqRBSCKLiBOHBAIQcAABAIAAzz3xWbNgKwiBocUVYtgR2yfiXKJECxVwIMU++cSX4DK1rPLaGk1YIQYdeRCSyStYYFGPPvzg42Q20oyYC0LcrFFEE1dckcYdc/AwiT/53CMPOuWUA441I86STkJ8rAEEm2JQIYQw+NhDz51OKvjLLr4oZMsZWgBRBBFYmHNPPPS8o8468WVjzaO9NLMQK31YUUQF38Qjjzxa74CKIJnAFFNqQ6HooYUOk8zjDjrqlDOriMn0EsxDtvDBRw2MxLqOOjouk0wyx2BTEjGiUHIEI/G4E44322xzDDQlliQQN6xcgoQw5JCjzTnmxivvvPTWW1JAADs=" />

char * getMeFileMetaType(char * filename){
  char * file_extension = strrchr(filename, '.');    // Me quedo con la extensión
  char extension[6] = "\0";
  if (file_extension != NULL){    // Me fijo si tiene extension
    if (strlen(file_extension) < 6)   // Si tiene mas de 6 caracteres noe s una extension válida
      for(int i = 0; file_extension[i]; i++){ extension[i] = tolower(file_extension[i+1]); }  // Cambio la extensión a minúscula para comparar
  }

  // Se tomaron algunos a modo de referencia, el resto se pueden ver acá: http://www.iana.org/assignments/media-types/media-types.xhtml

  // TEXT
  if(!strcmp(extension,"html"))
    return "text/html; charset=UTF-8";
  if(!strcmp(extension,"htm"))
    return "text/html; charset=UTF-8";
  if(!strcmp(extension,"xml"))
    return "text/xml; charset=UTF-8";
  if(!strcmp(extension,"php"))
    return "text/html; charset=UTF-8";
  if(!strcmp(extension,"css"))
    return "text/css; charset=UTF-8";
  if(!strcmp(extension,"csv"))
    return "text/csv; charset=UTF-8";
  // IMAGE
  if(!strcmp(extension,"ico"))
    return "image/x-icon";
  if(!strcmp(extension,"jpeg"))
    return "image/jpeg";
  if(!strcmp(extension,"jpg"))
    return "image/jpeg";
  if(!strcmp(extension,"gif"))
    return "image/gif";
  if(!strcmp(extension,"png"))
    return "image/png";
  // VIDEO
  if(!strcmp(extension,"avi"))
    return "video/x-msvideo";
  if(!strcmp(extension,"mpeg"))
    return "video/mpeg";
  if(!strcmp(extension,"webm"))
    return "video/webm";
  if(!strcmp(extension,"mp4"))
    return "video/mp4";
  // AUDIO
  if(!strcmp(extension,"wav"))
    return "audio/x-wav";
  if(!strcmp(extension,"midi"))
    return "audio/midi";
  if(!strcmp(extension,"aac"))
    return "audio/aac";
  if(!strcmp(extension,"mp3"))
    return "audio/mpeg";
  // APLICACIONES
  if(!strcmp(extension,"bin"))
    return "application/octet-stream";
  if(!strcmp(extension,"jar"))
    return "application/java-archive";
  if(!strcmp(extension,"js"))
    return "application/javascript";
  if(!strcmp(extension,"json"))
    return "application/json";
  if(!strcmp(extension,"pdf"))
    return "application/pdf";
  if(!strcmp(extension,"tar"))
    return "application/x-tar";
  if(!strcmp(extension,"zip"))
    return "application/zip";
  // DEFAULT
  return "application/octet-stream";
}

size_t getFileSize(char *fn){
  size_t sz = 0;
  FILE *fp = fopen(fn, "r");
  if (fp != NULL){
  fseek(fp, 0L, SEEK_END);
  sz = ftell(fp);
  fclose (fp);
  }
  return sz;
}

int getIndex(char *index_dir){
  char *index_cmd;

  index_cmd = malloc(strlen(index_dir) + 50);
  sprintf(index_cmd, "tree -H '.' -L 1 --noreport --charset utf-8 %s > %sindex.html", index_dir, index_dir);

  sprintf(index_dir, "%sindex.html",index_dir);

  int status = system(index_cmd);

  free (index_cmd);

  return status;
}
