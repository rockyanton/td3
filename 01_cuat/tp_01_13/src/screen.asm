;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;----- LA PANTALLA ES DE 80(W)x25(H) (2 bytes por caracter) ------
%define Screen_Row_01 0x0000
%define Screen_Row_02 0x00A0
%define Screen_Row_03 0x0140
%define Screen_Row_04 0x01E0
%define Screen_Row_05 0x0280
%define Screen_Row_06 0x0320
%define Screen_Row_07 0x03C0
%define Screen_Row_08 0x0460
%define Screen_Row_09 0x0500
%define Screen_Row_10 0x05A0
%define Screen_Row_11 0x0640
%define Screen_Row_12 0x06E0
%define Screen_Row_13 0x0780
%define Screen_Row_14 0x0820
%define Screen_Row_15 0x08C0
%define Screen_Row_16 0x0960
%define Screen_Row_17 0x0A00
%define Screen_Row_18 0x0AA0
%define Screen_Row_19 0x0B40
%define Screen_Row_20 0x0BE0
%define Screen_Row_21 0x0C80
%define Screen_Row_22 0x0D20
%define Screen_Row_23 0x0DC0
%define Screen_Row_24 0x0E60
%define Screen_Row_25 0x0F00

%define Offset_Character_Digitos  0x38    ; Caracter 28
%define Offset_Character_Name     0x30    ; Caracter 24
%define Offset_Character_PF       0x38    ; Caracter 28

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
EXTERN __BUFFER_DE_VIDEO_LIN
EXTERN tarea_actual

;--------- Variables compartidas -----------
GLOBAL mostrar_nombre
GLOBAL mostrar_digitos
GLOBAL mostrar_page_fault
GLOBAL mostrar_tarea

    mostrar_digitos:
      pushad

      mov ebp, esp

      mov ecx, [ebp + 0x04*9]         ; Traigo el resulatdo de la suma acumulado
      mov edx, [ebp + 0x04*10]

      ;call limpiar_pantalla

      mov edi, buffer_pantalla_digitos
      xor ebx, ebx     ; Contador de digitos en 0

      guardar_parte_alta:
        rol edx, 0x04    ; Roto para guardar del mas significativo al menos
        mov eax, edx
        and eax, 0x0F
        call convertir_ascii
        mov [edi + ebx], al   ; Guardo en el buffer
        inc ebx
        cmp ebx, 0x08       ; Si llego a los 8 bytes, paso a la parte baja
        jnz guardar_parte_alta

      guardar_parte_baja:
        rol ecx, 0x04    ; Roto para guardar del mas significativo al menos
        mov eax, ecx
        and eax, 0x0F
        call convertir_ascii
        mov [edi + ebx], al   ; Guardo en el buffer
        inc ebx
        cmp ebx, 0x10       ; Si llego a los 16 bytes paso a mostar el digito en pantalla
        jnz guardar_parte_baja

      mov ebp, __BUFFER_DE_VIDEO_LIN     ; Dirección del buffer de video
      add ebp, Screen_Row_12
      add ebp, Offset_Character_Digitos   ; Le agrego un offset para que me aparezca en el medio de la pantalla

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

    mostrar_page_fault:
      pushad
      mov ebp, esp  ; Puntero a pila
      mov ebx, [ebp + 0x04*9] ; Traigo el direccion lineal de error
      mov edi, [ebp + 0x04*10] ; Traigo el cantidad de paginas creadas dinamicamente

      mov ebp, __BUFFER_DE_VIDEO_LIN     ; Dirección del buffer de video
      add ebp, Screen_Row_04
      add ebp, Offset_Character_PF   ; Le agrego un offset para que me aparezca en el medio de la pantalla

      mov cl, Font_Color_White   ; Color del Caracter
      or cl, Font_Background_Red  ; Color del fondo

      ; Pongo en pantalla "PAGE: 0x"
      mov al, ASCII_L
      call imprimir_caracter
      mov al, ASCII_I
      call imprimir_caracter
      mov al, ASCII_N
      call imprimir_caracter
      mov al, ASCII_E
      call imprimir_caracter
      mov al, ASCII_A
      call imprimir_caracter
      mov al, ASCII_R
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_D
      call imprimir_caracter
      mov al, ASCII_I
      call imprimir_caracter
      mov al, ASCII_R
      call imprimir_caracter
      mov al, ASCII_Dot
      call imprimir_caracter
      mov al, ASCII_Colon
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_0
      call imprimir_caracter
      mov al, ASCII_x
      call imprimir_caracter

      mov cl, Font_Color_White   ; Color del Caracter
      or cl, Font_Background_Red  ; Color del fondo

      xor edx, edx

      loop_page_fault:
        rol ebx, 0x04    ; Roto para mostrar del mas significativo al menos
        mov eax, ebx    ; Copio en C
        and eax, 0x0F   ; Me quedo con los 4 bits del hexa
        call convertir_ascii
        call imprimir_caracter
        inc edx
      cmp edx, 0x08       ; Cuando recorro los 8 hexa me voy
      jnz loop_page_fault

      mov ebp, __BUFFER_DE_VIDEO_LIN     ; Dirección del buffer de video
      add ebp, Screen_Row_05
      add ebp, Offset_Character_PF   ; Le agrego un offset para que me aparezca en el medio de la pantalla
      add ebp, 0x04     ; Le pongo un poco mas de offset

      mov al, ASCII_P
      call imprimir_caracter
      mov al, ASCII_A
      call imprimir_caracter
      mov al, ASCII_G
      call imprimir_caracter
      mov al, ASCII_E
      call imprimir_caracter
      mov al, ASCII_S
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_C
      call imprimir_caracter
      mov al, ASCII_R
      call imprimir_caracter
      mov al, ASCII_E
      call imprimir_caracter
      mov al, ASCII_A
      call imprimir_caracter
      mov al, ASCII_T
      call imprimir_caracter
      mov al, ASCII_E
      call imprimir_caracter
      mov al, ASCII_D
      call imprimir_caracter
      mov al, ASCII_Colon
      call imprimir_caracter
      mov al, ASCII_Space
      call imprimir_caracter
      mov al, ASCII_0
      call imprimir_caracter
      mov al, ASCII_x
      call imprimir_caracter

      mov eax, edi
      shr eax, 0x04
      and eax, 0x0F
      call convertir_ascii
      call imprimir_caracter
      mov eax, edi
      and eax, 0x0F
      call convertir_ascii
      call imprimir_caracter

      popad
      ret

;----------------------------------------------------------

  mostrar_tarea:
    pushad

    mov ebp, esp  ; Puntero a pila
    mov eax, [ebp + 0x04*9] ; Traigo tarea actual
    call convertir_ascii
    mov bl, al

    mov ebp, __BUFFER_DE_VIDEO_LIN     ; Dirección del buffer de video
    add ebp, Screen_Row_07
    add ebp, Offset_Character_PF   ; Le agrego un offset para que me aparezca en el medio de la pantalla

    mov cl, Font_Color_White   ; Color del Caracter
    or cl, Font_Background_Green  ; Color del fondo

    ; Pongo en pantalla "CURRENT TASK: "
    mov al, ASCII_C
    call imprimir_caracter
    mov al, ASCII_U
    call imprimir_caracter
    mov al, ASCII_R
    call imprimir_caracter
    mov al, ASCII_R
    call imprimir_caracter
    mov al, ASCII_E
    call imprimir_caracter
    mov al, ASCII_N
    call imprimir_caracter
    mov al, ASCII_T
    call imprimir_caracter
    mov al, ASCII_Space
    call imprimir_caracter
    mov al, ASCII_T
    call imprimir_caracter
    mov al, ASCII_A
    call imprimir_caracter
    mov al, ASCII_S
    call imprimir_caracter
    mov al, ASCII_K
    call imprimir_caracter
    mov al, ASCII_Colon
    call imprimir_caracter
    mov al, ASCII_Space
    call imprimir_caracter

    mov al, bl
    call imprimir_caracter

    popad
    ret


    limpiar_pantalla:
      pushad
      xor esi, esi
      xor eax, eax
      mov ebp, __BUFFER_DE_VIDEO_LIN
      loop_limpiar_pantalla:
        mov [ebp + esi], eax
      inc esi
      cmp esi, 0x03E8  ; Pantalla de 80x25, 2 bytes cada uno = 4000. Limpio de a 4 bytes => Comparo contra 1000 (0x3E8)
      jl loop_limpiar_pantalla
      call mostrar_nombre  ; Vuelvo a escribir mi nombre
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

        cmp al, 0x09    ; Chequeo si es mayor a 9
        jg not_number
          add al, ASCII_0
          ret
        not_number:

        cmp al, 0x0A
        jnz not_value_a
          mov al, ASCII_A
          ret
        not_value_a:

        cmp al, 0x0B
        jnz not_value_b
          mov al, ASCII_B
          ret
        not_value_b:

        cmp al, 0x0C
        jnz not_value_c
          mov al, ASCII_C
          ret
        not_value_c:

        cmp al, 0x0D
        jnz not_value_d
          mov al, ASCII_D
          ret
        not_value_d:

        cmp al, 0x0E
        jnz not_value_e
          mov al, ASCII_E
          ret
        not_value_e:

        cmp al, 0x0F
        jnz not_value_f
          mov al, ASCII_F
          ret
        not_value_f:

        mov al, ASCII_N     ; Default que me ponga N
        ret

;----------------------------------------------------------

    mostrar_nombre:
      pushad

      mov ebp, __BUFFER_DE_VIDEO_LIN          ; Dirección del buffer de video
      add ebp, Screen_Row_01
      add ebp, Offset_Character_Name ; Le agrego un offset para que me aparezca en el medio de la pantalla

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
