;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++ RESET +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section .reset
  arranque:
USE16
    mov ax,0
    jmp ax                        ; Salto al inicio del programa (16 bits)
    times 16-($-arranque) db 0    ; Relleno con ceros hasta el final

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++ INICIALIZACION MODO REAL +++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section .init_start

  jmp inicio    ; Salto a la rutina de inicialización

  ;--------- GDT Primaria (básica) ------------
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

  ;--------- Rutina de inicialización ------------
  inicio:
    cli                   ; Deshabilito las interrupciones
    db 0x66               ; Requerido para direcciones mayores que 0x00FFFFFFF.
    lgdt [cs:img_gdtr_prim]    ; Cargo la GDTR
    mov eax, cr0          ; Copio el registro de
    or eax,1              ; Habilito el bit de modo protegido
    mov cr0, eax          ; Guardo los cambios -> Activo el modo protegido

    jmp dword cs_sel_prim:modo_proteg    ; Voy a la sección de código en modo protegido

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++ INICIALIZACION MODO PROTEGIDO +++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;--------- Variables externas ------------
EXTERN __FIN_PILA
EXTERN __NUCLEO_ROM
EXTERN __NUCLEO_RAM
EXTERN __NUCLEO_LENGHT
EXTERN __COPY_ROM
EXTERN __RUTINAS_ROM
EXTERN __RUTINAS_RAM
EXTERN __RUTINAS_LENGHT
EXTERN copy
EXTERN gdt
EXTERN img_gdtr
EXTERN ds_sel
EXTERN cs_sel

USE32
  modo_proteg:
    ;--------- Cargo los selectores ------------
    mov ax,ds_sel_prim
    mov ds, ax
    mov ss, ax

    ;--------- Cargo la dirección del stack (pila) ------------
    mov esp, __FIN_PILA ; La pila se carga al revés (es decreciente)

    ;--------- Paso el NUCLEO a RAM (se copia a si mismo con la rutina copy) ------------
    push __NUCLEO_ROM     ; Pusheo ORIGEN
    push __NUCLEO_RAM     ; Pusheo DESTINO
    push __NUCLEO_LENGHT  ; Pusheo LARGO
    call __COPY_ROM       ; LLamo a la rutina en ROM
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio las RUTINAS a RAM ------------
    push __RUTINAS_ROM    ; Pusheo ORIGEN
    push __RUTINAS_RAM    ; Pusheo DESTINO
    push __RUTINAS_LENGHT ; Pusheo LARGO
    call copy             ; LLamo a la rutina en RAM
    pop eax               ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ;--------- Copio la GDT a RAM (y los selectores) ------------
    push gdt_prim       ; Pusheo ORIGEN
    push gdt            ; Pusheo DESTINO
    push long_gdt_prim  ; Pusheo LARGO
    call copy           ; LLamo a la rutina en RAM
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax

    ; CUANDO CARGO LA GDT SE REINICIA!!!!
    ;lgdt [cs:img_gdtr]    ; Cargo la GDTR con la gdt nueva
    ;mov ax,ds_sel
    ;mov ds, ax
    ;mov ss, ax

    jmp cs_sel_prim:main

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ RUTINAS  (MAIN) ++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;--------- Variables externas ------------
EXTERN rutina_teclado_polling

  main:
    ;--------- Copio la rutina copy a la direccion 0x00400000 ------------
    call rutina_teclado_polling
    breakpoint

    ;--------- Terminado, cuelgo el procesador ------------------
    hlt
