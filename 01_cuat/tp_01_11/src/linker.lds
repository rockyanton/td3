/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++  MEMORIA +++++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
MEMORY
{
  ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000
  rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFF0
  rom_reset (rx) : ORIGIN = 0xFFFFFFF0, LENGTH = 0x10
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++  SECCIONES +++++++++++++++++++++++++++++++++++*/
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* Las secciones se definen en orden creciente de posiciones de memorias a donde se ubicarán */
/* El "." es el vector de VMA e indica la posición de memoria a donde se llamarán las siguientes secciones de código (VMA) */
SECTIONS
{
  /*------------INIT-------------*/
  .init_out 0xFFFF0000 :      /* El vector "." de VMA le digo que arranque en 0xFFFF0000 */
    { __INIT_ROM_LIN = .;
      *(.init_start);
      *(.init)} AT >rom       /* Entre paréntesis la LMA donde está la sección a copiar/ubicar. El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */
    __SIZE_INIT = SIZEOF(.init_out);
    __INIT_ROM_FIS = __INIT_ROM_LIN;

  /*-----------RESET--------------*/
  .reset_out 0xFFFFFFF0:            /* El vector "." de VMA le digo que arranque en 0xFFFFFFF0 */
    {*(.reset)} AT >rom_reset       /* Le pido que me cargue la sección .reset en ROM (LMA) */
    __SIZE_RESET = SIZEOF(.reset_out);

  /*----------RUTINAS------------*/
  .handlers_out 0x00000000 :                     /* El vector "." de VMA le digo que arranque en 0x00000000 */
    { __HANDLERS_LIN = .;                        /* Cargo el valor anterior en la etiqueta __RUTINAS_RAM (VALOR EN VMA) */
      __HANDLERS_ROM = LOADADDR(.handlers_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      *(.exc);                                  /* Que copie la sección .exc de los archivos */
      *(.isr);                                  /* Que copie la sección .isr de los archivos */
    } AT >rom                                   /* Le pido que me cargue todo eso en ROM (LMA) */
    __HANDLERS_LENGHT = SIZEOF(.handlers_out);    /* Le pido el largo de la seccion de .rutinas_out */
    __HANDLERS_FIS = __HANDLERS_LIN;

  /*-----------BUFFER DE VIDEO------------*/
  __BUFFER_DE_VIDEO_LIN = 0x00010000;                                      /* Principio del Buffer */
  __SIZE_BUFFER_DE_VIDEO = 0x00000FA0;                                        /* Tamañno del buffer (25 líneas * 80 caracteres * 2 bytes) */
  __BUFFER_DE_VIDEO_FIS = 0x000B8000;

  /*------TABLAS DE SISTEMA-------*/
  .tablas_de_sistema_out 0x00100000 :                             /* El vector "." de VMA le digo que arranque en 0x00100000 */
  { __TABLAS_DE_SISTEMA_LIN = .;                                  /* Cargo el valor anterior en la etiqueta __TABLAS_DE_SISTEMA_RAM (VALOR EN VMA) */
    bin/tables.elf(.tablas_de_sistema)}                           /* Que copie la sección .tablas_de_sistema de todos los archivos ensamblado */
  __TABLAS_DE_SISTEMA_LENGHT = SIZEOF(.tablas_de_sistema_out);    /* Le pido el largo de la seccion de .tablas_de_sistema_out */
  __TABLAS_DE_SISTEMA_FIS = __TABLAS_DE_SISTEMA_LIN;

  /*------TABLAS DE PAGINACION-------*/
  .tablas_de_paginacion_out 0x00110000 :                             /* El vector "." de VMA le digo que arranque en 0x00110000 */
  { __TABLAS_DE_PAGINACION_LIN = .;                                  /* Cargo el valor anterior en la etiqueta __TABLAS_DE_PAGINACION_RAM (VALOR EN VMA) */
    bin/paging.elf(.tablas_de_paginacion)                            /* Que copie la sección .tablas_de_paginacion de todos los archivos ensamblado */
  }
  __TABLAS_DE_PAGINACION_LENGHT = SIZEOF(.tablas_de_paginacion_out); /* Le pido el largo de la seccion de .tablas_de_paginacion_out */
  __TABLAS_DE_PAGINACION_FIS = __TABLAS_DE_PAGINACION_LIN;
  __INICIO_DIRECTORIO = __TABLAS_DE_PAGINACION_FIS;


  /*------------NUCLEO------------*/
  .nucleo_out 0x00400000 :                  /* El vector "." de VMA le digo que arranque en 0x00400000 */
    { __NUCLEO_LIN = .;                     /* Cargo el valor anterior en la etiqueta __COPY_RAM (VALOR EN VMA) */
      __NUCLEO_ROM = LOADADDR(.nucleo_out); /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/copy.elf(.copy);                  /* Que copie la sección .copy del archivo copy ensamblado */
      bin/keyboard.elf(.keyboard);          /* Que copie la sección .teclado del archivo teclado.elf ensamblado */
      bin/screen.elf(.screen)               /* Que copie la sección .screen del archivo screen.elf ensamblado */
    } AT >rom                               /* Le pido que me cargue todo eso en ROM (LMA) */
    __NUCLEO_LENGHT = SIZEOF(.nucleo_out);  /* Le pido el largo de la seccion de .copy_out */
    __NUCLEO_FIS = __NUCLEO_LIN;
    __COPY_ROM = __NUCLEO_ROM;              /* Dirección de Copy */

  /*------TABLA DE DIGITOS-------*/
  .tabla_de_digitos_out 0x00410000 :           /* El vector "." de VMA le digo que arranque en 0x00410000 */
    { __TABLA_DE_DIGITOS_LIN = .;           /* Cargo el valor anterior en la etiqueta __INICIO_TABLA_DE_DIGITOS (VALOR EN VMA) */
      bin/tables.elf(.tabla_de_digitos);      /* Que copie la sección .tabla_de_digitos del archivo ensamblado */
    }
    __SIZE_TABLA_DE_DIGITOS = SIZEOF(.tabla_de_digitos_out);    /* Le pido el largo de la seccion de .tabla_de_digitos */
    __TABLA_DE_DIGITOS_FIS = __TABLA_DE_DIGITOS_LIN;

  /*----------TAREA 1------------*/
  .tarea_1_text_out 0x00510000 :                        /* El vector "." de VMA le digo que arranque en 0x00420000 */
    { __TAREA_1_TEXT_LIN = .;                            /* Cargo el valor anterior en la etiqueta __TAREA_1_TEXT_RAM (VALOR EN VMA) */
      __TAREA_1_TEXT_ROM = LOADADDR(.tarea_1_text_out);  /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_1.elf(.tarea_1_text);                    /* Que copie la sección .tarea_1_text del archivo ensamblado */
    } AT >rom                                           /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_TEXT_LENGHT = SIZEOF(.tarea_1_text_out);   /* Le pido el largo de la seccion de .tarea_1_text_out */
    __TAREA_1_TEXT_FIS = 0x00421000;

  .tarea_1_bss_out 0x00511000 :                        /* El vector "." de VMA le digo que arranque en 0x00421000 */
    { __TAREA_1_BSS_LIN = .;                           /* Cargo el valor anterior en la etiqueta __TAREA_1_BSS_RAM (VALOR EN VMA) */
      bin/tarea_1.elf(.tarea_1_bss);                   /* Que copie la sección .tarea_1_bss del archivo ensamblado */
    }                                                  /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_BSS_LENGHT = SIZEOF(.tarea_1_bss_out);   /* Le pido el largo de la seccion de .tarea_1_bss_out */
    __TAREA_1_BSS_FIS = 0x00042000;

  .tarea_1_data_rw_out 0x00512000 :                             /* El vector "." de VMA le digo que arranque en 0x00422000 */
    { __TAREA_1_DATA_RW_LIN = .;                                /* Cargo el valor anterior en la etiqueta __TAREA_1_DATA_RW_RAM (VALOR EN VMA) */
      __TAREA_1_DATA_RW_ROM = LOADADDR(.tarea_1_data_rw_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_1.elf(.tarea_1_data_rw);                        /* Que copie la sección .tarea_1_data_rw del archivo ensamblado */
    } AT >rom                                                   /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_DATA_RW_LENGHT = SIZEOF(.tarea_1_data_rw_out);    /* Le pido el largo de la seccion de .tarea_1_data_rw_out */
    __TAREA_1_DATA_RW_FIS = 0x00423000;

  .tarea_1_data_r_out 0x00513000 :                            /* El vector "." de VMA le digo que arranque en 0x00423000 */
    { __TAREA_1_DATA_R_LIN = .;                               /* Cargo el valor anterior en la etiqueta __TAREA_1_DATA_R_RAM (VALOR EN VMA) */
      __TAREA_1_DATA_R_ROM = LOADADDR(.tarea_1_data_r_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_1.elf(.tarea_1_data_r);                       /* Que copie la sección .tarea_1_data_r del archivo ensamblado */
    } AT >rom                                                 /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_DATA_R_LENGHT = SIZEOF(.tarea_1_data_r_out);    /* Le pido el largo de la seccion de .tarea_1_data_r_out */
    __TAREA_1_DATA_R_FIS = 0x00424000;

  /*-----------DATOS------------*/
  .datos_out 0x004E0000 :    /* El vector "." de VMA le digo que arranque en 0x004E0000 */
  {*(.datos)}                /* Todos los archivos de datos que los cargue en ese lugar */

  /*-----------PILA GENERAL------------*/
  __INICIO_PILA_GENERAL_LIN = 0x1FFFB000;                   /* Principio del stack */
  __FIN_PILA_GENERAL_LIN = 0x1FFFDFF0;                      /* La termino al principop de la pila de la tarea 1 */
  __SIZE_PILA_GENERAL = __FIN_PILA_GENERAL_LIN - __INICIO_PILA_GENERAL_LIN;     /* Calculo el largo de la pila */
  __INICIO_PILA_GENERAL_FIS = __INICIO_PILA_GENERAL_LIN;
  __FIN_PILA_GENERAL_FIS = __INICIO_PILA_GENERAL_FIS + __SIZE_PILA_GENERAL;

  /*-----------PILA TAREA 1------------*/
  __INICIO_PILA_TAREA_1_LIN = 0x1FFFE000;                               /* Principio del stack */
  __FIN_PILA_TAREA_1_LIN = 0x1FFFFFF0;                                  /* La termino al final de la RAM */
  __SIZE_PILA_TAREA_1 = __FIN_PILA_TAREA_1_LIN - __INICIO_PILA_TAREA_1_LIN; /* Calculo el largo de la pila */
  __INICIO_PILA_TAREA_1_FIS = __INICIO_PILA_TAREA_1_LIN;
  __FIN_PILA_TAREA_1_FIS = __INICIO_PILA_TAREA_1_FIS + __SIZE_PILA_TAREA_1;

}
