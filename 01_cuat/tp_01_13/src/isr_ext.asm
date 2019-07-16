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
GLOBAL pit_flag

;--------- Variables externas ------------
EXTERN handle_keyboard

;------------------------------- IRQ 0 ----------------------------------------
  isr_irq_00_pit:
    pushad
    mov edx, 0x20   ; Interrupción 32

    ; Como el timer solo llega a 10ms, tengo que hacer un contador par contar 10 interrupciones
    xor ebx, ebx          ; Inicializo en 0 el registro
    mov bl, [pit_counter] ; Traigo el contador
    cmp bl, 0x00          ; Me fijo si tiene basura
    jns pit_counter_ok
      xor ebx, ebx        ; Lo inicializo en 0
    pit_counter_ok:

    cmp bl, 0xA               ; Me fijo si llegue al final
    jl pit_counter_end
      mov bl, 0x01
      mov [pit_flag], bl      ; Levanto el flag de clock
      mov bl, [cant_interrupciones]
      inc bl
      mov [cant_interrupciones], bl   ; Aumento el contador de interrupciones
      xor ebx, ebx            ; Lo reseteo a 0
    pit_counter_end:

    inc bl                  ; Incrmento el contador
    mov [pit_counter], bl

    mov al, PIC_EOI
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción

    pit_counter:
    db 0x00
    pit_flag:
    db 0x00
    cant_interrupciones:
    dd 0x00                 ; Guardo la cant de veces que interrumpí

;------------------------------- IRQ 1 ----------------------------------------
  isr_irq_01_keyboard:
    pushad
    mov edx, 0x21   ; Interrupción 33

    call handle_keyboard
    mov al, PIC_EOI
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción
