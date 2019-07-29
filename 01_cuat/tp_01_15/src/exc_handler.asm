;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx
%define TSS_Lenght  0x270      ; 576 bytes

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++ HANDLERS +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .exc

;--------- Variables externas ------------
EXTERN mostrar_page_fault
EXTERN paginacion_dinamica
EXTERN tarea_actual
EXTERN TSS_simd

;--------- Variables compartidas -----------
GLOBAL exc_handler_000_de
GLOBAL exc_handler_006_ud
GLOBAL exc_handler_007_nm
GLOBAL exc_handler_008_df
GLOBAL exc_handler_013_gp
GLOBAL exc_handler_014_pf

;--------------------------- 0x00 Divide Error -----------------------------------
    exc_handler_000_de:
      pushad              ;  Guardo los registros
      mov edx, 0x0         ; Guardo el número de excepción "0"
      call ISR_Main
      popad               ; Vuelvo a traer los registros
      iret
;------------------------ 0x06 Undefined Opcode ----------------------------------
    exc_handler_006_ud:
      pushad              ; Guardo los registros
      mov edx, 0x06        ; Guardo el número de excepción "6"
      call ISR_Main
      popad               ; Vuelvo a traer los registros
      iret

;-------------------------- 0x07 Device Not Available (No Math Coprocessor) ------
    exc_handler_007_nm:
      pushad                ; Guardo los registros
      mov edx, 0x07          ; Guardo el número de excepción "7"
      clts
      mov eax, [tarea_actual]
      mov ecx, TSS_Lenght
      mul ecx
      fxrstor [TSS_simd + eax]
      popad               ; Vuelvo a traer los registros
      iret

;-------------------------- 0x08 Double Fault ------------------------------------
    exc_handler_008_df:
      pushad                ; Guardo los registros
      mov edx, 0x08          ; Guardo el número de excepción "8"
      call ISR_Main
      popad               ; Vuelvo a traer los registros
      add esp, 4          ; Como el #DF me genera un código de error, lo tengo que sacar antes de retornar
      iret

;----------------------- 0x0D General Protection -----------------------------
    exc_handler_013_gp:
      pushad              ; Guardo los registros
      mov edx, 0x0D        ; Guardo el número de excepción "13"

      mov ebp, esp          ; Copio la esp para no usarla directamente
      mov ecx, [ebp + 0x04*9]  ; Traigo el código de error (los primeros 8 son los registros)
      mov eax, ecx
      and eax, 0x01         ; El primer valor me dice si la excepción fue interna "0" o externa "1"
      mov ebx, ecx
      sar ebx, 1
      and ebx, 0x01         ; El segundo bit me dice si es de la IDT "1" o de la GDT/LDT "0"
      sar ecx, 3
      and ecx, 0x1FFF       ; Los bytes del 15-3 son el número de excepción/interrupción

      call ISR_Main

      popad               ; Vuelvo a traer los registros
      add esp, 4          ; Como el #GP me genera un código de error, lo tengo que sacar antes de retornar
      iret

;-------------------------- 0x14 Page Fault --------------------------------
    exc_handler_014_pf:
      pushad                ; Guardo los registros
      mov edx, 0x0E          ; Guardo el número de excepción "14"

      mov eax, cr2                    ; Treigo el numero de la pagina que generó la excepción
      push eax
      push eax                        ; Lo pusheo a pila
      ;call paginacion_dinamica
      call mostrar_page_fault
      breakpoint
      pop eax
      pop eax

      popad               ; Vuelvo a traer los registros
      add esp, 4          ; Como el #PG me genera un código de error, lo tengo que sacar antes de retornar
      iret

;------------------------------- ISR Main ------------------------------------
    ISR_Main:
      breakpoint
      hlt
      ret
