;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

%define MASTER_PIC_8259_CMD_PORT   0x20

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++ HANDLERS +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16
section .isr

GLOBAL isr_irq_00_pit
GLOBAL isr_irq_01_keyboard

EXTERN handle_keyboard
EXTERN check_keyboard_buffer

  isr_irq_00_pit:
    pushad
    mov edx, 0x20   ; Interrupción 32
    call check_keyboard_buffer
    mov al, 0x20
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción

  isr_irq_01_keyboard:
    pushad
    mov edx, 0x21   ; Interrupción 33
    call handle_keyboard
    mov al, 0x20
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción
