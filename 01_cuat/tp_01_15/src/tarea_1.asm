;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint    xchg bx,bx
%define system_call   int 0x80
%define td3_halt      0x01
%define td3_read      0x02
%define td3_print     0x03
%define task_end      0x04

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++ TAREA 1 (TEXT) +++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_text progbits

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL tarea_1

  tarea_1:      ; Suma aritmética en quadruple word

    sumar_tabla_loop:
      xor eax, eax
      mov al, [indice_suma_tabla]
      inc eax

      push DWORD 0x00     ; Return
      push eax        ; Indice siguiente
      push DWORD buffer_tarea
      push DWORD td3_read
      system_call
      pop ebx
      pop ebx
      pop ebx
      pop ebx

      cmp ebx, 0x01     ; Si me devuelve 0, es porque no hay nada nuevo
      jnz end_tarea_1
        dec eax   ; Traigo el último dígito
        push DWORD 0x00     ; Return
        push eax        ; Indice siguiente
        push DWORD buffer_tarea
        push DWORD td3_read
        system_call
        pop ebx
        pop ebx
        pop ebx
        pop ebx

        movdqu xmm0, [suma_tabla_digitos]   ; Traigo el resulatdo de la suma acumulado
        movdqu xmm1, [buffer_tarea]         ; Traigo el valor del dato
        paddq  xmm0, xmm1                   ; Los sumo
   	    movdqu  [suma_tabla_digitos], xmm0  ; Guardo la suma
        inc eax
        mov [indice_suma_tabla], al         ; Guardo el indice actualizado

        push DWORD 0x00   ; Return
        push DWORD 0x02   ; 2 bytes
        push DWORD suma_tabla_digitos   ; Que mostrar
        push DWORD td3_print  ; Quiero mostrar
        system_call
        pop eax
        pop eax
        pop eax
        pop eax

        jmp sumar_tabla_loop

      end_tarea_1:
        push DWORD task_end
        system_call
        pop eax

      leer_memoria:
        cmp ebx, 0x00           ; Si la direccion de memoria es mayor a 32 bits, no leoo
        jnz end_leer_memoria
          cmp eax, 0x20000000   ; Me fijo si me pase de los 512 MB
          jge end_leer_memoria
            mov ecx, [eax]      ; Traigo el valor
        end_leer_memoria:
        ret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++ TAREA 1 (DATA RW) ++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_data_rw progbits

;--------- Variables externas ------------

;--------- Variables compartidas -----------


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++ TAREA 1 (BSS) ++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tarea_1_bss nobits

;--------- Variables externas ------------

;--------- Variables compartidas -----------

suma_tabla_digitos:
  resd 2        ; Reservo 8 bytes para guardar la suma (64 bits)
indice_suma_tabla:
  resb 1        ; Indice para saber hasta que digito llegué
buffer_tarea:
  resq 1
