;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

%define MASTER_PIC_8259_CMD_PORT    0x20
%define PIC_EOI                     0x20

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++ HANDLERS +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .isr

;--------- Variables compartidas -----------
GLOBAL isr_irq_00_pit
GLOBAL isr_irq_01_keyboard
GLOBAL isr_system_call

;--------- Variables externas ------------
EXTERN handle_keyboard
EXTERN cambiar_tarea
EXTERN tabla_digitos
EXTERN puntero_tabla_digitos
EXTERN mostrar_digitos
EXTERN tarea_terminada

;------------------------------- IRQ 0 ----------------------------------------
  isr_irq_00_pit:
    pushad
    mov edx, 0x20   ; Interrupción 32

    mov al, PIC_EOI
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que levanté la interrupción

    mov bl, [pit_status]        ; Traigo el contador
    cmp bl, 0x0A                ; Me fijo si llegue al final => Cambio de tarea
    jl continua_tarea

    cambio_de_tarea:
      xor ebx, ebx
      mov [pit_status], bl   ; Pongo el contador en 0
      popad                  ; Traaigo los registros de la tarea vieja
      sti
      call cambiar_tarea

    continua_tarea:
      inc bl                  ; Incrmento el contador
      mov [pit_status], bl    ; Guardo el contador actualizado
      popad
      iret    ; Vuelvo a la tarea

;------------------------------- IRQ 1 ----------------------------------------
  isr_irq_01_keyboard:
    pushad
    mov edx, 0x21   ; Interrupción 33

    call handle_keyboard

    mov al, PIC_EOI
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción

    popad
    iret    ; Vuelvo de la interrupción

;----------------------------- SYSTEM CALL --------------------------------------
    isr_system_call:
      pushad                ; Guardo los registros
      mov edx, 0x80          ; Guardo el número de excepción "128"
      ; Pila PL3
      ; 0:   Tipo de system call
      ; 1:   Dirección del buffer de salida
      ; 2:   Cantidad de bytes / Indice
      ; 3:   Return
      mov esi, esp
      mov ebp, [esi + 0x04*11]    ; Pila PL3
      mov esi, [ebp + 0x04*0]
      cmp esi, 0x01
      je td3_halt
      cmp esi, 0x02
      je td3_read
      cmp esi, 0x03
      je td3_print
      cmp esi, 0x04
      je task_end
      jmp end_system_call

      td3_halt:
        sti
        hlt
        jmp end_system_call

      td3_read:
        mov edi, [ebp + 0x04*1]  ; Buffer
        mov eax, [ebp + 0x04*2]  ; Indice de la tabla
        mov [ebp + 0x04*3], DWORD 0x00   ; Devuelvo 0 si no copié nada
        xor ebx, ebx
        mov bl, [puntero_tabla_digitos]   ; Traigo el indice del último número guardado
        cmp eax, ebx        ; Si el byte que pide es mayor, me voy
        jg end_system_call
          mov ebx, [tabla_digitos + eax*8]  ; Traigo parte baja
          mov [edi], ebx    ; Guardo
          mov ebx, [tabla_digitos + eax*8 + 0x04] ; Traigo parte alta
          mov [edi + 0x04], ebx   ; Guardo
          mov [ebp + 0x04*3], DWORD 0x01   ; Devuelvo 1 si copie algo
          jmp end_system_call

      td3_print:
        mov edi, [ebp + 0x04*1]  ; Buffer
        mov eax, [ebp + 0x04*2]  ; Cant. de bytes
        cmp eax, 0x02     ; Para la rutina necesito 2 bytes, si son mas o menos me voy
        jnz end_system_call
          mov ebx, [edi + 0x04] ; Pusheo parte alta
          push ebx
          mov eax, [edi]        ; Pusheo parte baja
          push eax
          call mostrar_digitos    ; Muestro resultado en pantalla
          pop ecx
          pop ecx
          jmp end_system_call

      task_end:
        popad
        call tarea_terminada

      end_system_call:
        popad               ; Vuelvo a traer los registros
        iret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++++ DATOS ++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .datos nobits

;--------- Variables compartidas -----------

;--------- Variables externas ------------


  pit_status:
  resb 0x00
