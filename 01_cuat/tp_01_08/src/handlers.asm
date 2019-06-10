;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++ HANDLERS +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16
section .handlers
GLOBAL handler_de
GLOBAL handler_df
GLOBAL handler_gp
GLOBAL handler_ud

  ; 0x00 Divide Error
    handler_de:
      pushad              ;  Guardo los registros
      xor edx, edx        ; Pongo en "0" ebx
      mov dx, 0x0         ; Guardo el número de excepción "0"
      call handler_main
      popad               ; Vuelvo a traer los registros
      iret
  ; 0x00 Divide Error
    handler_ud: ; 0x00 Divide Error
      pushad              ; Guardo los registros
      xor edx, edx        ; Pongo en "0" ebx
      mov dx, 0x06        ; Guardo el número de excepción "6"
      call handler_main
      popad               ; Vuelvo a traer los registros
      iret

  ; 0x08 Double Fault
    handler_df:
      breakpoint
      pushad                ; Guardo los registros
      xor edx, edx          ; Pongo en "0" ebx
      mov dx, 0x08          ; Guardo el número de excepción "8"
      call handler_main
      popad               ; Vuelvo a traer los registros
      add esp, 4          ; Como el #DF me genera un código de error, lo tengo que sacar antes de retornar
      iret

  ; 0x0D General Protection
    handler_gp:
      pushad              ; Guardo los registros
      xor edx, edx        ; Pongo en 0 ebx
      mov dx, 0x0D        ; Guardo el número de excepción "13"

      mov ebp, esp          ; Copio la esp para no usarla directamente
      mov ecx, [ebp + 4*8]  ; Traigo el código de error (los primeros 8 son los registros)
      mov eax, ecx
      and eax, 0x01         ; El primer valor me dice si la excepción fue interna "0" o externa "1"
      mov ebx, ecx
      sar ebx, 1
      and ebx, 0x01         ; El segundo bit me dice si es de la IDT "1" o de la GDT/LDT "0"
      sar ecx, 3
      and ecx, 0x1FFF       ; Los bytes del 15-3 son el número de excepción/interrupción

      call handler_main

      popad               ; Vuelvo a traer los registros
      add esp, 4          ; Como el #GP me genera un código de error, lo tengo que sacar antes de retornar
      iret

    handler_main:
      breakpoint
      ret

    handler_irq_01:
