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

    ; Como el timer solo llega a 10ms, tengo que hacer un contador par contar 10 interrupciones
    xor ebx, ebx          ; Inicializo en 0 el registro
    mov bl, [pit_counter] ; Traigo el contador
    cmp bl, 0x00          ; Me fijo si tiene basura
    jns pit_counter_ok
      xor ebx, ebx        ; Lo inicializo en 0
    pit_counter_ok:

    cmp bl, 0xA               ; Me fijo si llegue al final
    jl pit_counter_end
      call check_keyboard_buffer
      xor ebx, ebx            ; Lo reseteo a 0
    pit_counter_end:

    inc bl                  ; Incrmento el contador
    mov [pit_counter], bl

    mov al, 0x20
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción

    pit_counter:
    db 0x00

  isr_irq_01_keyboard:
    pushad
    mov edx, 0x21   ; Interrupción 33
    call handle_keyboard
    mov al, 0x20
    out MASTER_PIC_8259_CMD_PORT, al   ; Le aviso al PIC que ya levanté la interrupción
    popad
    iret    ; Vuelvo de la interrupción
