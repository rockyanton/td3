/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++  ETIQUETAS ++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*--------- STACK ------------*/
__INICIO_PILA = 0x1FFFB000;
__SIZE_PILA = 0x4000;
__FIN_PILA = __INICIO_PILA + __SIZE_PILA;   /* Tamaño de pila = 16k */

/*--------- ETIQUETAS ------------*/
__COPY_RAM_2 = 0x00300000;
__COPY_RAM_3 = 0x00400000;


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
/* El ". = DIR" es memoria virtual (VMA) ---- El "AT(DIR)" es LMA*/
/* Las secciones se definen en orden creciente de posiciones de memorias a donde se ubicarán */
/* El "." indica la posición de memoria donde ubicar las siguientes secciones de código (VMA) */
SECTIONS
{
/*----------INIT-------------*/
  .init 0xFFFF0000 :      /* nombre de la sección a copiar */
    {*(.init)} AT >rom    /* Entre paréntesis la LMA donde está la sección a copiar/ubicar. El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */

/*-----------COPY-------------*/
  .copy_out 0x00000000 :     /* El vector de VMA le digo que arranque en 0x00000000 */
    { __COPY_RAM = .;       /* Cargo el valor anterior en la etiqueta __INICIO RAM RUTINAS (VALOR EN VMA) */
    __COPY_ROM = LOADADDR(.copy_out);  /*  Como no se en que parte de la rom me lo carga, tengo que usar la funcion LOADADDR para que me diga donde cargo esa seccion */
    bin/copy.elf(.copy);} AT >rom   /* Le pido que me cargue la seccion rutinas en ROM (LMA) */
    __COPY_LENGHT = SIZEOF(.copy_out);  /* Le pido el largo de la seccion de .rutinas_out */

/*-----------RESET--------------*/
  .reset 0xFFFFFFF0:      /* Cambio la ubicación del puntero "." */
    {*(.reset)} AT >rom_reset
}
