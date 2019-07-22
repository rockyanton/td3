;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++ RESET +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE16
section .reset

;--------- Variables externas ------------

;--------- Variables compartidas -----------

;------------------------ Salto inicial (reset) ------------------------------
    arranque:
    mov ax,0
    jmp ax                        ; Salto al inicio del programa (16 bits)
    times 16-($-arranque) db 0    ; Relleno con ceros hasta el final

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++ INICIALIZACION MODO REAL +++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
section .init_start

;--------- Variables externas ------------
EXTERN _bios_init

;--------- Variables compartidas -----------

;----------------------------- Jump al código -------------------------------
  jmp inicio    ; Salto a la rutina de inicialización

;----------------------- GDT Primaria (básica) ------------------------------
  GLOBAL cs_sel_prim
  GLOBAL ds_sel_prim

  gdt_prim:
    db 0,0,0,0,0,0,0,0                ; Descriptor nulo
    ds_sel_prim equ $-gdt_prim
    db 0xFF,0xFF,0,0,0,0x92,0xCF,0    ; Selector de datos
    cs_sel_prim equ $-gdt_prim
    db 0xFF,0xFF,0,0,0,0x9A,0xCF,0    ; Selector de codigo

    long_gdt_prim equ $-gdt_prim    ; Largo de la gdt

  img_gdtr_prim:               ; Escribo primero la longitud y luego la GDT
    dw long_gdt_prim - 1       ; dw me agrega 1 byte en cero antes: 0x0017 (3 elementos de 8 bytes: 23 -> 0x17)
    dd gdt_prim

;---------------- Rutina de pasaje a modo protegido -------------------------
  inicio:
    cli                   ; Deshabilito las interrupciones
    call _bios_init       ; Inicialización para poder usar la pantalla
    db 0x66               ; Requerido para direcciones mayores que 0x00FFFFFFF.
    lgdt [cs:img_gdtr_prim]    ; Cargo la GDTR
    mov eax, cr0          ; Copio el registro de
    or eax,1              ; Habilito el bit de modo protegido
    mov cr0, eax          ; Guardo los cambios -> Activo el modo protegido

    jmp dword cs_sel_prim:modo_proteg    ; Voy a la sección de código en modo protegido

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++ INICIALIZACION MODO PROTEGIDO +++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32

;--------- Variables compartidas -----------

;--------- Variables externas ------------
EXTERN __FIN_PILA_NUCLEO_FIS
EXTERN __FIN_PILA_NUCLEO_LIN
EXTERN __NUCLEO_ROM
EXTERN __NUCLEO_LIN
EXTERN __NUCLEO_LENGHT
EXTERN __COPY_ROM
EXTERN __HANDLERS_ROM
EXTERN __HANDLERS_LIN
EXTERN __HANDLERS_LENGHT
EXTERN __TAREA_1_TEXT_ROM
EXTERN __TAREA_1_TEXT_LIN
EXTERN __TAREA_1_TEXT_LENGHT
EXTERN copy
EXTERN gdt
EXTERN img_gdtr
EXTERN ds_sel
EXTERN cs_sel
EXTERN init_idt
EXTERN img_idtr
EXTERN init_paginar
EXTERN __INICIO_DIRECTORIO
EXTERN _pic_configure
EXTERN _pit_configure

;---------------------------------------------------------------------------
  modo_proteg:
  ;--------- Cargo los selectores ------------
    mov ax,ds_sel_prim
    mov ds, ax
    mov ss, ax

    ;--------- Cargo la dirección del stack (pila) ------------
    mov esp, __FIN_PILA_NUCLEO_FIS    ; La pila se carga al revés (es decreciente)

    ;--------- Inicializo las tablas y activo paginación ------------

    call init_paginar

    mov eax, __INICIO_DIRECTORIO
    mov cr3, eax          ; Cargo el directorio de páginas en cr3

    mov eax,cr0           ; Pongo en 1 el bit 31 de cr0: Paginacion activada
    or eax,0x80000000
    mov cr0,eax
    mov esp, __FIN_PILA_NUCLEO_LIN    ; La pila se carga al revés (es decreciente)

    ;--------- Paso el NUCLEO a RAM (se copia a si mismo con la rutina copy) ------------
    push __NUCLEO_ROM     ; Pusheo ORIGEN
    push __NUCLEO_LIN     ; Pusheo DESTINO
    push __NUCLEO_LENGHT  ; Pusheo LARGO
    call __COPY_ROM       ; LLamo a la rutina en ROM
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio los HANDLERS a RAM ------------
    push __HANDLERS_ROM    ; Pusheo ORIGEN
    push __HANDLERS_LIN    ; Pusheo DESTINO
    push __HANDLERS_LENGHT ; Pusheo LARGO
    call copy             ; LLamo a la rutina en RAM
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio la GDT a RAM  ------------
    push gdt_prim       ; Pusheo ORIGEN
    push gdt            ; Pusheo DESTINO
    push long_gdt_prim  ; Pusheo LARGO
    call copy           ; LLamo a la rutina en RAM
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Cargo la nueva GDT de RAM  y los selectores ------------
    lgdt [cs:img_gdtr]    ; Cargo la GDTR con la gdt nueva
    mov ax,ds_sel
    mov ds, ax
    mov ss, ax

    ;--------- Inicializo y cargo la IDT ------------
    call init_idt
    lidt [cs:img_idtr]

    ;--------- Inicializo el PIC ------------
    call _pic_configure

    ;--------- Inicializo el PIT ------------
    call _pit_configure

    ;--------- Enciendo las interrupciones ------------
    sti

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ RUTINAS  (MAIN) ++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------

;--------- Variables externas ------------
EXTERN mostrar_nombre

;--------- Variables compartidas -----------

;-----------------------------------------------------------------------------
  call mostrar_nombre

  main:
    hlt       ; Halteo el procesador hasta que me llegue algo
    jmp main          ; Vuelvo a esperar
