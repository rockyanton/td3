#include "../inc/tcp_socket.h"
#include "http_server.c"
#include "device.c"

int main(int argc, char *argv[]) {

  int socket_http, connection, nbr_fds, http_child, get_val_child;
  struct sockaddr_in address;
  char client_addr[20];
  int client_port;
  socklen_t addrlen;
  fd_set readfds;
  struct timeval timeout;

  // Creamos el socket
  socket_http = socket(AF_INET, SOCK_STREAM,0);   // AF_INET: IPv4 // SOCK_STREAM: TCP // 0: PROTOCOLO NULO
  if (socket_http < 0) {
    perror("[ERROR] TCP SOCKET: Can't create socket");
    return(-1);
  }

  // Asigna el puerto indicado y una IP de la maquina
  address.sin_family = AF_INET;
  address.sin_port = htons(PORT);      // htons/htonl (Host TO Network Short/Long) es para pasar de little endian a big endian
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  memset(address.sin_zero, '\0', sizeof address.sin_zero);  // Relleno el buffer sin_zero con null

  // Conecta el socket a la direccion local
  if (bind(socket_http, (struct sockaddr *)&address, sizeof(address))<0) {
    perror("[ERROR] TCP SOCKET: Can't bind socket");
    return(-1);
  }

  // Indicar que el socket encole hasta MAX_CONN pedidos
  // de conexion simultaneas.
  if (listen(socket_http, MAX_CONN) < 0) {    // MAX_CONN ES DE LAS QUE ESTAN EN COLA A SER ATENDIDAS, NO CUENTA LAS QUE TENGO ACTIVAS
    perror("[ERROR] TCP SOCKET: Catn't listen");
    return(-1);
  }

  get_val_child = fork();

  if (!get_val_child){  // El proceso hijo va a actualizar los valores cada tanto
    printf("Buscando valores\n");
    return 0;
  }

  printf("[LOG] TCP SOCKET: Server is online listening on port: %d\n", PORT);

  // Permite atender a multiples usuarios
  while (1) {

    printf("[LOG] TCP SOCKET: Waiting for new connection\n");
    /*
    // Vacío el puntero, indicando que no nos interesa ningún descriptor de fichero.
    FD_ZERO(&readfds);

    // Especificamos el socket.
    FD_SET(socket_http, &readfds);

    // Espera al establecimiento de alguna conexion.

    nbr_fds = select(socket_http+1, &readfds, NULL, NULL, NULL);

    if (nbr_fds<0) {
      perror("[ERROR] TCP SOCKET: Error in select");
    }
    if (!FD_ISSET(socket_http,&readfds)) {
      printf("[ERROR] TCP SOCKET: Se hizo un pedido\n");
    }

    // Child
    // Elimino el descriptor dentro del fd_set.
    //FD_CLEAR (int, fd_set *) elimina el descriptor dentro del fd_set.
    */

    // La funcion accept rellena la estructura address con informacion del cliente y pone en addrlen la longitud de la estructura.
    if ((connection = accept (socket_http, (struct sockaddr *) &address, (socklen_t *)&addrlen)) < 0) {  // LE PASO COMO PARAMETRO EL SOCKET DE ESPERA Y ME DEVUELVE EL SOCKET DE LA CONEXION
      perror("[ERROR] TCP SOCKET: Error accepting new connection");                                      // SI LE PASO EL ADRESS ME DEVUELVE LA DIRECCION IP DEL CLIENTE
      close(connection);
    }

    http_child = fork();

    if (http_child == -1) {
      perror("[ERROR] TCP SOCKET: Error forking");
    } else if (http_child == 0){ // Pregunto si es el hijo

  		close(socket_http);   // Cierro el socket desde el hijo

      strcpy(client_addr, inet_ntoa(address.sin_addr));  // inet_ntoa ME PASA DE IP A ASCII PARA PODER MOSTRARLO
      client_port = ntohs(address.sin_port);  // ntohs (Network TO Host Short): Para volver a cambiar el endian
      printf("[LOG] TCP SOCKET: Conectado cliente %s:%d\n", client_addr, client_port);

      http_server(connection);
      // Cierra la conexion con el cliente actual
      close(connection);

      // Termino el proceso hijo
      return 0;
    }

  }
  // Cierra el servidor
  close(socket_http);

  return 0;
}
