;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ RUTINA TECLADO +++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;--------- Variables externas ------------
EXTERN __INICIO_TABLA_DE_DIGITOS
EXTERN __FIN_TABLA_DE_DIGITOS

;--------- Parámetros globales ------------
GLOBAL rutina_teclado_polling     ; Para poder usar esa etiqueta en otro archivo
section .teclado
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16

  ;--------- Rutina de teclado ------------
  rutina_teclado_polling:
    pushad
    mov esi, __INICIO_TABLA_DE_DIGITOS - 1    ; Tabla donde voy a copiar los datos
    mov edi, esi
    mov ecx, __FIN_TABLA_DE_DIGITOS      ; Final de la tabla

    check_buffer:
      in al, 0x64       ; Leo el puerto 0x64 (Keyboard Controller Status Register)
      and al, 0x01      ; Hago un AND para obtener el bit 0 (Output buffer status)
      cmp al, 0x01      ; Si el bit vale 1 el buffer de salida esta lleno (se puede leer)
    jnz check_buffer    ; Si está vacío sigo esperando

    in al, 0x60         ; Leo el puerto 0x60 (Keyboard Output Buffer Register)
    mov bl, al          ; Copio lo leído en otro registro
    and bl, 0x80        ; Hago un AND para obtener el bit 7 (BRK)
    cmp bl, 0x80        ; Si el bit vale 0 la tecla fue presionada (Make), si es 1 se dejó de presionar (Break)
    jz check_buffer     ; Si la tecla fue presionada vuelvo al principio (detecto cuando se suelta)

      cmp al, 0x1F        ; Si la tecla presionada es "S" me voy
      jz check_exit

      cmp al, 0x0A        ; Comparo si es 0x0A ==> Tecla "9" (los numeros 1-9 son consecutivos)
      jg not_number       ; Si es mayor, no es un número 1-9, analizo si es A-F o 0
        dec al
        dec al
        js check_buffer   ; Si me da negativo es porque  es menor a la Tecla "1" (0x02)
        add al, 0x31      ; Le sumo 0x31 para que se equipare con la tabla ASCII (1 es 0x31)
        jge save_data     ; Si está entre esos 2 valores, es un número => Voy a la funcion para guardarlo
      not_number:

      cmp al, 0x0B        ; Comparo si es la tecla "0"
      jnz not_key_0       ; Si no es sigo
        mov al, 0x30      ; Reemplazo el valor de registro con el caracter ASCII "0"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_0:

      cmp al, 0x1E        ; Comparo si es la tecla "A"
      jnz not_key_a       ; Si no es sigo
        mov al, 0x41      ; Reemplazo el valor de registro con el caracter ASCII "A"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_a:

      cmp al, 0x30        ; Comparo si es la tecla "B"
      jnz not_key_b       ; Si no es sigo
        mov al, 0x42      ; Reemplazo el valor de registro con el caracter ASCII "B"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_b:

      cmp al, 0x2E        ; Comparo si es la tecla "C"
      jnz not_key_c       ; Si no es sigo
        mov al, 0x43      ; Reemplazo el valor de registro con el caracter ASCII "C"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_c:

      cmp al, 0x20        ; Comparo si es la tecla "D"
      jnz not_key_d       ; Si no es sigo
        mov al, 0x44      ; Reemplazo el valor de registro con el caracter ASCII "D"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_d:

      cmp al, 0x12        ; Comparo si es la tecla "E"
      jnz not_key_e       ; Si no es sigo
        mov al, 0x45      ; Reemplazo el valor de registro con el caracter ASCII "E"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_e:

      cmp al, 0x21        ; Comparo si es F
      jnz not_key_f       ; Si no es me sigo
        mov al, 0x46      ; Reemplazo el valor de registro con el caracter ASCII "F"
        jmp save_data     ; Voy a la funcion para guardarlo
      not_key_f:

      jmp check_buffer    ; Si no es ninguno de los anteriores vuelvo a esperar

    save_data:
      cmp edi, ecx        ; Me fijo si estoy en el final del buffer
      jnz check_overflow
        mov edi, esi      ; En ese caso vuelvo al principio
      check_overflow:
      inc edi             ; Incremento el puntero a la tabla
      mov [edi], al       ; Guardo el valor en la tabla
    jmp check_buffer      ; Vuelvo a esperar

    check_exit:
      popad
      ret

section .tabla_de_digitos nobits     ; nobits le dice al linker que esa sección va a existir pero que no carge nada (sino me hace un archivo de 4GB)
  resb 64*1024  ; Reservo Los 64k de la tabla (1024 x 64 bytes)
