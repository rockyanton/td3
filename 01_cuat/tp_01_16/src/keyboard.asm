;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

%define Keyboard_Controller_Status_Register 0x64
%define Keyboard_Output_Buffer_Register     0x60

%define Keyboard_Key_1  0x02
%define Keyboard_Key_2  0x03
%define Keyboard_Key_3  0x04
%define Keyboard_Key_4  0x05
%define Keyboard_Key_5  0x06
%define Keyboard_Key_6  0x07
%define Keyboard_Key_7  0x08
%define Keyboard_Key_8  0x09
%define Keyboard_Key_9  0x0A
%define Keyboard_Key_0  0x0B
%define Keyboard_Key_A  0x1E
%define Keyboard_Key_B  0x30
%define Keyboard_Key_C  0x2E
%define Keyboard_Key_D  0x20
%define Keyboard_Key_E  0x12
%define Keyboard_Key_F  0x21
%define Keyboard_Key_G  0x22
%define Keyboard_Key_H  0x23
%define Keyboard_Key_I  0x17
%define Keyboard_Key_J  0x24
%define Keyboard_Key_K  0x25
%define Keyboard_Key_L  0x26
%define Keyboard_Key_M  0x32
%define Keyboard_Key_N  0x31
%define Keyboard_Key_O  0x18
%define Keyboard_Key_P  0x19
%define Keyboard_Key_Q  0x10
%define Keyboard_Key_R  0x13
%define Keyboard_Key_S  0x1F
%define Keyboard_Key_T  0x14
%define Keyboard_Key_U  0x16
%define Keyboard_Key_V  0x2F
%define Keyboard_Key_W  0x11
%define Keyboard_Key_X  0x2D
%define Keyboard_Key_Y  0x15
%define Keyboard_Key_Z  0x2C
%define Keyboard_Key_ENTER  0x1C

%define ASCII_0   0x30
%define ASCII_1   0x31
%define ASCII_A   0x41
%define ASCII_B   0x42
%define ASCII_C   0x43
%define ASCII_D   0x44
%define ASCII_E   0x45
%define ASCII_F   0x46

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ RUTINA TECLADO +++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .keyboard

;--------- Variables externas ------------
EXTERN clear_isr_idt
EXTERN tabla_digitos
EXTERN puntero_tabla_digitos

;--------- Variables compartidas -----------
GLOBAL handle_keyboard

;--------- Rutina que llena el buffer de teclado ------------
  handle_keyboard:
    pushad

    xor eax, eax

    check_buffer:
      in al, Keyboard_Controller_Status_Register  ; Leo el puerto 0x64 (Keyboard Controller Status Register)
      and al, 0x01                                ; Hago un AND para obtener el bit 0 (Output buffer status)
      cmp al, 0x01                                ; Si el bit vale 1 el buffer de salida esta lleno (se puede leer)
    jnz handle_key_end                            ; Si está vacío me voy

    in al, Keyboard_Output_Buffer_Register  ; Leo el puerto 0x60 (Keyboard Output Buffer Register)
    mov bl, al                              ; Copio lo leído en otro registro
    and bl, 0x80                            ; Hago un AND para obtener el bit 7 (BRK)
    cmp bl, 0x80                            ; Si el bit vale 0 la tecla fue presionada (Make), si es 1 se dejó de presionar (Break)
    jz handle_key_end                       ; Si la tecla fue presionada me voy (detecto solo cuando se suelta)

  handle_key:

    cmp al, Keyboard_Key_S        ; Si la tecla presionada es "S" me voy
    jz handle_key_end

    cmp al, Keyboard_Key_0  ; Comparo si es la tecla "0"
    jz save_data

    cmp al, Keyboard_Key_1  ; Comparo si es la tecla "1"
    jz save_data

    cmp al, Keyboard_Key_2  ; Comparo si es la tecla "2"
    jz save_data

    cmp al, Keyboard_Key_3  ; Comparo si es la tecla "3"
    jz save_data

    cmp al, Keyboard_Key_4  ; Comparo si es la tecla "4"
    jz save_data

    cmp al, Keyboard_Key_5  ; Comparo si es la tecla "5"
    jz save_data

    cmp al, Keyboard_Key_6  ; Comparo si es la tecla "6"
    jz save_data

    cmp al, Keyboard_Key_7  ; Comparo si es la tecla "7"
    jz save_data

    cmp al, Keyboard_Key_8  ; Comparo si es la tecla "8"
    jz save_data

    cmp al, Keyboard_Key_9  ; Comparo si es la tecla "9"
    jz save_data

    cmp al, Keyboard_Key_A  ; Comparo si es la tecla "A"
    jz save_data

    cmp al, Keyboard_Key_B  ; Comparo si es la tecla "B"
    jz save_data

    cmp al, Keyboard_Key_C  ; Comparo si es la tecla "C"
    jz save_data

    cmp al, Keyboard_Key_D  ; Comparo si es la tecla "D"
    jz save_data

    cmp al, Keyboard_Key_E  ; Comparo si es la tecla "E"
    jz save_data

    cmp al, Keyboard_Key_F  ; Comparo si es la tecla "F"
    jz save_data

    cmp al, Keyboard_Key_Y  ; Comparo si es la tecla "Y"
    jz generate_exc_de

    cmp al, Keyboard_Key_U  ; Comparo si es la tecla "U"
    jz generate_exc_ud

    cmp al, Keyboard_Key_I  ; Comparo si es la tecla "I"
    jz generate_exc_df

    cmp al, Keyboard_Key_O  ; Comparo si es la tecla "O"
    jz generate_exc_gp

    cmp al, Keyboard_Key_ENTER  ; Comparo si es la tecla "Enter"
    jz save_enter

    handle_key_end:
      popad
      ret   ; Vuelvo

;----------------------------------------------------------
    save_data:
      mov edi, keyboard_buffer_hexa
      xor ecx, ecx
      mov cl, [keyboard_buffer_status]
      and cl, 0x1F     ; Los primeros 5 bits son el puntero

      inc ecx
      cmp ecx, 0x12     ; Si estoy en el final del buffer (9 bytes -> 18 (0x12) posiciones) vuelvo a arrancar
      jl no_fin_buffer
        xor ecx, ecx  ; Reinicio ecx
      no_fin_buffer:

      call tecla_a_hexa   ; Convierto el valor de opcode a hexa
      mov ebx, eax        ; Guardo el valor en hexa
      mov eax, ecx        ; Copio el valor del indice
      mov dl, 0x02
      div dl              ; Divido por 2 para saber en byte estoy -- AL: Quotient, AH: Remainder
      xor edx,edx
      mov dl,al           ; Copio el numero de byte

      cmp ah, 0x00        ; Me fijo si tengo que escribir estoy en la parte alta o baja
      jz hexa_alta        ; Empiezo a escribir en la parte alta
      jmp hexa_baja       ; Sigo en la baja

        hexa_baja:
          mov al, [edi + edx]   ; Trago la parte alta
          and al, 0xF0
          or bl, al             ; Uno todo
          mov [edi + edx], bl   ; Guardo el valor en hexa
        jmp end_save_data

        hexa_alta:
          mov al, [edi + edx]   ; Trago la parte baja
          AND al, 0x0F
          shl bl, 0x04          ; Lo muevo hacia la parte alta
          OR bl, al             ; Uno todo
          mov [edi + edx], bl   ; Guardo
        jmp end_save_data

      end_save_data:
      mov ch, [keyboard_buffer_status]
      and ch, 0x80  ; Flag enter
      or cl, ch
      mov [keyboard_buffer_status], cl

      jmp handle_key_end      ; Me voy

;----------------------------------------------------------

    save_enter:
      ;mov al, [keyboard_buffer_status]    ; Levanto el bit 8 del keyboard_buffer_status como flag de enter
      ;or al, 0x80
      ;mov [keyboard_buffer_status], al

      xor eax, eax      ; Limpio registro
      mov al, [keyboard_buffer_status]
      and al, 0x1F    ; Los primeros 5 bytes son el contador
      mov dl, 0x02
      div dl          ; Divido al por 2 para tener la cantidad de bytes (al) y la parte alta o baja (ah)
      xor edx, edx    ; Pongo en 0 edx
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

      xor ebx, ebx
      mov bl, [puntero_tabla_digitos]
      mov ebp, ebx        ; Copio el indice de la tabla del ultimo registro

      xor ecx, ecx        ; Pongo exc en 0 (contador)

      mov al, 0x00        ; Parte baja o alta de la tabla de digitos (guardar)

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
          inc edx                           ; Cambio de byte para siguiente ciclo
          cmp edx, 0x09                     ; Chequeo overflow
          jl no_overflow_baja
            xor edx, edx
          no_overflow_baja:
          jmp copio_buffer_check

        copio_parte_alta:
          mov bl, [keyboard_buffer_hexa + edx]  ; Traigo el byte
          shr bl, 0x04      ; Paso la parte alta a la baja
          and bl, 0x0F
          call guardar_en_tabla
          jmp copio_buffer_check

        copio_buffer_check:
          xor ah, 0x01  ; Para poder copiar parte baja en siguiente ciclo
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

    jmp handle_key_end

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

;----------------------------------------------------------

    limpiar_buffer_teclado:
      xor ecx, ecx
      xor edx, edx

      loop_limpiar_buffer:
        mov [keyboard_buffer_hexa + edx], cl
        inc edx
      cmp edx, 0x09
      jnz loop_limpiar_buffer

      ret

;----------------------------------------------------------

    generate_exc_de:
      pushad                ; Guardo los registros
      xor ebx, ebx          ; Pongo ebx en 0
      div ebx               ; Divido por 0
      popad                 ; Traigo de nuevo los registros
      jmp handle_key_end

;----------------------------------------------------------

    generate_exc_ud:
      ud2                   ; Esta instrucción me genera la excepción
      jmp handle_key_end

;----------------------------------------------------------

    generate_exc_df:
      pushad
      xor ebx, ebx            ; Pongo ebx en 0
      push ebx                ; Pusheo numero de excepcion
      call clear_isr_idt      ; Borro la excepcion de la idt
      div ebx                 ; Divido por 0, como no existe el descriptor en la IDT => ·DF
      popad
      jmp handle_key_end

;----------------------------------------------------------

    generate_exc_gp:
      mov [cs:handle_key_end], eax   ; Trato de escribir en un segmento de código ==> #GP
      jmp handle_key_end

;----------------------------------------------------------

    tecla_a_hexa:
      cmp al, Keyboard_Key_A  ; Comparo si es la tecla "A"
      jnz not_key_a
        mov al, 0x0A
        jmp tecla_en_hexa
      not_key_a:

      cmp al, Keyboard_Key_B  ; Comparo si es la tecla "B"
      jnz not_key_b
        mov al, 0x0B
        jmp tecla_en_hexa
      not_key_b:

      cmp al, Keyboard_Key_C  ; Comparo si es la tecla "C"
      jnz not_key_c
        mov al, 0x0C
        jmp tecla_en_hexa
      not_key_c:

      cmp al, Keyboard_Key_D  ; Comparo si es la tecla "D"
      jnz not_key_d
        mov al, 0x0D
        jmp tecla_en_hexa
      not_key_d:

      cmp al, Keyboard_Key_E  ; Comparo si es la tecla "E"
      jnz not_key_e
        mov al, 0x0E
        jmp tecla_en_hexa
      not_key_e:

      cmp al, Keyboard_Key_F  ; Comparo si es la tecla "F"
      jnz not_key_f
        mov al, 0x0F
        jmp tecla_en_hexa
      not_key_f:

      cmp al, Keyboard_Key_9  ; Comparo si es la tecla "F"
      jg not_number           ; Si es mayor, no es un número 1-9
        dec al
        dec al
        js not_number         ; Si me da negativo es porque  es menor a la Tecla "1" (0x02)
        inc al
        jmp tecla_en_hexa
      not_number:

      mov al, 0x00            ; Si no es ninguno de los anteriores, lo reemplazo por "0"

      tecla_en_hexa:
        ret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ BUFFER DE TECLADO ++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .datos nobits

;--------- Parámetros globales ------------

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL keyboard_buffer_hexa
GLOBAL keyboard_buffer_status

;--------- Buffer y Puntero ------------
  keyboard_buffer_hexa:
    resb 9   ; 9 bytes
  keyboard_buffer_status:
    resb 1
