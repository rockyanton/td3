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

  tarea_1:      ; Producto escalar de vectores

    producto_escalar_loop:
      xor eax, eax
      mov al, [indice_tabla]
      inc eax

      push DWORD 0x00     ; Return
      push eax        ; Indice siguiente
      push DWORD vector_1
      push DWORD td3_read
      system_call
      pop ebx
      pop ebx
      pop ebx
      pop ebx

      cmp ebx, 0x01     ; Si me devuelve 0, es porque no hay nada nuevo
      jnz end_tarea_1

        cmp eax, 0x02 ; Si hay menos de 2 vectores me voy
        jl end_producto_escalar_loop

        dec eax   ; Traigo el último vector
        push DWORD 0x00     ; Return
        push eax        ; Indice siguiente
        push DWORD vector_1
        push DWORD td3_read
        system_call
        pop ebx
        pop ebx
        pop ebx
        pop ebx

        dec eax   ; Traigo el vector anterior
        push DWORD 0x00     ; Return
        push eax        ; Indice
        push DWORD vector_2
        push DWORD td3_read
        system_call
        pop ebx
        pop ebx
        pop ebx
        pop ebx

        ; ------- Forma de hacerlo en tamaño double word ----
        ;mov eax, [vector_1]  ; Parte alta -> Parte real
        ;mov ebx, [vector_2]
        ;mul ebx       ; Multiplico ambas partes

        ;mov [escalar_real], eax         ; Parte alta
        ;mov [escalar_real + 0x04], edx  ; Parte baja

        ;mov eax, [vector_1 + 0x04]  ; Parte baka -> Parte imaginaria
        ;mov ebx, [vector_2 + 0x04]
        ;mul ebx       ; Multiplico ambas partes

        ;mov [escalar_imag], eax         ; Parte alta
        ;mov [escalar_imag + 0x04], edx  ; Parte baja

        ;movdqu xmm0, [escalar_real]        ; Traigo ambas multiplicaciones
        ;movdqu xmm1, [escalar_imag]
        ;paddq  xmm0, xmm1                   ; Las sumo
        ; ------- Forma de hacerlo en tamaño word ----
        xor ebx, ebx                ; Pongo ebx en 0

        mov ax, [vector_1 + 0x04]   ; Traigo los datos de la parte imaginaria
        mov [vector_1 + 0x02], ax   ; Lo coloco en el segundo word
        mov [vector_1 + 0x04], ebx  ; Limpio segundo double word

        mov ax, [vector_2 + 0x04]   ; Traigo los datos de la parte imaginaria
        mov [vector_2 + 0x02], ax   ; Lo coloco en el segundo word
        mov [vector_2 + 0x04], ebx  ; Limpio segundo double word

        movdqu xmm0, [vector_1]     ; Parte alta -> Parte real
        movdqu xmm1, [vector_2]     ; Parte baja -> Parte imaginaria



        pmaddwd xmm0, xmm1          ; Esta instrucción me hace el producto escalar (suma y multiplica)
        ;----------------------------------------------

   	    movdqu  [producto_escalar], xmm0  ; Guardo la suma

        inc eax
        mov [indice_tabla], al         ; Guardo el indice actualizado

        push DWORD 0x00   ; Return
        push DWORD 0x02   ; 2 bytes
        push DWORD producto_escalar   ; Que mostrar
        push DWORD td3_print  ; Quiero mostrar
        system_call
        pop eax
        pop eax
        pop eax
        pop eax

        jmp producto_escalar_loop

      end_producto_escalar_loop:
        mov [indice_tabla], al         ; Guardo el indice actualizado

      end_tarea_1:
        push DWORD task_end
        system_call
        pop eax

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

vector_1:
  resd 2        ; Reservo 8 bytes para guardar la suma (64 bits)
vector_2:
  resd 2        ; Reservo 8 bytes para guardar la suma (64 bits)
escalar_real:
  resd 2
escalar_imag:
  resd 2
producto_escalar:
  resd 2
indice_tabla:
  resb 1        ; Indice para saber hasta que digito llegué
