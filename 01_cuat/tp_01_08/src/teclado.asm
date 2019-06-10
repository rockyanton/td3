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
EXTERN clear_handler_idt

;--------- Parámetros globales ------------
USE32
section .keyboard

GLOBAL rutina_teclado_polling     ; Para poder usar esa etiqueta en otro archivo

  ;--------- Rutina de teclado por polling------------
  rutina_teclado_polling:
    pushad
    mov esi, __INICIO_TABLA_DE_DIGITOS   ; Tabla donde voy a copiar los datos
    mov ecx, __FIN_TABLA_DE_DIGITOS      ; Final de la tabla
    mov edi, esi
    xor eax, eax

    check_buffer:
      in al, Keyboard_Controller_Status_Register  ; Leo el puerto 0x64 (Keyboard Controller Status Register)
      and al, 0x01                                ; Hago un AND para obtener el bit 0 (Output buffer status)
      cmp al, 0x01                                ; Si el bit vale 1 el buffer de salida esta lleno (se puede leer)
    jnz check_buffer                              ; Si está vacío sigo esperando

    in al, Keyboard_Output_Buffer_Register  ; Leo el puerto 0x60 (Keyboard Output Buffer Register)
    mov bl, al                              ; Copio lo leído en otro registro
    and bl, 0x80                            ; Hago un AND para obtener el bit 7 (BRK)
    cmp bl, 0x80                            ; Si el bit vale 0 la tecla fue presionada (Make), si es 1 se dejó de presionar (Break)
    jz check_buffer                         ; Si la tecla fue presionada vuelvo al principio (detecto cuando se suelta)

    push edi            ; Pongo en la pila el lugar donde lo debería guardar
    push eax            ; Pongo en la pila el registro con la tecla presionada
    call handle_key     ; Llamo a la funcion que analiza la tecla

    pop eax             ; Traigo el valor que devolvió
    pop ebx             ; Saco el otro valor

    cmp eax, 0x00       ; Valor "0": Fin del programa
    jnz no_exit_key
      popad             ; Traigo los registros originales
      ret               ; Termino
    no_exit_key:

    cmp eax, 0x02         ; Valor "2": Tecla hexadecimal presionada (guardado en tabla)
    jnz no_caracter_hexa
      cmp edi, ecx        ; Me fijo si estoy en el final del buffer
      jnz check_overflow
        mov edi, esi      ; En ese caso vuelvo al principio
        dec edi           ; Decremento el valor, porque lo voy a incrementar y dejar en 0.
      check_overflow:
      inc edi             ; Incremento el puntero a la tabla
    no_caracter_hexa:

    jmp check_buffer    ; Vuelvo a arrancar

  handle_key:
    pushad
    mov ebp, esp
    mov eax,[ebp + 4*9] ; Son los 8 registros más la dirección de retorno

    mov ebx, 0x1     ; Valor "1": Tela presionada, no guardo datos

    cmp al, Keyboard_Key_S        ; Si la tecla presionada es "S" me voy
    jnz no_key_s
      xor ebx, ebx                ; Valor "0": Fin del programa
      jmp handle_key_end
    no_key_s:

    cmp al, Keyboard_Key_9  ; Comparo si es 0x0A ==> Tecla "9" (los numeros 1-9 son consecutivos)
    jg not_number           ; Si es mayor, no es un número 1-9, analizo si es A-F o 0
      dec al
      dec al
      js handle_key_end     ; Si me da negativo es porque  es menor a la Tecla "1" (0x02)
        add al, ASCII_1     ; Le sumo 0x31 para que se equipare con la tabla ASCII (1 es 0x31)
        jge save_data       ; Si está entre esos 2 valores, es un número => Voy a la funcion para guardarlo
    not_number:

    cmp al, Keyboard_Key_0  ; Comparo si es la tecla "0"
    jnz not_key_0           ; Si no es sigo
      mov al, ASCII_0       ; Reemplazo el valor de registro con el caracter ASCII "0"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_0:

    cmp al, Keyboard_Key_A  ; Comparo si es la tecla "A"
    jnz not_key_a           ; Si no es sigo
      mov al, ASCII_A       ; Reemplazo el valor de registro con el caracter ASCII "A"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_a:

    cmp al, Keyboard_Key_B  ; Comparo si es la tecla "B"
    jnz not_key_b           ; Si no es sigo
      mov al, ASCII_B       ; Reemplazo el valor de registro con el caracter ASCII "B"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_b:

    cmp al, Keyboard_Key_C  ; Comparo si es la tecla "C"
    jnz not_key_c           ; Si no es sigo
      mov al, ASCII_C       ; Reemplazo el valor de registro con el caracter ASCII "C"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_c:

    cmp al, Keyboard_Key_D  ; Comparo si es la tecla "D"
    jnz not_key_d           ; Si no es sigo
      mov al, ASCII_D       ; Reemplazo el valor de registro con el caracter ASCII "D"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_d:

    cmp al, Keyboard_Key_E  ; Comparo si es la tecla "E"
    jnz not_key_e           ; Si no es sigo
      mov al, ASCII_E       ; Reemplazo el valor de registro con el caracter ASCII "E"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_e:

    cmp al, Keyboard_Key_F  ; Comparo si es F
    jnz not_key_f           ; Si no es me sigo
      mov al, ASCII_F       ; Reemplazo el valor de registro con el caracter ASCII "F"
      jmp save_data         ; Voy a la funcion para guardarlo
    not_key_f:

    cmp al, Keyboard_Key_Y  ; Comparo si es Y (#DE)
    jnz not_key_y           ; Si no es me sigo
      pushad                ; Guardo los registros
      xor ebx, ebx          ; Pongo ebx en 0
      div ebx               ; Divido por 0
      popad                 ; Traigo de nuevo los registros
      jmp handle_key_end
    not_key_y:

    cmp al, Keyboard_Key_U  ; Comparo si es U (#UD)
    jnz not_key_u           ; Si no es me sigo
      ud2                   ; Esta instrucción me genera la excepción
      jmp handle_key_end
    not_key_u:

    cmp al, Keyboard_Key_I    ; Comparo si es I (#DF)
    jnz not_key_i             ; Si no es me sigo
      pushad
      xor ebx, ebx            ; Pongo ebx en 0
      push ebx                ; Pusheo numero de excepcion
      call clear_handler_idt  ; Borro la excepcion de la idt
      div ebx                 ; Divido por 0, como no existe el descriptor en la IDT => ·DF
      popad
      jmp handle_key_end
    not_key_i:

    cmp al, Keyboard_Key_O      ; Comparo si es O (#GP)
    jnz not_key_o               ; Si no es me sigo
      mov [cs:not_key_o], eax   ; Trato de escribir en un segmento de código ==> #GP
      jmp handle_key_end
    not_key_o:

    handle_key_end:
      mov [ebp + 4*9], ebx ; Guardo el valor de retorno. ebp + los 8 registros más la dirección de retorno
      popad
      ret   ; Vuelvo

    save_data:
      mov [edi], al       ; Guardo el valor en la tabla
      mov ebx, 0x02       ; Valor "2": Tecla hexadecimal presionada (guardado en tabla)
    jmp handle_key_end    ; Vuelvo a esperar

section .tabla_de_digitos nobits     ; nobits le dice al linker que esa sección va a existir pero que no carge nada (sino me hace un archivo de 4GB)
  resb 64*1024  ; Reservo Los 64k de la tabla (1024 x 64 bytes)
