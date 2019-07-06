;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;----- LA PANTALLA ES DE 80(W)x25(H) (2 bytes por caracter) ------
%define Offset_Row_Digitos      0x06E0  ; Linea 12
%define Offset_Column_Digitos   0x38    ; Caracter 28

%define Offset_Row_Name      0x00     ; Linea 1
%define Offset_Column_Name   0x30    ; Caracter 24

%define Font_Color_Black        0x00
%define Font_Color_Blue         0x01
%define Font_Color_Green        0x02
%define Font_Color_Cyan         0x03
%define Font_Color_Red          0x04
%define Font_Color_Purple       0x05
%define Font_Color_Brown        0x06
%define Font_Color_Gray         0x07
%define Font_Color_DarkGray     0x08
%define Font_Color_LightBlue    0x09
%define Font_Color_LightGreen   0x0A
%define Font_Color_LightCyan    0x0B
%define Font_Color_LightRed     0x0C
%define Font_Color_LightPurple  0x0D
%define Font_Color_Yellow       0x0E
%define Font_Color_White        0x0F

%define Font_Background_Black        0x00
%define Font_Background_Blue         0x10
%define Font_Background_Green        0x20
%define Font_Background_Cyan         0x30
%define Font_Background_Red          0x40
%define Font_Background_Purple       0x50
%define Font_Background_Brown        0x60
%define Font_Background_Gray         0x70

%define Font_Blink    0x80

%define ASCII_0 0x30
%define ASCII_1 0x31
%define ASCII_2 0x32
%define ASCII_3 0x33
%define ASCII_4 0x34
%define ASCII_5 0x35
%define ASCII_6 0x36
%define ASCII_7 0x37
%define ASCII_8 0x38
%define ASCII_9 0x39
%define ASCII_A 0x41
%define ASCII_B 0x42
%define ASCII_C 0x43
%define ASCII_D 0x44
%define ASCII_E 0x45
%define ASCII_F 0x46
%define ASCII_G 0x47
%define ASCII_H 0x48
%define ASCII_I 0x49
%define ASCII_J 0x4A
%define ASCII_K 0x4B
%define ASCII_L 0x4C
%define ASCII_M 0x4D
%define ASCII_N 0x4E
%define ASCII_O 0x4F
%define ASCII_P 0x50
%define ASCII_Q 0x51
%define ASCII_R 0x52
%define ASCII_S 0x53
%define ASCII_T 0x54
%define ASCII_U 0x55
%define ASCII_V 0x56
%define ASCII_W 0x57
%define ASCII_X 0x58
%define ASCII_Y 0x59
%define ASCII_Z 0x60
%define ASCII_x 0x78
%define ASCII_Colon 0x3A
%define ASCII_Space 0x20
%define ASCII_Dash  0x2D
%define ASCII_Dot   0x2E

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++ RUTINA QUE ESCRIBE EN PANTALLA ++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .screen

;--------- Variables externas ------------
EXTERN suma_tabla_digitos

;--------- Variables compartidas -----------
GLOBAL actualizar_pantalla

    actualizar_pantalla:
      call mostrar_nombre
      call mostrar_digitos
      ret

    mostrar_digitos:
      pushad

      mov ebp, 0x000B8000     ; Dirección del buffer de video
      mov edi, buffer_pantalla_digitos
      xor edx, edx     ; Contador de digitos en 0

      mov esi, 0x04
      mov eax, [suma_tabla_digitos]         ; Traigo el resulatdo de la suma acumulado
      mov ebx, [suma_tabla_digitos + esi]

      guardar_parte_alta:
        rol ebx, 0x04    ; Roto para guardar del mas significativo al menos
        mov ecx, ebx
        and ecx, 0x0F
        call convertir_ascii
        mov [edi + edx], cl   ; Guardo en el buffer
        inc edx
        cmp edx, 0x08       ; Si llego a los 8 bytes, paso a la parte baja
        jnz guardar_parte_alta

      guardar_parte_baja:
        rol eax, 0x04    ; Roto para guardar del mas significativo al menos
        mov ecx, eax
        and ecx, 0x0F
        call convertir_ascii
        mov [edi + edx], cl   ; Guardo en el buffer
        inc edx
        cmp edx, 0x10       ; Si llego a los 16 bytes paso a mostar el digito en pantalla
        jnz guardar_parte_baja

      add ebp, Offset_Row_Digitos     ; Le agrego un offset para que me aparezca en el medio de la pantalla
      add ebp, Offset_Column_Digitos

      mov cl, Font_Color_Red   ; Color del Caracter
      or cl, Font_Background_Green  ; Color del fondo

      ; Pongo en pantalla "Suma:"
      mov al, ASCII_S
      call imprimir_caracter
      mov al, ASCII_U
      call imprimir_caracter
      mov al, ASCII_M
      call imprimir_caracter
      mov al, ASCII_A
      call imprimir_caracter
      mov al, ASCII_Colon
      call imprimir_caracter

      mov cl, Font_Color_Black   ; Color del Caracter
      or cl, Font_Background_Black  ; Color del fondo

      ; Pongo en pantalla un espacio
      mov al, ASCII_Space
      call imprimir_caracter

      mov cl, Font_Color_DarkGray   ; Color del Caracter
      or cl, Font_Background_Cyan  ; Color del fondo

      ; Pongo en pantalla un 0x
      mov al, ASCII_0
      call imprimir_caracter
      mov al, ASCII_x
      call imprimir_caracter

      mov cl, Font_Color_Black   ; Color del Caracter
      or cl, Font_Background_Cyan  ; Color del fondo

      xor edx, edx      ; Contador de digitos en 0

      loop_mostrar:
        mov al , [edi + edx]              ; Traigo el digito del buffer
        call imprimir_caracter
        inc edx
        cmp edx,0x10                      ; Si ya mostre los 16 digitos me voy
        jnz loop_mostrar

      fin_mostrar_digitos:
      popad
      ret

;----------------------------------------------------------

    imprimir_caracter:
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02
      ret

;----------------------------------------------------------

      convertir_ascii:

        cmp cl, 0x09    ; Chequeo si es mayor a 9
        jg not_number
          add cl, ASCII_0
          ret
        not_number:

        cmp cl, 0x0A
        jnz not_value_a
          mov cl, ASCII_A
          ret
        not_value_a:

        cmp cl, 0x0B
        jnz not_value_b
          mov cl, ASCII_B
          ret
        not_value_b:

        cmp cl, 0x0C
        jnz not_value_c
          mov cl, ASCII_C
          ret
        not_value_c:

        cmp cl, 0x0D
        jnz not_value_d
          mov cl, ASCII_D
          ret
        not_value_d:

        cmp cl, 0x0E
        jnz not_value_e
          mov cl, ASCII_E
          ret
        not_value_e:

        cmp cl, 0x0F
        jnz not_value_f
          mov cl, ASCII_F
          ret
        not_value_f:

        mov cl, ASCII_N     ; Default que me ponga N
        ret

;----------------------------------------------------------

    mostrar_nombre:
      pushad

      mov ebp, 0x000B8000          ; Dirección del buffer de video
      add ebp, Offset_Row_Name     ; Le agrego un offset para que me aparezca en el medio de la pantalla
      add ebp, Offset_Column_Name

      mov cl, Font_Color_White   ; Color del Caracter
      or cl, Font_Background_Blue  ; Color del fondo

      ; Pongo en pantalla "RODRIGO ANTON -- LEG.: 144.129-2"
      mov al, ASCII_R
      call imprimir_caracter
      mov al, ASCII_O
      call imprimir_caracter
      mov al, ASCII_D
      call imprimir_caracter
      mov al, ASCII_R
      call imprimir_caracter
      mov al, ASCII_I
      call imprimir_caracter
      mov al, ASCII_G
      call imprimir_caracter
      mov al, ASCII_O
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_A
      call imprimir_caracter
      mov al, ASCII_N
      call imprimir_caracter
      mov al, ASCII_T
      call imprimir_caracter
      mov al, ASCII_O
      call imprimir_caracter
      mov al, ASCII_N
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_Dash
      call imprimir_caracter
      mov al, ASCII_Dash
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_L
      call imprimir_caracter
      mov al, ASCII_E
      call imprimir_caracter
      mov al, ASCII_G
      call imprimir_caracter
      mov al, ASCII_Dot
      call imprimir_caracter
      mov al, ASCII_Colon
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_1
      call imprimir_caracter
      mov al, ASCII_4
      call imprimir_caracter
      mov al, ASCII_4
      call imprimir_caracter
      mov al, ASCII_Dot
      call imprimir_caracter
      mov al, ASCII_1
      call imprimir_caracter
      mov al, ASCII_2
      call imprimir_caracter
      mov al, ASCII_9
      call imprimir_caracter
      mov al, ASCII_Dash
      call imprimir_caracter
      mov al, ASCII_2
      call imprimir_caracter

      popad
      ret

;----------------------------------------------------------
  buffer_pantalla_digitos:
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 16 digitos en total
