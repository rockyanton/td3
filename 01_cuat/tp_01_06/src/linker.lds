/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++  ETIQUETAS ++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*--------- STACK ------------*/
__INICIO_PILA = 0x1FFFE000;
__FIN_PILA = 0x1FFFFF0;    /* La termino al final de la RAM */
__SIZE_PILA = __FIN_PILA - __INICIO_PILA;

/*------ TABLA DE DÍGITOS ------*/
__INICIO_TABLA_DE_DIGITOS = 0x00310000;
__SIZE_TABLA_DE_DIGITOS = 64K;
__FIN_TABLA_DE_DIGITOS = __INICIO_TABLA_DE_DIGITOS + __SIZE_TABLA_DE_DIGITOS;

/*------ TABLA DE DÍGITOS ------*/
__DATOS_PROGRAMA = 0x003E0000;

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++  MEMORY +++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
MEMORY
{
  ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000
  rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFF0
  rom_reset (rx) : ORIGIN = 0xFFFFFFF0, LENGTH = 0x10
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++  SECTIONS +++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* Las secciones se definen en orden creciente de posiciones de memorias a donde se ubicarán */
/* El "." es el vector de VMA e indica la posición de memoria a donde se llamarán las siguientes secciones de código (VMA) */
SECTIONS
{
  /*----------INIT-------------*/
  .init 0xFFFF0000 :      /* El vector "." de VMA le digo que arranque en 0xFFFF0000 */
    {*(.init)} AT >rom    /* Entre paréntesis la LMA donde está la sección a copiar/ubicar. El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */

  /*----------RUTINAS------------*/
  .rutinas_out 0x00000000 :                   /* El vector "." de VMA le digo que arranque en 0x00000000 */
    { __RUTINAS_RAM = .;                      /* Cargo el valor anterior en la etiqueta __RUTINAS_RAM (VALOR EN VMA) */
    __RUTINAS_ROM = LOADADDR(.rutinas_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
    bin/teclado.elf(.teclado);                /* Que copie la sección .teclado del archivo teclaso.elf compilado */
    } AT >rom                                 /* Le pido que me cargue todo eso en ROM (LMA) */
    __RUTINAS_LENGHT = SIZEOF(.rutinas_out);  /* Le pido el largo de la seccion de .rutinas_out */

  /*------------NUCLEO------------*/
  .nucleo 0x00300000 :                  /* El vector "." de VMA le digo que arranque en 0x00300000 */
    {__NUCLEO_RAM = .;                  /* Cargo el valor anterior en la etiqueta __COPY_RAM (VALOR EN VMA) */
    __NUCLEO_ROM = LOADADDR(.nucleo);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
    bin/copy.elf(.copy);                /* Que copie la sección .copy del archivo copy precompilado */
    } AT >rom                           /* Le pido que me cargue todo eso en ROM (LMA) */
    __NUCLEO_LENGHT = SIZEOF(.nucleo);  /* Le pido el largo de la seccion de .copy_out */
    __COPY_ROM = __NUCLEO_ROM;          /* Dirección de Copy */

  /*-----------RESET--------------*/
  .reset 0xFFFFFFF0:            /* El vector "." de VMA le digo que arranque en 0xFFFFFFF0 */
    {*(.reset)} AT >rom_reset   /* Le pido que me cargue la sección .reset en ROM (LMA) */
}
