;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

%define ASCII_0   0x30
%define ASCII_1   0x31
%define ASCII_A   0x41
%define ASCII_B   0x42
%define ASCII_C   0x43
%define ASCII_D   0x44
%define ASCII_E   0x45
%define ASCII_F   0x46

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ TAREA QUE LEE EL BUFFER ++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1

;--------- Variables externas ------------
EXTERN keyboard_buffer_hexa
EXTERN keyboard_buffer_status
EXTERN tabla_de_digitos
EXTERN puntero_tabla_digitos

;--------- Variables compartidas -----------
GLOBAL check_keyboard_buffer

  check_keyboard_buffer:
    pushad
    xor eax, eax      ; Limpio registro
    mov al, [keyboard_buffer_status]
    mov bl, al        ; Guardo el valor
    and bl, 0x80      ; El bit 8 es el de flag de enter
    cmp bl, 0x80
    jnz end_check_keyboard_buffer   ; Si no hay enter me voy

    and al, 0x1F    ; Los primeros 5 bytes son el contador
    mov dl, 0x02
    div dl          ; Divido al por 2 para tener la cantidad de bytes y la parte alta o baja
    xor edx, edx
    mov dl, al      ; Copio el indice de bytes

    inc edx         ; Avanzo al siguiente byte

    cmp ah, 0x01    ; Si estoy en la parte baja tengo que avanzar un byte mas
    jnz no_inc_extra
      inc edx
    no_inc_extra:

    cmp edx, 0x09       ; Chequeo overflow
    jl no_overflow_ini
      sub edx, 0x09     ; Le resto lo que me pase
    no_overflow_ini:

    xor ah, 0x01    ; La arranco a copiar por la parte contraria a la ultima que escribí

    mov al, 0x00    ; Parte baja o alta de la tabla de digitos

    xor ebx, ebx
    mov bl, [puntero_tabla_digitos]
    mov ebp, ebx        ; Copio el indice de la tabla del ultimo registro

    xor esi, esi        ; Limpio variables
    xor ecx, ecx

    copio_buffer:
      xor ebx, ebx      ; Limpio ebx
      cmp ah, 0x00
      jz copio_parte_alta
      jmp copio_parte_baja

      copio_parte_baja:
        mov bl, [keyboard_buffer_hexa + edx]
        and bl, 0x0F
        call guardar_en_tabla
        xor ah, 0x01                      ; Para poder copiar parte alta en siguiente ciclo
        inc edx                           ; Cambio de byte para siguiente ciclo
        cmp edx, 0x09                     ; Chequeo overflow
        jl no_overflow_baja
          xor edx, edx
        no_overflow_baja:
        jmp copio_buffer_check


      copio_parte_alta:
        mov bl, [keyboard_buffer_hexa + edx]  ; Traigo el byte
        and bl, 0xF0                      ; Obtengo la parte alta
        shr bl, 0x04
        call guardar_en_tabla
        xor ah, 0x01  ; Para poder copiar parte baja en siguiente ciclo
        jmp copio_buffer_check

      copio_buffer_check:
        inc cl
        cmp cl, 0x10          ; Me fijo si cargue los 64 bits
        jz copio_buffer_end
        jmp copio_buffer

      copio_buffer_end:
        inc ebp             ; Incremento indice (para siguiente ciclo)
        mov ecx, ebp        ; Guardo el puntero actualizado
        mov [puntero_tabla_digitos], cl
        call limpiar_buffer_teclado       ; Vacío el buffer de teclado

        mov al, [keyboard_buffer_status]  ; Saco el flag de enter
        and al, 0x7F
        mov [keyboard_buffer_status], al

        call sumar_tabla

        jmp end_check_keyboard_buffer


      guardar_en_tabla:
        cmp al, 0x00
        jz guardar_parte_alta
        jmp guardar_parte_baja

        guardar_parte_alta:
          shl bl, 0x04        ; Muevo hacia parte alta
          and bl, 0xF0
          mov [tabla_de_digitos + ebp*8 + esi], bl  ; Guardo
          xor al, 0x01        ; Siguiente ciclo parte baja
          ret

        guardar_parte_baja:
          and bl, 0x0F      ; Me quedo con la parte baja
          mov bh, [tabla_de_digitos + ebp*8 + esi]    ; Traigo la parte alta
          and bh, 0xF0
          or bl, bh         ; Uno todo
          mov [tabla_de_digitos + ebp*8 + esi], bl    ; Guardo
          xor al, 0x01      ; Siguiente ciclo parte alta
          inc esi           ; Incremento indice de byte
          ret

      sumar_tabla:
        mov ecx, ebp
        ; SEGUIR ACA


      limpiar_buffer_teclado:
        xor ecx, ecx
        xor edx, edx

        loop_limpiar_buffer:
          mov [keyboard_buffer_hexa + edx], cl
          inc edx
        cmp edx, 0x09
        jnz loop_limpiar_buffer

        ret

    end_check_keyboard_buffer:
      popad
      ret
