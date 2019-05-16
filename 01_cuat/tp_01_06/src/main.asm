section .reset
  arranque:
USE16
    mov ax,0
    jmp ax
    times 16-($-arranque) db 0    ;salto a inicio16

section .init

  jmp inicio

  gdt:
    db 0,0,0,0,0,0,0,0                ; Descriptor nulo
    ds_sel equ $-gdt
    db 0xFF,0xFF,0,0,0,0x92,0xCF,0    ; Selector de datos
    cs_sel equ $-gdt
    db 0xFF,0xFF,0,0,0,0x9A,0xCF,0    ; Selector de codigo

    long_gdt equ $-gdt

  img_gdtr:
    ;dw 3*8-1  ; 3 elementos de 8 bytes: 23 -> 0x17
    dw long_gdt - 1         ; dw me agrega 1 byte en cero antes: 0x0017
    dd gdt

  inicio:
    cli                   ; Deshabilito las interrupciones
    db 0x66               ; Requerido para direcciones mayores
    lgdt [cs:img_gdtr]    ; que 0x00FFFFFFF.
    mov eax, cr0          ; Habiltación bit de modo protegido.
    or eax,1
    mov cr0, eax

    jmp dword cs_sel:modo_proteg

EXTERN __COPY_ROM
EXTERN __COPY_LENGHT
EXTERN __FIN_PILA
EXTERN copy
EXTERN __COPY_RAM_2
EXTERN __COPY_RAM_3

USE32
  modo_proteg:
    ; Cargo los selectores
    mov ax,ds_sel
    mov ds, ax
    mov ss, ax
    ; Creo el stack
    mov esp, __FIN_PILA
    ; Copio la funcion copy en RAM (se copia a si misma)
    xchg bx,bx
    push __COPY_ROM     ; Pusheo ORIGEN
    push copy           ; Pusheo DESTINO
    push __COPY_LENGHT  ; Pusheo LARGO
    call __COPY_ROM     ; LLamo a la funcion en ROM
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax

    xchg bx,bx

    ; Copio la rutina copy a la direccion 0x00300000
    push copy
    push __COPY_RAM_2
    push __COPY_LENGHT
    call copy
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax

    xchg bx,bx

    ; Copio la rutina copy a la direccion 0x00400000
    push copy
    push __COPY_RAM_3
    push __COPY_LENGHT
    call copy
    pop eax             ; Saco los 3 push que hice antes
    pop eax
    pop eax

    xchg bx,bx

    ; Terminado, cuelgo el procesador
    hlt
