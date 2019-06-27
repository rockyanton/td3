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

    and al, 0x0F    ; Los primeros 4 bytes son el contador
    mov dl, 0x02
    div dl          ; Divido al por 2 para tener la cantidad de bytes y la parte alta o baja
    xor edx, edx
    mov dl, al      ; Copio los bytes

    inc edx         ; Avanzo 2 bytes
    cmp edx, 0x09       ; Chequeo overflow
    jl no_overflow_ini_1
      xor edx, edx
    no_overflow_ini_1:

    inc edx
    cmp edx, 0x09       ; Chequeo overflow
    jl no_overflow_ini_2
      xor edx, edx
    no_overflow_ini_2:

    xor ecx, ecx
    xor ah, 0x01    ; La parte que necesito es la siguiente

    mov al, 0x00    ; Parte baja o alta de la tabla

    xor ebx, ebx
    mov bl, [puntero_tabla_digitos]
    mov ebp, ebx        ; Copio la posición en la que estoy
    inc ebp
    xor esi, esi        ; Limpio variables

    copio_buffer:
      xor ebx, ebx    ; Limpio ebx
      cmp ah, 0x00
      jz copio_parte_baja
      jmp copio_parte_alta

      copio_parte_baja:
        mov bl, [keyboard_buffer_hexa + edx]
        and bl, 0x0F
        call guardar_en_tabla
        xor ah, 0x01  ; Para poder copiar parte alta en siguiente ciclo
        jmp copio_buffer_check


      copio_parte_alta:
        mov bl, [keyboard_buffer_hexa + edx]
        and bl, 0xF0
        shr bl, 0x04
        call guardar_en_tabla
        inc edx                           ; Cargo siguiente numero para siguiente ciclo
        cmp edx, 0x09                     ; Chequeo overflow
        jl no_overflow_alta
          xor edx, edx
        no_overflow_alta:
        jmp copio_buffer_check

      copio_buffer_check:
        inc cl
        cmp cl, 0x10          ; Me fijo si cargue los 64 bits
        jz copio_buffer_end
        jmp copio_buffer

      copio_buffer_end:
        ; Guardo el puntero actualizado
        mov ecx, esi
        mov [puntero_tabla_digitos], cl
        ; Vacío el buffer de teclado
        call limpiar_buffer_teclado
        ; Saco el flag de enter
        mov al, [keyboard_buffer_status]
        and al, 0x7F
        mov [keyboard_buffer_status], al
        ; Me voy
        jmp end_check_keyboard_buffer


      guardar_en_tabla:
        cmp al, 0x01
        jz guardar_parte_alta
        jmp guardar_parte_baja

        guardar_parte_alta:
          shl bl, 0x04
          mov bh, [tabla_de_digitos + ebp + esi]
          or bl, bh
          mov [tabla_de_digitos + ebp + esi], bl
          xor al, 0x01
          inc esi
          ret

        guardar_parte_baja:
          mov [tabla_de_digitos + ebp + esi], bl
          xor al, 0x01
          ret


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
