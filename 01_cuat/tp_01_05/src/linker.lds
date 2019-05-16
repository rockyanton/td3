/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++  ETIQUETAS ++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*--------- STACK ------------*/
__INICIO_PILA = 0x1FFFB000;
__SIZE_PILA = 0x4000;
__FIN_PILA = __INICIO_PILA + __SIZE_PILA;   /* Tamaño de pila = 16k */

/*--------- EJERCICIO 5 ------------*/
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
/* Las secciones se definen en orden creciente de posiciones de memorias a donde se ubicarán */
/* El "." es el vector de VMA e indica la posición de memoria a donde se llamarán las siguientes secciones de código (VMA) */
SECTIONS
{
/*----------INIT-------------*/
  .init 0xFFFF0000 :      /* El vector "." de VMA le digo que arranque en 0xFFFF0000 */
    {*(.init)} AT >rom    /* Entre paréntesis la LMA donde está la sección a copiar/ubicar. El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */

/*-----------COPY-------------*/
  .copy_out 0x00000000 :                /* El vector "." de VMA le digo que arranque en 0x00000000 */
    { __COPY_RAM = .;                   /* Cargo el valor anterior en la etiqueta __COPY_RAM (VALOR EN VMA) */
    __COPY_ROM = LOADADDR(.copy_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
    bin/copy.elf(.copy);                /* Que copie el la sección .copy del archivo copy precompilado */
    } AT >rom                           /* Le pido que me cargue todo eso en ROM (LMA) */
    __COPY_LENGHT = SIZEOF(.copy_out);  /* Le pido el largo de la seccion de .copy_out */

/*-----------RESET--------------*/
  .reset 0xFFFFFFF0:            /* El vector "." de VMA le digo que arranque en 0xFFFFFFF0 */
    {*(.reset)} AT >rom_reset   /* Le pido que me cargue la sección .reset en ROM (LMA) */
}
