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
EXTERN img_gdtr_rom
EXTERN cs_sel_nucleo_rom


;--------- Variables compartidas -----------

;----------------------------- Jump al código -------------------------------
  jmp inicio    ; Salto a la rutina de inicialización

;---------------- Rutina de pasaje a modo protegido -------------------------
  inicio:
    cli                   ; Deshabilito las interrupciones
    call _bios_init       ; Inicialización para poder usar la pantalla
    db 0x66               ; Requerido para direcciones mayores que 0x00FFFFFFF.
    lgdt [cs:img_gdtr_rom]    ; Cargo la GDTR
    mov eax, cr0          ; Copio el registro de
    or eax,1              ; Habilito el bit de modo protegido
    mov cr0, eax          ; Guardo los cambios -> Activo el modo protegido

    jmp dword cs_sel_nucleo_rom:modo_proteg    ; Voy a la sección de código en modo protegido

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
EXTERN __NUCLEO_FIS
EXTERN __NUCLEO_LENGHT
EXTERN __COPY_ROM
EXTERN __HANDLERS_ROM
EXTERN __HANDLERS_FIS
EXTERN __HANDLERS_LENGHT
EXTERN __TAREA_0_TEXT_FIS
EXTERN __TAREA_1_TEXT_FIS
EXTERN __TAREA_2_TEXT_FIS
EXTERN __TAREA_0_TEXT_ROM
EXTERN __TAREA_1_TEXT_ROM
EXTERN __TAREA_2_TEXT_ROM
EXTERN __TAREA_0_TEXT_LENGHT
EXTERN __TAREA_1_TEXT_LENGHT
EXTERN __TAREA_2_TEXT_LENGHT
EXTERN copy
extern ds_sel_nucleo_rom
EXTERN gdt
EXTERN img_gdtr
EXTERN ds_sel
EXTERN cs_sel
EXTERN init_gdt
EXTERN init_idt
EXTERN img_idtr
EXTERN init_paginar
EXTERN __INICIO_DIRECTORIO
EXTERN _pic_configure
EXTERN _pit_configure

;---------------------------------------------------------------------------
  modo_proteg:
  ;--------- Cargo los selectores ------------
    mov ax, ds_sel_nucleo_rom
    mov ds, ax
    mov ss, ax

    ;--------- Cargo la dirección del stack (pila) ------------
    mov esp, __FIN_PILA_NUCLEO_FIS    ; La pila se carga al revés (es decreciente)

    ;--------- Paso el NUCLEO a RAM (se copia a si mismo con la rutina copy) ------------
    push __NUCLEO_ROM     ; Pusheo ORIGEN
    push __NUCLEO_FIS     ; Pusheo DESTINO
    push __NUCLEO_LENGHT  ; Pusheo LARGO
    call __COPY_ROM       ; LLamo a la rutina en ROM
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio los HANDLERS a RAM ------------
    push __HANDLERS_ROM    ; Pusheo ORIGEN
    push __HANDLERS_FIS    ; Pusheo DESTINO
    push __HANDLERS_LENGHT ; Pusheo LARGO
    call copy             ; LLamo a la rutina en RAM
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio los TAREA 0 a RAM ------------
    push __TAREA_0_TEXT_ROM     ; Pusheo ORIGEN
    push __TAREA_0_TEXT_FIS     ; Pusheo DESTINO
    push __TAREA_0_TEXT_LENGHT  ; Pusheo LARGO
    call copy                   ; LLamo a la rutina
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio los TAREA 1 a RAM ------------
    push __TAREA_1_TEXT_ROM     ; Pusheo ORIGEN
    push __TAREA_1_TEXT_FIS     ; Pusheo DESTINO
    push __TAREA_1_TEXT_LENGHT  ; Pusheo LARGO
    call copy                   ; LLamo a la rutina
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio los TAREA 2 a RAM ------------
    push __TAREA_2_TEXT_ROM     ; Pusheo ORIGEN
    push __TAREA_2_TEXT_FIS     ; Pusheo DESTINO
    push __TAREA_2_TEXT_LENGHT  ; Pusheo LARGO
    call copy                   ; LLamo a la rutina
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Inicializo las tablas y activo paginación ------------

    call init_paginar

    mov eax, __INICIO_DIRECTORIO
    mov cr3, eax          ; Cargo el directorio de páginas en cr3

    mov eax,cr0           ; Pongo en 1 el bit 31 de cr0: Paginacion activada
    or eax,0x80000000
    mov cr0,eax
    mov esp, __FIN_PILA_NUCLEO_LIN    ; Vuelvo a cargar la pila pero con su dirección lineal

    ;--------- Inicalizo y cargo la GDT en RAM  ------------
    call init_gdt

    ;--------- Inicializo y cargo la IDT ------------
    call init_idt

    ;--------- Inicializo el PIC ------------
    call _pic_configure

    ;--------- Inicializo el PIT ------------
    call _pit_configure

    ;--------- Activo SIMD ------------

    mov eax, cr0          ; Traigo los registros de control 0
    and eax, 0xFFFFFFFB		; Pongo en 0 el bit 2 (Emulation): x87 FPU present
    or eax, 0x8						; Pongo en 1 el bit 3 (Task Switched): Allows saving x87 task context upon a task switch only after x87 instruction used
    mov cr0, eax          ; Guardo los cambios

    mov eax, cr4          ; Traigo los registros de control 4
    or eax, 0x600         ; Pongo en 1 el bit 9 (Operating system support for FXSAVE and FXRSTOR instruction) y 10 (Operating System Support for Unmasked SIMD Floating-Point Exceptions)
    mov cr4, eax          ; Guardo los cambios

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ RUTINAS  (MAIN) ++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------

;--------- Variables externas ------------
EXTERN mostrar_nombre
EXTERN arrancar_scheduler

;--------- Variables compartidas -----------

;-----------------------------------------------------------------------------
  call mostrar_nombre

  main:
    call arrancar_scheduler
    jmp main          ; Vuelvo a esperar
