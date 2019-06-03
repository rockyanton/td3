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

    handler_de: ; 0x00 Divide Error
      pushad
      xor edx, edx
      mov dx, 0x0
      call handler_main
      popad
      iret

    handler_ud: ; 0x06 Invalid Opcode (Undefined Opcode)
      pushad
      xor edx, edx
      mov dx, 0x06
      call handler_main
      popad
      iret

    handler_df: ; 0x08 Double Fault
      pushad
      xor edx, edx
      mov dx, 0x08
      call handler_main
      popad
      iret

    handler_gp: ; 0x0D General Protection
      pushad
      xor edx, edx
      mov dx, 0x0D
      call handler_main
      popad
      iret

    handler_main:
      breakpoint
      hlt
      ret
