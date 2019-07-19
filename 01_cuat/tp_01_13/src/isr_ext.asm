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

;------------------------------- IRQ 0 ----------------------------------------
  isr_irq_00_pit:
    pushad
    mov edx, 0x20   ; Interrupción 32

    ; Como el timer solo llega a 10ms, tengo que hacer un contador par contar 10 interrupciones
    xor ebx, ebx          ; Inicializo en 0 el registro
    mov bl, [pit_status]  ; Traigo el contador
    mov cl, bl            ; Copio el valor
    and cl, 0x80          ; Me quedo con el primer bit5 --> PIT Flag
    and bl, 0x0F          ; Me quedo con los primeros 4 bytes --> Contador
    cmp bl, 0xA               ; Me fijo si llegue al final
    jl pit_counter_end
      mov al, [cant_interrupciones]
      inc al
      mov [cant_interrupciones], al   ; Aumento el contador de interrupciones
      mov bl, 0x80          ; levanto el bit 7 --> PIT Flag y pingo el contador en 0
    pit_counter_end:

    inc bl                  ; Incrmento el contador
    or bl, cl               ; Le agrego el flag

    mov [pit_status], bl

    mov al, PIC_EOI
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción

    pit_status:
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
