;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

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
;++++++++++++++++++++++++++ TAREA QUE LEE EL BUFFER ++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1

;--------- Variables externas ------------
EXTERN buffer_circular
EXTERN puntero_buffer
EXTERN tabla_de_digitos

;--------- Variables compartidas -----------
GLOBAL check_keyboard_buffer

  check_keyboard_buffer:
    pushad
    ; Recorro el buffer buscando la tecla enter
    mov edi, buffer_circular    ; Puntero al buffer
    xor edx, edx    ; Limpio registros
    xor eax, eax

    recorrer_buffer:
      mov al, [edi + edx]           ; Traigo los datos de a uno
      cmp al, Keyboard_Key_ENTER    ; Me fijo si es la tecla enter
      jz enter_detectado            ; Si es proceso
      inc edx               ; Incremento el indice
    cmp edx, 0x09           ; Me fijo si ya llegue al final
    jnz recorrer_buffer     ; Sino, me voy

    end_check_keyboard_buffer:
      popad
      ret

    enter_detectado:
      mov esi, edx  ; Copio la posición del enter
      xor ecx, ecx  ; Pongo en 0 ecx
      mov [edi + edx], cl               ; Borro el enter del buffer

      inc esi             ; Primer caracter o número
      cmp esi, 0x09       ; Chequeo overflow
      jl no_overflow_ini
        xor esi, esi
      no_overflow_ini:

      copio_buffer:

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
