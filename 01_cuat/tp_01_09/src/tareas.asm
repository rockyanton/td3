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
    mov esi, eax    ; Guardo el valor del buffer
    div byte 0x02   ; Divido al por 2 para tener la cantidad de bytes y la parte alta o baja
    mov edi, [keyboard_buffer_hexa]    ; Puntero al buffer
    xor edx, edx
    mov dl, al

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

    xor ah, 0x01    ; La parte que necesito es la siguiente
    xor ecx, ecx    ; Pongo ecx en 0

    copio_buffer:
      cmp ah, 0x00
      jz copio_parte_baja
      jmp copio_parte_alta

      copio_parte_baja:
        mov bl, [keyboard_buffer_hexa + edx]
        and bl, 0x0F
        ;; COPIAR A DATOS
        inc ecx
        xor ah, 0x01  ; Para poder copiar parte alta en siguiente ciclo


      copio_parte_alta:
        mov bl, [keyboard_buffer_hexa]
        and bl, 0xF0

        inc edx                           ; Cargo siguiente numero para siguiente ciclo
        cmp edx, 0x09                     ; Chequeo overflow
        jl no_overflow_alta
          xor edx, edx
        no_overflow_alta:









        mov al, [edi + esi]               ; Extraigo el caracter
        mov [edi + esi], byte 0x00        ; Lo borro en el buffer
        call tecla_a_hexa                 ; Lo paso a hexa
        mov bl, al                        ; Lo Muevo 4 posiciones (parte 1 del byte)
        shl bl, 0x04

        inc esi                           ; Siguiente numero
        cmp esi, 0x09                     ; Chequeo overflow
        jl no_overflow_2
          xor esi, esi
        no_overflow_2:

        mov al, [edi + esi]               ; Extraigo el caracter
        mov [edi + esi], byte 0x00        ; Lo borro en el buffer
        call tecla_a_hexa                 ; Lo paso a hexa

        or al, bl                         ; Combino los valores
        mov [tabla_de_digitos + ecx], al  ; Lo guardo en la tabla
        inc ecx

        inc esi                           ; Siguiente numero
        cmp esi, 0x09                     ; Chequeo overflow
        jl no_overflow_1
          xor esi, esi
        no_overflow_1:

      cmp esi, edx          ; Me fijo si ya pegue la vuelta
      jnz copio_buffer      ; Sino, me voy

      breakpoint

      jmp end_check_keyboard_buffer   ; Me voy


    end_check_keyboard_buffer:
      popad
      ret
