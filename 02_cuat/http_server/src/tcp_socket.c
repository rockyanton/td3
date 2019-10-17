#include "../inc/tcp_socket.h"
#include "http_server.c"

int main(int argc, char *argv[]) {

  int socket_http, connection, nbr_fds;
  struct sockaddr_in address;
  char client_addr[20];
  int client_port;
  socklen_t addrlen;

  // Creamos el socket
  socket_http = socket(AF_INET, SOCK_STREAM,0);   // AF_INET: IPv4 // SOCK_STREAM: TCP // 0: PROTOCOLO NULO
  if (socket_http < 0) {
      perror("ERROR: El socket no se ha creado correctamente!\n");
      return(-1);
  }

  // Asigna el puerto indicado y una IP de la maquina
  address.sin_family = AF_INET;
  address.sin_port = htons(PORT);      // htons/htonl (Host TO Network Short/Long) es para pasar de little endian a big endian
  address.sin_addr.s_addr = htonl(INADDR_ANY);
  memset(address.sin_zero, '\0', sizeof address.sin_zero);  // Relleno el buffer sin_zero con null

  // Conecta el socket a la direccion local
  if (bind(socket_http, (struct sockaddr *)&address, sizeof(address))<0) {
    perror("ERROR al nombrar el socket\n");
    return(-1);
  }
  printf("\n\aServidor ACTIVO escuchando en el puerto: %d\n",PORT);

  // Indicar que el socket encole hasta MAX_CONN pedidos
  // de conexion simultaneas.
  if (listen(socket_http, MAX_CONN) < 0) {    // MAX_CONN ES DE LAS QUE ESTAN EN COLA A SER ATENDIDAS, NO CUENTA LAS QUE TENGO ACTIVAS
    perror("Error en listen");
    return(-1);
  }

  // Permite atender a multiples usuarios
  while (1) {
    printf("\n+++++++ Esperando conexión ++++++++\n\n");
    fd_set readfds;     // fd_set BLOQUEA PARA PODER LEER

    // Crear la lista de "file descriptors" que vamos a escuchar
    FD_ZERO(&readfds);

    // Especificamos el socket, podria haber mas.
    FD_SET(socket_http, &readfds);

    // Espera al establecimiento de alguna conexion.
    // El primer parametro es el maximo de los fds especificados en
    // las macros FD_SET + 1.
    nbr_fds = select(socket_http+1, &readfds, NULL, NULL, NULL);

    if ((nbr_fds<0) && (errno!=EINTR)) {
      perror("select");
    }
    if (!FD_ISSET(socket_http,&readfds)) {
      continue;
    }

    // La funcion accept rellena la estructura address con informacion del cliente y pone en addrlen la longitud de la estructura.
    if ((connection = accept (socket_http, (struct sockaddr *) &address, (socklen_t *)&addrlen)) < 0) {  // LE PASO COMO PARAMETRO EL SOCKET DE ESPERA Y ME DEVUELVE EL SOCKET DE LA CONEXION
      perror("Error en accept");                                                              // SI LE PASO EL ADRESS ME DEVUELVE LA DIRECCION IP DEL CLIENTE
      close(connection);
    }

    strcpy(client_addr, inet_ntoa(address.sin_addr));  // inet_ntoa ME PASA DE IP A ASCII PARA PODER MOSTRARLO
    client_port = ntohs(address.sin_port);  // ntohs (Network TO Host Short): Para volver a cambiar el endian
    printf("Conectado cliente %s:%d\n", client_addr, client_port);

    http_server(connection);
    // Cierra la conexion con el cliente actual
    close(connection);
    //return 0;
  }
  // Cierra el servidor
  close(socket_http);

  return 0;
}
