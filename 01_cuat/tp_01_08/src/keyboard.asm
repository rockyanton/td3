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
;--------- Variables externas ------------
EXTERN __INICIO_TABLA_DE_DIGITOS
EXTERN __FIN_TABLA_DE_DIGITOS
EXTERN clear_isr_idt

;--------- Parámetros globales ------------
USE32
section .keyboard

GLOBAL handle_keyboard     ; Para poder usar esa etiqueta en otro archivo

  ;--------- Rutina de teclado por polling------------
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
    jz save_data

    handle_key_end:
      popad
      ret   ; Vuelvo

;----------------------------------------------------------
    save_data:
      mov edi, buffer_circular
      xor edx, edx
      mov dl, [puntero_buffer]

      cmp edx, 0x00     ; Me fijo si es menor a 0 (el jl me lo toma como valido si es negativo)
      jge puntero_ok
        mov edx, 0x00
      puntero_ok:

      cmp edx, 0x09     ; Si estoy en el final del buffer vuelvo a arrancar
      jl no_fin_buffer
        mov edx, 0x00
      no_fin_buffer:

      mov [edi + edx], al

      inc edx
      mov [puntero_buffer], dl

      jmp handle_key_end      ; Me voy

    generate_exc_de:
      pushad                ; Guardo los registros
      xor ebx, ebx          ; Pongo ebx en 0
      div ebx               ; Divido por 0
      popad                 ; Traigo de nuevo los registros
      jmp handle_key_end

    generate_exc_ud:
      ud2                   ; Esta instrucción me genera la excepción
      jmp handle_key_end

    generate_exc_df:
      pushad
      xor ebx, ebx            ; Pongo ebx en 0
      push ebx                ; Pusheo numero de excepcion
      call clear_isr_idt      ; Borro la excepcion de la idt
      div ebx                 ; Divido por 0, como no existe el descriptor en la IDT => ·DF
      popad
      jmp handle_key_end

    generate_exc_gp:
      mov [cs:handle_key_end], eax   ; Trato de escribir en un segmento de código ==> #GP
      jmp handle_key_end

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++ FUNCION QUE LEE EL BUFFER ++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
      ; Incremento la cant de interrupciones
      mov al, [cant_interrupciones]
      inc al
      mov [cant_interrupciones], al

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


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ TABLA DE DIGITOS +++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
section .tabla_de_digitos nobits     ; nobits le dice al linker que esa sección va a existir pero que no carge nada (sino me hace un archivo de 4GB)
  tabla_de_digitos:
    resb 4  ; Reservo 4 bytes (32 bits)
  cant_interrupciones:
    resb 1   ; Guardo la cant de veces que llené el buffer
  buffer_circular:
    resb 9
  puntero_buffer:
    resb 1
