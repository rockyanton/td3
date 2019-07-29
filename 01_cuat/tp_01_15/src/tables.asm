;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ TABLAS DE SISTEMA ++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tablas_de_sistema nobits

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL gdt
GLOBAL ds_sel
GLOBAL cs_sel
GLOBAL idt

;-------------------------------- GDT ---------------------------------------
  gdt:
    resb 8              ; Descriptor nulo
    ds_sel equ $-gdt
    resb 8              ; Selector de datos nulo
    cs_sel equ $-gdt
    resb 8              ; Selector de codigo nulo

    long_gdt equ $-gdt    ; Largo de la gdt vacía

;------------------------------- IDT -----------------------------------------
  idt:
     resb 8*255  ; Reservo las 255 entradas de 8 bytes de la tabla (1024 x 64 bytes)

  long_idt equ $-idt

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++ INICIALIZACIÓN DE TABLAS DE SISTEMA ++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
section .init progbits

;--------- Variables externas ------------
EXTERN exc_handler_000_de
EXTERN exc_handler_006_ud
EXTERN exc_handler_007_nm
EXTERN exc_handler_008_df
EXTERN exc_handler_013_gp
EXTERN exc_handler_014_pf
EXTERN cs_sel_prim
EXTERN isr_irq_00_pit
EXTERN isr_irq_01_keyboard

;--------- Variables compartidas -----------
GLOBAL img_gdtr
GLOBAL init_idt
GLOBAL clear_isr_idt
GLOBAL img_idtr

;------------------------- Inicialización GDT -------------------------------
    img_gdtr:               ; Escribo primero la longitud y luego la GDT
      dw long_gdt - 1       ; dw me agrega 1 byte en cero antes: 0x0017 --- 3 elementos de 8 bytes: 23 -> 0x17
      dd gdt

;------------------------ Inicialización IDT --------------------------------
    img_idtr:
       dw long_idt-1
       dd idt

    init_idt:
      ; Excepcion de división por cero (DE), codigo 0 (0x00)
      push exc_handler_000_de     ; Pusheo el handler
      push 0x00               ; Pusheo el numero de interrupción
      call load_isr_idt   ; LLamo a la función para cargar la IDT
      pop eax                 ; Saco lo que puse en pila
      pop eax

      ; Excepcion de Opcode inválido (UD), codigo 6 (0x06)
      push exc_handler_006_ud
      push 0x06
      call load_isr_idt
      pop eax
      pop eax

      ; Excepcion de Device Not Available (No Math Coprocessor) (nm), codigo 7 (0x07)
      push exc_handler_007_nm
      push 0x07
      call load_isr_idt
      pop eax
      pop eax

      ; Excepcion de Doble Falta (DF), codigo 8 (0x08)
      push exc_handler_008_df
      push 0x08
      call load_isr_idt
      pop eax
      pop eax

      ; Excepcion de General Protection (GP), codigo 13 (0x0D)
      push exc_handler_013_gp
      push 0x0D
      call load_isr_idt
      pop eax
      pop eax

      ; Excepcion de Page Fault (PF), codigo 14 (0x0E)
      push exc_handler_014_pf
      push 0x0E
      call load_isr_idt
      pop eax
      pop eax

      ; Interrupción por Timer (IRQ 0), codigo 32 (0x20)
      push isr_irq_00_pit
      push 0x20
      call load_isr_idt
      pop eax
      pop eax

      ; Interrupción por Teclado (IRQ 1), codigo 33 (0x21)
      push isr_irq_01_keyboard
      push 0x21
      call load_isr_idt
      pop eax
      pop eax

    ret

    load_isr_idt:
      mov esi, idt
      mov ebp, esp        ; Copio el puntero a la pila, para no usarlo directamente
      mov ecx, [ebp + 4]  ; Numero de excepción / interrupción
      mov edi, [ebp + 8]  ; Dirección del handler

      ;  |7|6|5|4|3|2|1|0|  Bit 0 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 0-7 del Offset

      ;  |7|6|5|4|3|2|1|0|  Bit 1 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 8-15 del Offset
      mov [esi + ecx*8],di

      ;  |7|6|5|4|3|2|1|0|  Bit 2 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Selector se segmento (primera parte)

      ;  |7|6|5|4|3|2|1|0|  Bit 3 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Selector se segmento (segunda parte)
      mov ax, cs_sel_prim
      mov [esi + ecx*8 +2], ax

      ;  |7|6|5|4|3|2|1|0|  Bit 4 del descriptor IDT
      ;   | | | `-`-`-`-`---- Reservado
      ;   `-`-`------------- "000"
      mov al, 0x00
      mov [esi + ecx*8 +4], al

      ;  |7|6|5|4|3|2|1|0|  Bit 5 del descriptor IDT
      ;   | | | | | `-`-`---- "110"
      ;   | | | | `--------- D (Size of gate): 1=32bits   0=16bits
      ;   | | | `---------- "0"
      ;   | `-`----------- DPL (Descriptor Privilege Level): 0=SO ... 3:User
      ;   `-------------- P (Segment Present Flag)
      mov al, 0x8E  ;0x8E = 1 00 0 1 110 ==> Segmento Presente, Permisos elevados, tamaño del gate de 32bits
      mov [esi + ecx*8 +5], al

      ;  |7|6|5|4|3|2|1|0|  Bit 6 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 16-23 del Offset

      ;  |7|6|5|4|3|2|1|0|  Bit 7 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 24-31 del Offset
      rol edi,16    ; Lo roto para obtener la parte alta
      mov [esi + ecx*8 +6],di

      ret

    clear_isr_idt:
      mov esi, idt
      mov ebp, esp        ; Copio el puntero a la pila, para no usarlo directamente
      mov edi, [ebp + 4]  ; Numero de excepción / interrupción

      xor ecx, ecx
      mov [esi + edi*8], ecx
      mov [esi + edi*8 + 4], ecx

      ret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ TABLA DE DIGITOS +++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
section .tabla_de_digitos nobits     ; nobits le dice al linker que esa sección va a existir pero que no carge nada (sino me hace un archivo de 4GB)

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL tabla_digitos
GLOBAL puntero_tabla_digitos

;-----------------------------------------------------------------------------
  tabla_digitos:
    resb 63*1024  ; Reservo 63k bytes para tabla
  puntero_tabla_digitos:
    resb 1


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++ TSS DE TAREAS +++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .tablas_de_sistema nobits

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL TSS_eax
GLOBAL TSS_ebx
GLOBAL TSS_ecx
GLOBAL TSS_edx
GLOBAL TSS_edi
GLOBAL TSS_esi
GLOBAL TSS_ebp
GLOBAL TSS_esp
GLOBAL TSS_eip
GLOBAL TSS_eflags
GLOBAL TSS_cs
GLOBAL TSS_ds
GLOBAL TSS_es
GLOBAL TSS_ss

;-------------------------------- TAREA 0 ---------------------------------------

  TSS:
  ; 4 bytes (10): eax, ebx, ecx, edx, edi, esi, ebp, esp, eip, eflags => 40 bytes
  ; 2 bytes (4): cs, ds, es, ss => 8 bytes
  ; Total 48 bytes
  TSS_tarea_0:
    TSS_eax:
      resd 1
    TSS_ebx:
      resd 1
    TSS_ecx:
      resd 1
    TSS_edx:
      resd 1
    TSS_edi:
      resd 1
    TSS_esi:
      resd 1
    TSS_ebp:
      resd 1
    TSS_esp:
      resd 1
    TSS_eip:
      resd 1
    TSS_eflags:
      resd 1
    TSS_cs:
      resw 1
    TSS_ds:
      resw 1
    TSS_es:
      resw 1
    TSS_ss:
      resw 1
  TSS_tarea_1:
    resd 10
    resw 4
  TSS_tarea_2:
    resd 10
    resw 4
