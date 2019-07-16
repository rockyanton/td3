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
  .nucleo_out 0x00500000 :                  /* El vector "." de VMA le digo que arranque en 0x00400000 */
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
  .tabla_de_digitos_out 0x00510000 :           /* El vector "." de VMA le digo que arranque en 0x00410000 */
    { __TABLA_DE_DIGITOS_LIN = .;           /* Cargo el valor anterior en la etiqueta __INICIO_TABLA_DE_DIGITOS (VALOR EN VMA) */
      bin/tables.elf(.tabla_de_digitos);      /* Que copie la sección .tabla_de_digitos del archivo ensamblado */
    }
    __SIZE_TABLA_DE_DIGITOS = SIZEOF(.tabla_de_digitos_out);    /* Le pido el largo de la seccion de .tabla_de_digitos */
    __TABLA_DE_DIGITOS_FIS = __TABLA_DE_DIGITOS_LIN;

  /*----------TAREA 0------------*/
  .tarea_0_text_out 0x00610000 :                          /* El vector "." de VMA le digo que arranque en 0x00610000 */
    { __TAREA_0_TEXT_LIN = .;                             /* Cargo el valor anterior en la etiqueta __TAREA_0_TEXT_RAM (VALOR EN VMA) */
      __TAREA_0_TEXT_ROM = LOADADDR(.tarea_0_text_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_0.elf(.tarea_0_text);                     /* Que copie la sección .tarea_0_text del archivo ensamblado */
    } AT >rom                                             /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_0_TEXT_LENGHT = SIZEOF(.tarea_0_text_out);    /* Le pido el largo de la seccion de .tarea_0_text_out */
    __TAREA_0_TEXT_FIS = 0x00501000;

  .tarea_0_bss_out 0x00611000 :                        /* El vector "." de VMA le digo que arranque en 0x00421000 */
    { __TAREA_0_BSS_LIN = .;                           /* Cargo el valor anterior en la etiqueta __TAREA_0_BSS_RAM (VALOR EN VMA) */
      bin/tarea_0.elf(.tarea_0_bss);                   /* Que copie la sección .tarea_0_bss del archivo ensamblado */
    }                                                  /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_0_BSS_LENGHT = SIZEOF(.tarea_0_bss_out);   /* Le pido el largo de la seccion de .tarea_0_bss_out */
    __TAREA_0_BSS_FIS = 0x00502000;

  .tarea_0_data_rw_out 0x00612000 :                             /* El vector "." de VMA le digo que arranque en 0x00422000 */
    { __TAREA_0_DATA_RW_LIN = .;                                /* Cargo el valor anterior en la etiqueta __TAREA_0_DATA_RW_RAM (VALOR EN VMA) */
      __TAREA_0_DATA_RW_ROM = LOADADDR(.tarea_0_data_rw_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_0.elf(.tarea_0_data_rw);                        /* Que copie la sección .tarea_0_data_rw del archivo ensamblado */
    } AT >rom                                                   /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_0_DATA_RW_LENGHT = SIZEOF(.tarea_0_data_rw_out);    /* Le pido el largo de la seccion de .tarea_0_data_rw_out */
    __TAREA_0_DATA_RW_FIS = 0x00503000;

  .tarea_0_data_r_out 0x00613000 :                            /* El vector "." de VMA le digo que arranque en 0x00423000 */
    { __TAREA_0_DATA_R_LIN = .;                               /* Cargo el valor anterior en la etiqueta __TAREA_0_DATA_R_RAM (VALOR EN VMA) */
      __TAREA_0_DATA_R_ROM = LOADADDR(.tarea_0_data_r_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_0.elf(.tarea_0_data_r);                       /* Que copie la sección .tarea_0_data_r del archivo ensamblado */
    } AT >rom                                                 /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_0_DATA_R_LENGHT = SIZEOF(.tarea_0_data_r_out);    /* Le pido el largo de la seccion de .tarea_0_data_r_out */
    __TAREA_0_DATA_R_FIS = 0x00504000;

  /*----------TAREA 1------------*/
  .tarea_1_text_out 0x00610000 :                        /* El vector "." de VMA le digo que arranque en 0x00420000 */
    { __TAREA_1_TEXT_LIN = .;                            /* Cargo el valor anterior en la etiqueta __TAREA_1_TEXT_RAM (VALOR EN VMA) */
      __TAREA_1_TEXT_ROM = LOADADDR(.tarea_1_text_out);  /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_1.elf(.tarea_1_text);                    /* Que copie la sección .tarea_1_text del archivo ensamblado */
    } AT >rom                                           /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_TEXT_LENGHT = SIZEOF(.tarea_1_text_out);   /* Le pido el largo de la seccion de .tarea_1_text_out */
    __TAREA_1_TEXT_FIS = 0x00521000;

  .tarea_1_bss_out 0x00611000 :                        /* El vector "." de VMA le digo que arranque en 0x00421000 */
    { __TAREA_1_BSS_LIN = .;                           /* Cargo el valor anterior en la etiqueta __TAREA_1_BSS_RAM (VALOR EN VMA) */
      bin/tarea_1.elf(.tarea_1_bss);                   /* Que copie la sección .tarea_1_bss del archivo ensamblado */
    }                                                  /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_BSS_LENGHT = SIZEOF(.tarea_1_bss_out);   /* Le pido el largo de la seccion de .tarea_1_bss_out */
    __TAREA_1_BSS_FIS = 0x00522000;

  .tarea_1_data_rw_out 0x00612000 :                             /* El vector "." de VMA le digo que arranque en 0x00422000 */
    { __TAREA_1_DATA_RW_LIN = .;                                /* Cargo el valor anterior en la etiqueta __TAREA_1_DATA_RW_RAM (VALOR EN VMA) */
      __TAREA_1_DATA_RW_ROM = LOADADDR(.tarea_1_data_rw_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_1.elf(.tarea_1_data_rw);                        /* Que copie la sección .tarea_1_data_rw del archivo ensamblado */
    } AT >rom                                                   /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_DATA_RW_LENGHT = SIZEOF(.tarea_1_data_rw_out);    /* Le pido el largo de la seccion de .tarea_1_data_rw_out */
    __TAREA_1_DATA_RW_FIS = 0x00523000;

  .tarea_1_data_r_out 0x00613000 :                            /* El vector "." de VMA le digo que arranque en 0x00423000 */
    { __TAREA_1_DATA_R_LIN = .;                               /* Cargo el valor anterior en la etiqueta __TAREA_1_DATA_R_RAM (VALOR EN VMA) */
      __TAREA_1_DATA_R_ROM = LOADADDR(.tarea_1_data_r_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_1.elf(.tarea_1_data_r);                       /* Que copie la sección .tarea_1_data_r del archivo ensamblado */
    } AT >rom                                                 /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_1_DATA_R_LENGHT = SIZEOF(.tarea_1_data_r_out);    /* Le pido el largo de la seccion de .tarea_1_data_r_out */
    __TAREA_1_DATA_R_FIS = 0x00524000;

  /*----------TAREA 2------------*/
  .tarea_2_text_out 0x00610000 :                        /* El vector "." de VMA le digo que arranque en 0x00420000 */
    { __TAREA_2_TEXT_LIN = .;                            /* Cargo el valor anterior en la etiqueta __TAREA_2_TEXT_RAM (VALOR EN VMA) */
      __TAREA_2_TEXT_ROM = LOADADDR(.tarea_2_text_out);  /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_2.elf(.tarea_2_text);                    /* Que copie la sección .tarea_2_text del archivo ensamblado */
    } AT >rom                                           /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_2_TEXT_LENGHT = SIZEOF(.tarea_2_text_out);   /* Le pido el largo de la seccion de .tarea_2_text_out */
    __TAREA_2_TEXT_FIS = 0x00531000;

  .tarea_2_bss_out 0x00611000 :                        /* El vector "." de VMA le digo que arranque en 0x00421000 */
    { __TAREA_2_BSS_LIN = .;                           /* Cargo el valor anterior en la etiqueta __TAREA_2_BSS_RAM (VALOR EN VMA) */
      bin/tarea_2.elf(.tarea_2_bss);                   /* Que copie la sección .tarea_2_bss del archivo ensamblado */
    }                                                  /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_2_BSS_LENGHT = SIZEOF(.tarea_2_bss_out);   /* Le pido el largo de la seccion de .tarea_2_bss_out */
    __TAREA_2_BSS_FIS = 0x00532000;

  .tarea_2_data_rw_out 0x00612000 :                             /* El vector "." de VMA le digo que arranque en 0x00422000 */
    { __TAREA_2_DATA_RW_LIN = .;                                /* Cargo el valor anterior en la etiqueta __TAREA_2_DATA_RW_RAM (VALOR EN VMA) */
      __TAREA_2_DATA_RW_ROM = LOADADDR(.tarea_2_data_rw_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_2.elf(.tarea_2_data_rw);                        /* Que copie la sección .tarea_2_data_rw del archivo ensamblado */
    } AT >rom                                                   /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_2_DATA_RW_LENGHT = SIZEOF(.tarea_2_data_rw_out);    /* Le pido el largo de la seccion de .tarea_2_data_rw_out */
    __TAREA_2_DATA_RW_FIS = 0x00533000;

  .tarea_2_data_r_out 0x00613000 :                            /* El vector "." de VMA le digo que arranque en 0x00423000 */
    { __TAREA_2_DATA_R_LIN = .;                               /* Cargo el valor anterior en la etiqueta __TAREA_2_DATA_R_RAM (VALOR EN VMA) */
      __TAREA_2_DATA_R_ROM = LOADADDR(.tarea_2_data_r_out);   /* Como no se en que parte de la rom me lo cargan (LMA), tengo que usar la funcion LOADADDR para que me diga donde cargó esa seccion */
      bin/tarea_2.elf(.tarea_2_data_r);                       /* Que copie la sección .tarea_2_data_r del archivo ensamblado */
    } AT >rom                                                 /* Le pido que me cargue todo eso en ROM (LMA) */
    __TAREA_2_DATA_R_LENGHT = SIZEOF(.tarea_2_data_r_out);    /* Le pido el largo de la seccion de .tarea_2_data_r_out */
    __TAREA_2_DATA_R_FIS = 0x00534000;

  /*-----------DATOS------------*/
  .datos_out 0x005E0000 :    /* El vector "." de VMA le digo que arranque en 0x004E0000 */
  { __DATOS_LIN = .;
    *(.datos);              /* Todos los archivos de datos que los cargue en ese lugar */
  }
  __DATOS_FIS = __DATOS_LIN;

  /*-----------PILA NUCLEO TAREA 0------------*/
  __INICIO_PILA_NUCLEO_TAREA_0_LIN = 0x1FFF8000;                               /* Principio del stack */
  __SIZE_PILA_NUCLEO_TAREA_0 = 0x00000FFC; /* Calculo el largo de la pila */
  __FIN_PILA_NUCLEO_TAREA_0_LIN = __INICIO_PILA_NUCLEO_TAREA_0_LIN + __SIZE_PILA_NUCLEO_TAREA_0;
  __INICIO_PILA_NUCLEO_TAREA_0_FIS = 0x00614000;

  /*-----------PILA NUCLEO TAREA 1------------*/
  __INICIO_PILA_NUCLEO_TAREA_1_LIN = 0x1FFF9000;                               /* Principio del stack */
  __SIZE_PILA_NUCLEO_TAREA_1 = 0x00000FFC;
  __FIN_PILA_NUCLEO_TAREA_1_LIN = __INICIO_PILA_NUCLEO_TAREA_1_LIN + __SIZE_PILA_NUCLEO_TAREA_1; /* Calculo el largo de la pila */
  __INICIO_PILA_NUCLEO_TAREA_1_FIS = 0x00614000;

  /*-----------PILA NUCLEO TAREA 2------------*/
  __INICIO_PILA_NUCLEO_TAREA_2_LIN = 0x1FFFA000;                               /* Principio del stack */
  __SIZE_PILA_NUCLEO_TAREA_2 = 0x00000FFC;
  __FIN_PILA_NUCLEO_TAREA_2_LIN = __INICIO_PILA_NUCLEO_TAREA_2_LIN + __SIZE_PILA_NUCLEO_TAREA_2; /* Calculo el largo de la pila */
  __INICIO_PILA_NUCLEO_TAREA_2_FIS = 0x00614000;

  /*-----------PILA NUCLEO------------*/
  __INICIO_PILA_NUCLEO_LIN = 0x1FFFB000;                   /* Principio del stack */
  __FIN_PILA_NUCLEO_LIN = 0x1FFFBFFC;                      /* La termino al principop de la pila de la tarea 1 */
  __SIZE_PILA_NUCLEO = __FIN_PILA_NUCLEO_LIN - __INICIO_PILA_NUCLEO_LIN;     /* Calculo el largo de la pila */
  __INICIO_PILA_NUCLEO_FIS = __INICIO_PILA_NUCLEO_LIN;
  __FIN_PILA_NUCLEO_FIS = __INICIO_PILA_NUCLEO_FIS + __SIZE_PILA_NUCLEO;

  /*-----------PILA USUARIO TAREA 0------------*/
  __INICIO_PILA_USUARIO_TAREA_0_LIN = 0x1FFFC000;                               /* Principio del stack */
  __SIZE_PILA_USUARIO_TAREA_0 = 0x00000FFC; /* Calculo el largo de la pila */
  __FIN_PILA_USUARIO_TAREA_0_LIN = __INICIO_PILA_USUARIO_TAREA_0_LIN + __SIZE_PILA_USUARIO_TAREA_0;
  __INICIO_PILA_USUARIO_TAREA_0_FIS = 0x00613000;

  /*-----------PILA USUARIO TAREA 1------------*/
  __INICIO_PILA_USUARIO_TAREA_1_LIN = 0x1FFFD000;                               /* Principio del stack */
  __SIZE_PILA_USUARIO_TAREA_1 = 0x00000FFC; /* Calculo el largo de la pila */
  __FIN_PILA_USUARIO_TAREA_1_LIN = __INICIO_PILA_USUARIO_TAREA_1_LIN + __SIZE_PILA_USUARIO_TAREA_1;
  __INICIO_PILA_USUARIO_TAREA_1_FIS = 0x00613000;

  /*-----------PILA USUARIO TAREA 2------------*/
  __INICIO_PILA_USUARIO_TAREA_2_LIN = 0x1FFFE000;                               /* Principio del stack */
  __SIZE_PILA_USUARIO_TAREA_2 = 0x00000FFC; /* Calculo el largo de la pila */
  __FIN_PILA_USUARIO_TAREA_2_LIN = __INICIO_PILA_USUARIO_TAREA_2_LIN + __SIZE_PILA_USUARIO_TAREA_2;
  __INICIO_PILA_USUARIO_TAREA_2_FIS = 0x00613000;

}
