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

;--------- Variables externas ------------
EXTERN handle_keyboard
EXTERN cambiar_tarea

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

  pit_status:
  db 0x00

;------------------------------- IRQ 1 ----------------------------------------
  isr_irq_01_keyboard:
    pushad
    mov edx, 0x21   ; Interrupción 33

    call handle_keyboard

    mov al, PIC_EOI
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción

    popad
    iret    ; Vuelvo de la interrupción
