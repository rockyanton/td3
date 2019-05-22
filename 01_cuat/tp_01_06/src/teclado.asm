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
GLOBAL rutina_teclado     ; Para poder usar esa etiqueta en otro archivo
section .teclado
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16

  ;--------- Rutina de teclado ------------
  rutina_teclado:
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
      jnz check_exit
        ret
      check_exit:

      cmp al, 0x02        ; Comparo si es 1
      jz save_data
      cmp al, 0x03        ; Comparo si es 2
      jz save_data
      cmp al, 0x04        ; Comparo si es 3
      jz save_data
      cmp al, 0x05        ; Comparo si es 4
      jz save_data
      cmp al, 0x06        ; Comparo si es 5
      jz save_data
      cmp al, 0x07        ; Comparo si es 6
      jz save_data
      cmp al, 0x08        ; Comparo si es 7
      jz save_data
      cmp al, 0x09        ; Comparo si es 8
      jz save_data
      cmp al, 0x0A        ; Comparo si es 9
      jz save_data
      cmp al, 0x0B        ; Comparo si es 0
      jz save_data
      cmp al, 0x1E        ; Comparo si es A
      jz save_data
      cmp al, 0x30        ; Comparo si es B
      jz save_data
      cmp al, 0x2E        ; Comparo si es C
      jz save_data
      cmp al, 0x20        ; Comparo si es D
      jz save_data
      cmp al, 0x12        ; Comparo si es E
      jz save_data
      cmp al, 0x21        ; Comparo si es F
      jz save_data

      jmp check_buffer

      save_data:
        cmp edi, ecx        ; Me fijo si estoy en el final del buffer
        jnz check_overflow
          mov edi, esi      ; En ese caso vuelvo al principio
        check_overflow:
        inc edi             ; Incremento el puntero a la tabla
        mov [edi], al       ; Guardo el valor en la tabla
      jmp check_buffer
