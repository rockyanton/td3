;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;----- LA PANTALLA ES DE 80(W)x25(H) (2 bytes por caracter) ------
%define Offset_Row_Digitos      0x780   ; Linea 12
%define Offset_Column_Digitos   0x38    ; Caracter 28

%define FontColor     0x07

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
%define ASCII_Dos_Puntos 0x3A

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
      jmp mostrar_digitos

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

      mov cl, FontColor   ; Color del digito y fondo

      add ebp, Offset_Row_Digitos     ; Le agrego un offset para que me aparezca en el medio de la pantalla
      add ebp, Offset_Column_Digitos

      ; Pongo en pantalla Suma:
      mov al, ASCII_S
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02
      mov al, ASCII_U
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02
      mov al, ASCII_M
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02
      mov al, ASCII_A
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02
      mov al, ASCII_Dos_Puntos
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02

      ; Espacio
      add ebp, 0x02

      ; Pongo en pantalla un 0x
      mov al, ASCII_0
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02
      mov al, ASCII_x
      mov [ebp], al
      mov [ebp + 0x01], cl
      add ebp, 0x02

      xor edx, edx      ; Contador de digitos en 0

      loop_mostrar:
        mov al , [edi + edx]              ; Traigo el digito del buffer
        mov [ebp + edx*2], al             ; Lo guardo en el buffer de video
        mov [ebp + edx*2 + 0x01], cl      ; Guardo el color del digito y fondo
        inc edx
        cmp edx,0x10                      ; Si ya mostre los 16 digitos me voy
        jnz loop_mostrar

      fin_mostrar_digitos:
      popad
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
  buffer_pantalla_digitos:
    db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; 16 digitos en total
