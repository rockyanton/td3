#include<time.h>
#define HTML_FILE "./sup/spi.html"
#define DEVICE_NAME "/dev/td3-spi"

void update_http_file(sem_t *update_semaphore);
