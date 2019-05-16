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
;++++++++++++++++++++++++++ INICIALIZACION +++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section .init

  jmp inicio    ; Salto a la rutina de inicialización

  ;--------- GDT ------------
  gdt:
    db 0,0,0,0,0,0,0,0                ; Descriptor nulo
    ds_sel equ $-gdt
    db 0xFF,0xFF,0,0,0,0x92,0xCF,0    ; Selector de datos
    cs_sel equ $-gdt
    db 0xFF,0xFF,0,0,0,0x9A,0xCF,0    ; Selector de codigo

    long_gdt equ $-gdt    ; Largo de la gdt

  img_gdtr:               ; Escribo primero la longitud y luego la GDT
    dw long_gdt - 1       ; dw me agrega 1 byte en cero antes: 0x0017 (3 elementos de 8 bytes: 23 -> 0x17)
    dd gdt

  ;--------- Rutina de inicialización ------------
  inicio:
    cli                   ; Deshabilito las interrupciones
    db 0x66               ; Requerido para direcciones mayores que 0x00FFFFFFF.
    lgdt [cs:img_gdtr]    ; Cargo la GDTR
    mov eax, cr0          ; Copio el registro de
    or eax,1              ; Habilito el bit de modo protegido
    mov cr0, eax          ; Guardo los cambios -> Activo el modo protegido

    jmp dword cs_sel:modo_proteg    ; Voy a la sección de código en modo protegido

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++ MODO PROTEGIDO +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;--------- Variables externas ------------
EXTERN __COPY_ROM
EXTERN __COPY_LENGHT
EXTERN __FIN_PILA
EXTERN copy
EXTERN __COPY_RAM_2
EXTERN __COPY_RAM_3

USE32
  modo_proteg:
    ;--------- Cargo los selectores ------------
    mov ax,ds_sel
    mov ds, ax
    mov ss, ax

    ;--------- Cargo la dirección del stack (pila) ------------
    mov esp, __FIN_PILA ; La pila se carga al revés (es decreciente)
    breakpoint

    ;--------- Paso la rutina copy a RAM (se copia a si misma) ------------
    push __COPY_ROM     ; Pusheo ORIGEN
    push copy           ; Pusheo DESTINO
    push __COPY_LENGHT  ; Pusheo LARGO
    call __COPY_ROM     ; LLamo a la rutina en ROM
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax
    breakpoint

    ;--------- Copio la rutina copy (en RAM) a la direccion 0x00300000 ------------
    push copy           ; Pusheo ORIGEN
    push __COPY_RAM_2   ; Pusheo DESTINO
    push __COPY_LENGHT  ; Pusheo LARGO
    call copy           ; LLamo a la rutina en ROM
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax
    breakpoint

    ;--------- Copio la rutina copy a la direccion 0x00400000 ------------
    push copy           ; Pusheo ORIGEN
    push __COPY_RAM_3   ; Pusheo DESTINO
    push __COPY_LENGHT  ; Pusheo LARGO
    call copy
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax
    breakpoint

    ;--------- Terminado, cuelgo el procesador ------------------
    hlt
