//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++ Defines +++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define CLIENT_MESSAGE_SIZE 65535

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//++++++++++++++++++++++++++++++++ Funciones ++++++++++++++++++++++++++++++++++
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Server de HTTP
int http_server (int connection);

// Obtener el Meta Type de HTML segun extensión de archivo
char * getFileMetaType(char *);

// Generación dinámica del índice
int getIndex(char *);

// Handlers de señales
void handler_server_SIGINT (int signbr);
