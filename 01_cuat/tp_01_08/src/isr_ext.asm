;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++ HANDLERS +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16
section .isr
GLOBAL isr_irq_032_pit
GLOBAL isr_irq_033_keyboard

  isr_irq_032_pit:
    pushad
    breakpoint
    popad
    iret

  isr_irq_033_keyboard:
    pushad
    breakpoint
    popad
    iret
