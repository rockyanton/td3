;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++ TAREA 2 (TEXT) +++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_2_text progbits

;--------- Variables externas ------------
EXTERN tabla_digitos
EXTERN puntero_tabla_digitos
EXTERN mostrar_digitos

;--------- Variables compartidas -----------
GLOBAL tarea_2

  tarea_2:        ; Suma aritmética en word
    pushad
      mov al, [indice_suma_tabla]
      mov ah, [puntero_tabla_digitos]
      cmp al, ah          ; Si ambos punteros son iguales, no hubo cambios, me voy
      jz end_tarea_2
        xor ebx, ebx
        mov bl, al        ; Copio el indice del ultimo digito que tengo registrado
        mov ebp, ebx
        dec ebp           ; Lo decremento porque lo vuelvo a incrementar en el loop
        mov bl, ah        ; Copio el indice del ultimo digito en la tabla
        mov edi, ebx

        sumar_tabla_loop:
          inc ebp
          movdqu xmm0, [suma_tabla_digitos]
          movdqu xmm1, [tabla_digitos + ebp*8]
          paddw  xmm0, xmm1
        	movdqu  [suma_tabla_digitos], xmm0

        cmp ebp, edi            ; Si no son iguales los punteros itero
        jnz sumar_tabla_loop

        mov ecx, ebp    ; Guardo el valor de puntero actualizado
        mov [indice_suma_tabla], cl

        mov ebx, [suma_tabla_digitos + 0x04]  ; Traigo el resultado
        push ebx
        mov eax, [suma_tabla_digitos]
        push eax
        call mostrar_digitos    ; Muestro resultado en pantalla
        pop ecx
        pop ecx

        ;call leer_memoria

      end_tarea_2:
        popad
        ret

      leer_memoria:
        cmp ebx, 0x00           ; Si la direccion de memoria es mayor a 32 bits, no leoo
        jnz end_leer_memoria
          cmp eax, 0x20000000   ; Me fijo si me pase de los 512 MB
          jge end_leer_memoria
            mov ecx, [eax]      ; Traigo el valor
        end_leer_memoria:
        ret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++ TAREA 2 (DATA RW) ++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_2_data_rw progbits

;--------- Variables externas ------------

;--------- Variables compartidas -----------


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++ TAREA 2 (BSS) ++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_2_bss nobits

;--------- Variables externas ------------

;--------- Variables compartidas -----------

suma_tabla_digitos:
  resd 2        ; Reservo 8 bytes para guardar la suma (64 bits)
indice_suma_tabla:
  resb 1        ; Indice para saber hasta que digito llegué
