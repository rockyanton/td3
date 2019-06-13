/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++  ETIQUETAS ++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
__INICIO_PILA = 0x1FFFB000;                 /* Principio del stack */
__FIN_PILA = 0x1FFFFF0;                     /* La termino al final de la RAM */
__SIZE_PILA = __FIN_PILA - __INICIO_PILA;    /* Calculo el largo de la pila */


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
  /*------------INIT-------------*/
  .init_out 0xFFFF0000 :      /* El vector "." de VMA le digo que arranque en 0xFFFF0000 */
    { *(.init_start);
      *(.init)} AT >rom       /* Entre paréntesis la LMA donde está la sección a copiar/ubicar. El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */

  /*----------RUTINAS------------*/
  .rutinas_out 0x00000000 :                     /* El vector "." de VMA le digo que arranque en 0x00000000 */
    { __RUTINAS_RAM = .;                        /* Cargo el valor anterior en la etiqueta __RUTINAS_RAM (VALOR EN VMA) */
      __RUTINAS_ROM = LOADADDR(.rutinas_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/keyboard.elf(.keyboard);               /* Que copie la sección .teclado del archivo teclado.elf ensamblado */
      *(.isr);                         /* Que copie la sección .handlers del archivo handlers.elf ensamblado */
    } AT >rom                                   /* Le pido que me cargue todo eso en ROM (LMA) */
    __RUTINAS_LENGHT = SIZEOF(.rutinas_out);    /* Le pido el largo de la seccion de .rutinas_out */

  /*------TABLAS DE SISTEMA-------*/
  .tablas_de_sistema_out 0x00100000 :                             /* El vector "." de VMA le digo que arranque en 0x00100000 */
  { __TABLAS_DE_SISTEMA_RAM = .;                                  /* Cargo el valor anterior en la etiqueta __TABLAS_DE_SISTEMA_RAM (VALOR EN VMA) */
    *(.tablas_de_sistema)}                                        /* Que copie la sección .tablas_de_sistema de todos los archivos ensamblado */
  __TABLAS_DE_SISTEMA_LENGHT = SIZEOF(.tablas_de_sistema_out);    /* Le pido el largo de la seccion de .tablas_de_sistema_out */

  /*------------NUCLEO------------*/
  .nucleo_out 0x00300000 :                  /* El vector "." de VMA le digo que arranque en 0x00300000 */
    { __NUCLEO_RAM = .;                     /* Cargo el valor anterior en la etiqueta __COPY_RAM (VALOR EN VMA) */
      __NUCLEO_ROM = LOADADDR(.nucleo_out); /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/copy.elf(.copy);                  /* Que copie la sección .copy del archivo copy ensamblado */
    } AT >rom                               /* Le pido que me cargue todo eso en ROM (LMA) */
    __NUCLEO_LENGHT = SIZEOF(.nucleo_out);  /* Le pido el largo de la seccion de .copy_out */
    __COPY_ROM = __NUCLEO_ROM;              /* Dirección de Copy */

  /*------TABLA DE DIGITOS-------*/
  .tabla_de_digitos_out 0x00310000 :              /* El vector "." de VMA le digo que arranque en 0x00310000 */
    { __INICIO_TABLA_DE_DIGITOS = .;              /* Cargo el valor anterior en la etiqueta __INICIO_TABLA_DE_DIGITOS (VALOR EN VMA) */
      bin/teclado.elf(.tabla_de_digitos);     /* Que copie la sección .tabla_de_digitos del archivo teclado ensamblado */
    }
    __SIZE_TABLA_DE_DIGITOS = SIZEOF(.tabla_de_digitos_out);    /* Le pido el largo de la seccion de .tabla_de_digitos */
    __FIN_TABLA_DE_DIGITOS = __INICIO_TABLA_DE_DIGITOS + __SIZE_TABLA_DE_DIGITOS;   /* Resto para obtener el final de la tabla */

  /*-----------DATOS------------*/
  .datos_out 0x003E0000 :    /* El vector "." de VMA le digo que arranque en 0x00310000 */
  {*(.datos)}                /* Todos los archivos de datos que los cargue en ese lugar */

  /*-----------RESET--------------*/
  .reset_out 0xFFFFFFF0:            /* El vector "." de VMA le digo que arranque en 0xFFFFFFF0 */
    {*(.reset)} AT >rom_reset       /* Le pido que me cargue la sección .reset en ROM (LMA) */
}
