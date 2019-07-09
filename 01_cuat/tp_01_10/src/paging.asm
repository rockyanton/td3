;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

%define Table_Attrib_S_RW_P   0x03
%define Page_Attrib_S_RW_P    0x03
%define Page_Attrib_S_R_P     0x03

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++ TAREA QUE LEE EL BUFFER (DATA) +++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;  |11|10|9|8|7|6|5|4|3|2|1|0| ==> Page Directory Entry (Table)
;   |  |  | | | | | | | | | `----- Present (1) -- Not Present (0)
;   |  |  | | | | | | | | `------- Read/Write (1) -- Read Only (0)
;   |  |  | | | | | | | `--------- User/Spervisor (1) -- Supervisor (0)
;   |  |  | | | | | | `----------- Write-through
;   |  |  | | | | | `------------- Cache disabled
;   |  |  | | | | `--------------- Accesed
;   |  |  | | | `----------------- Reserved (0)
;   |  |  | | `------------------- Page size (0 para 4Kb)
;   |  |  | `--------------------- Global Page (Ignored)
;   `--`--`----------------------- Available for system programer's use

;  |11|10|9|8|7|6|5|4|3|2|1|0| ==> Page Table Entry (Page)
;   |  |  | | | | | | | | | `----- Present (1) -- Not Present (0)
;   |  |  | | | | | | | | `------- Read/Write (1) -- Read Only (0)
;   |  |  | | | | | | | `--------- User/Spervisor
;   |  |  | | | | | | `----------- Write-through
;   |  |  | | | | | `------------- Cache disabled
;   |  |  | | | | `--------------- Accesed
;   |  |  | | | `----------------- Dirty
;   |  |  | | `------------------- Reserved (0)
;   |  |  | `--------------------- Global Page
;   `--`--`----------------------- Available for system programer's use


;________________________________________________________________________________________________________________
;                       |   Dirección  |              |  Cantidad  | Indice Tabla |  Indice Página  |           |
;        Sección        |    Lineal    |   Longitud   | de Páginas | (Directorio) |     (Tabla)     | ¿Paginar? |
;_______________________|______________|______________|____________|______________|_________________|___________|
; Handlers (ISR)        | 0x 0000 0000 | 0x 0000 00CA |     1      |    0x 000    |     0x 000      |     SI    |
; Buffer de video       | 0x 000B 8000 | 0x 0000 0FA0 |     1      |    0x 000    |     0x 0B8      |     SI    |
; Tablas de Sistema     | 0x 0010 0000 | 0x 0000 0810 |     1      |    0x 000    |     0x 100      |     SI    |
; Tablas de Paginacion  | 0x 0011 0000 | 0x 0000 5004 |     6      |    0x 000    |     0x 110      |     SI    |
; Nucleo                | 0x 0040 0000 | 0x 0000 0404 |     1      |    0x 001    |     0x 000      |     SI    |
; Tabla de Digitos      | 0x 0041 0000 | 0x 0000 fc09 |    16      |    0x 001    | 0x 010 - 0x 01F |     SI    |
; Tarea 1 (Text)        | 0x 0042 0000 | 0x 0000 0129 |     1      |    0x 001    |     0x 020      |     SI    |
; Tarea 1 (BSS)         | 0x 0042 1000 | 0x 0000 0000 |     0      |    0x 001    |     0x 021      |     NO    |
; Tarea 1 (Data RW)     | 0x 0042 2000 | 0x 0000 0000 |     0      |    0x 001    |     0x 022      |     NO    |
; Tarea 1 (Data R)      | 0x 0042 3000 | 0x 0000 0000 |     0      |    0x 001    |     0x 023      |     NO    |
; Datos                 | 0x 004E 0000 | 0x 0000 0000 |     0      |    0x 001    |     0x 0E0      |     NO    |
; Pila General          | 0x 1FFF B000 | 0x 0000 2FF0 |     3      |    0x 07F    | 0x 3FB - 0x 3FD |     SI    |
; Pila Tarea 1          | 0x 1FFF E000 | 0x 0000 1FF0 |     2      |    0x 07F    | 0x 3FE - 0x 3FF |     SI    |
; Inicializacion ROM    | 0x FFFF 0000 | 0x 0000 1718 |     2      |    0x 3FF    | 0x 3F0 - 0x 3F1 |     SI    |
; Vector de reset       | 0x FFFF FFF0 | 0x 0000 0010 |     1      |    0x 3FF    |     0x 3FF      |     NO    |
;_______________________|______________|______________|____________|______________|_________________|___________|

;--------- Parámetros globales ------------
USE32
section .init

;--------- Variables externas ------------
EXTERN __INICIO_DIRECTORIO

EXTERN __HANDLERS_RAM
EXTERN __HANDLERS_LENGHT
EXTERN __INICIO_BUFFER_DE_VIDEO
EXTERN __SIZE_BUFFER_DE_VIDEO
EXTERN __TABLAS_DE_SISTEMA_RAM
EXTERN __TABLAS_DE_SISTEMA_LENGHT
EXTERN __TABLAS_DE_PAGINACION_RAM
EXTERN __TABLAS_DE_PAGINACION_LENGHT
EXTERN __NUCLEO_RAM
EXTERN __NUCLEO_LENGHT
EXTERN __INICIO_TABLA_DE_DIGITOS
EXTERN __SIZE_TABLA_DE_DIGITOS
EXTERN __TAREA_1_TEXT_RAM
EXTERN __TAREA_1_TEXT_LENGHT
EXTERN __INICIO_PILA
EXTERN __SIZE_PILA
EXTERN __INICIO_PILA_TAREA_1
EXTERN __SIZE_PILA_TAREA_1



;--------- Variables compartidas -----------
GLOBAL init_paginar
GLOBAL directorio


  init_paginar:

    ; ORDEN DE PUSHEO
    ;    1 - Atributos del directorio (tabla)
    ;    2 - Atributos de pagina
    ;    3 - Largo de la sección
    ;    4 - Direccion Física
    ;    5 - Dirección Lineal

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __HANDLERS_LENGHT
    push __HANDLERS_RAM
    push __HANDLERS_RAM
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __SIZE_BUFFER_DE_VIDEO
    push __INICIO_BUFFER_DE_VIDEO
    push __INICIO_BUFFER_DE_VIDEO
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __TABLAS_DE_SISTEMA_LENGHT
    push __TABLAS_DE_SISTEMA_RAM
    push __TABLAS_DE_SISTEMA_RAM
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __TABLAS_DE_PAGINACION_LENGHT
    push __TABLAS_DE_PAGINACION_RAM
    push __TABLAS_DE_PAGINACION_RAM
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __NUCLEO_LENGHT
    push __NUCLEO_RAM
    push __NUCLEO_RAM
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __SIZE_TABLA_DE_DIGITOS
    push __INICIO_TABLA_DE_DIGITOS
    push __INICIO_TABLA_DE_DIGITOS
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __TAREA_1_TEXT_LENGHT
    push __TAREA_1_TEXT_RAM
    push __TAREA_1_TEXT_RAM
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __SIZE_PILA
    push __INICIO_PILA
    push __INICIO_PILA
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    push Table_Attrib_S_RW_P
    push Page_Attrib_S_RW_P
    push __SIZE_PILA_TAREA_1
    push __INICIO_PILA_TAREA_1
    push __INICIO_PILA_TAREA_1
    call paginar
    pop eax
    pop eax
    pop eax
    pop eax
    pop eax

    ret


;-------------------------------------------------------------

  paginar:

    mov ebp, esp          ; Puntero a pila
    mov esi, [ebp + 0x04]    ; Cargo direccion lineal
    mov edi, esi

    shr esi, 0x16     ; Primeros 10 bits de la direccion lineal son el indice de direcorio
    and esi, 0x3FF

    shr edi, 0x0C     ; Segundos 10 bits son el indice de tabla
    and edi, 0x3FF

    mov eax, [directorio + esi*4]   ; Compruebo si no existe la tabla en el directorio (entrada vacía)
    cmp eax, 0x00
    jnz tabla_creada    ; Si existe, salto al cargado de entradas de la tabla de paginas
    jmp crear_tabla     ; Si no, primero creo la página

    crear_tabla:
      mov eax, [tablas_creadas]      ; Traigo el contador de tablas paginadas

      mov ebx, eax                  ; Copio el valor
      inc ebx                       ; Incremento valor de tablas creadas
      mov [tablas_creadas], ebx     ; Guardo valor incrementado de tablas creadas

      shl eax, 0x0C                 ; Multiplico por 4*1024=4096 (Desplazo 12 bits)

      mov ebx, inicio_tablas        ; Traigo el inicio de la seccion de memoria de tablas
      add ebx, eax                  ; Le sumo el indice de tablas ya paginadas
      and ebx, 0xFFFFF000           ; Me quedo con los primeros 20 bytes
      mov ecx, ebx                  ; Copio el valor
      add ecx, [ebp + 0x14]           ; Le sumo los atributos de tabla

      mov [directorio + esi*4], ecx ; Guardo la entrada del directorio

      jmp crear_paginas

    tabla_creada:
      mov ebx, [directorio + esi*4]

      jmp crear_paginas

    crear_paginas:
      mov ecx, [ebp + 0x10]   ; Traigo el largo de Sección
      shr ecx, 0x0C           ; A partir de los 12 bits es la cantidad de paginas -1
      inc ecx                 ; Incremento para saber la cant de paginas

      xor edx, edx        ; Pongo edx en 0

      mov eax, [ebp + 0x08]   ; Traigo dirección física

      loop_paginar:
        and eax, 0xFFFFF000   ; Me quedo con los primeros 20 bytes
        add eax, [ebp + 0x10] ; Agrego atributos

        mov [ebx + edx*4], eax        ; Guardo entrada de página en tabla

        add eax, 0x1000       ; Le sumo 4k (para siguiente ciclo)
        inc edx               ; Incremento paginas

      cmp edx, ecx
      jnz loop_paginar

    ret   ; Vuelvo



;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++ TABLA DE PAGINACIÓN +++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
section .tablas_de_paginacion nobits     ; nobits le dice al linker que esa sección va a existir pero que no carge nada (sino me hace un archivo de 4GB)

;--------- Variables externas ------------

;--------- Variables compartidas -----------


  directorio:
    resd 1024       ; Reservo los 1024 bytes del directorio
  inicio_tablas:
    resd 1024*4     ; Tengo 4 tablas en total
  tablas_creadas:
    resd 1          ; Reservo un indicador de tabla creada
