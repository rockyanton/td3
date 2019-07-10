;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++ TAREA QUE LEE EL BUFFER (TEXT) +++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_text progbits

;--------- Variables externas ------------
EXTERN keyboard_buffer_hexa
EXTERN keyboard_buffer_status
EXTERN tabla_digitos
EXTERN puntero_tabla_digitos
EXTERN mostrar_digitos

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

    xor ecx, ecx        ; Pongo exc en 0

    mov esi, 0x07       ; Arranca de atras para adelante

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
        mov ecx, ebp        ; Guardo el puntero de byte cargado
        inc ecx             ; Incremento indice (para siguiente ciclo)

        mov [puntero_tabla_digitos], cl
        call limpiar_buffer_teclado       ; Vacío el buffer de teclado

        mov al, [keyboard_buffer_status]  ; Saco el flag de enter
        and al, 0x7F
        mov [keyboard_buffer_status], al

        call sumar_tabla

        call mostrar_digitos  ; Muestro resultado en pantalla

        call leer_memoria

        jmp end_check_keyboard_buffer


      guardar_en_tabla:
        cmp al, 0x00
        jz guardar_parte_alta
        jmp guardar_parte_baja

        guardar_parte_alta:
          shl bl, 0x04        ; Muevo hacia parte alta
          and bl, 0xF0
          mov [tabla_digitos + ebp*8 + esi], bl  ; Guardo
          xor al, 0x01        ; Siguiente ciclo parte baja
          ret

        guardar_parte_baja:
          and bl, 0x0F      ; Me quedo con la parte baja
          mov bh, [tabla_digitos + ebp*8 + esi]    ; Traigo la parte alta
          and bh, 0xF0
          or bl, bh         ; Uno todo
          mov [tabla_digitos + ebp*8 + esi], bl    ; Guardo
          xor al, 0x01      ; Siguiente ciclo parte alta
          dec esi           ; Decremento indice de byte
          ret

      sumar_tabla:

        mov esi, 0x04     ; Para acceder a los 32 otros altos

        mov eax, [suma_tabla_digitos]         ; Traigo el resulatdo de la suma acumulado
        mov ebx, [suma_tabla_digitos + esi]

        mov ecx, [tabla_digitos + ebp*8]        ; Traigo el valor del dato
        mov edx, [tabla_digitos + ebp*8 + esi]

        add eax, ecx
        jc sumar_carry
        jmp sumar_sin_carry

        sumar_carry:
          adc ebx, edx
          jmp guardar_suma

        sumar_sin_carry:
          add ebx, edx
          jmp guardar_suma

        guardar_suma:
          mov [suma_tabla_digitos], eax         ; Guardo el resultado
          mov [suma_tabla_digitos + esi], ebx

        ret ; Vuelvo

      limpiar_buffer_teclado:
        xor ecx, ecx
        xor edx, edx

        loop_limpiar_buffer:
          mov [keyboard_buffer_hexa + edx], cl
          inc edx
        cmp edx, 0x09
        jnz loop_limpiar_buffer

        ret

      leer_memoria:
        cmp ebx, 0x00           ; Si la direccion de memoria es mayor a 32 bits, no leoo
        jnz end_leer_memoria
          cmp eax, 0x20000000   ; Me fijo si me pase de los 512 MB
          jge end_leer_memoria
            mov ecx, [eax]
        end_leer_memoria:
        ret

    end_check_keyboard_buffer:
      popad
      ret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++ TAREA QUE LEE EL BUFFER (DATA RW) +++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_data_rw progbits

;--------- Variables externas ------------

;--------- Variables compartidas -----------


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++ TAREA QUE LEE EL BUFFER (DATA R) +++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_data_r progbits

;--------- Variables externas ------------

;--------- Variables compartidas -----------


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++ TAREA QUE LEE EL BUFFER (BSS) +++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_bss nobits

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL suma_tabla_digitos

suma_tabla_digitos:
  resb 8        ; Reservo 8 bytes para la suma (64 bits)
