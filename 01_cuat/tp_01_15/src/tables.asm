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
GLOBAL ds_sel_nucleo
GLOBAL cs_sel_nucleo
GLOBAL ds_sel_usuario
GLOBAL cs_sel_usuario
GLOBAL tss_gdt

;-------------------------------- GDT ---------------------------------------
  gdt:
    resb 8              ; Descriptor nulo
    ds_sel_nucleo equ $ - gdt
    resb 8              ; Selector de datos nucleo nulo
    cs_sel_nucleo equ $ - gdt
    resb 8              ; Selector de codigo nucleo nulo
    ds_sel_usuario equ $ - gdt
    resb 8              ; Selector de datos usuario nulo
    cs_sel_usuario equ $ - gdt
    resb 8              ; Selector de codigo usuario nulo
    tss_gdt equ $ - gdt
    resb 8              ; Descriptor de la TSS

  long_gdt equ $-gdt    ; Largo de la gdt vacía

;------------------------------- IDT -----------------------------------------
  idt:
     resb 8*255  ; Reservo las 255 entradas de 8 bytes de la tabla (1024 x 64 bytes)

  long_idt equ $-idt

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++ INICIALIZACIÓN DE TABLAS DE SISTEMA ++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .init progbits

;--------- Variables externas ------------
EXTERN copy
EXTERN exc_handler_000_de
EXTERN exc_handler_006_ud
EXTERN exc_handler_007_nm
EXTERN exc_handler_008_df
EXTERN exc_handler_013_gp
EXTERN exc_handler_014_pf
EXTERN isr_irq_00_pit
EXTERN isr_irq_01_keyboard
EXTERN isr_system_call

;--------- Variables compartidas -----------
GLOBAL init_gdt
GLOBAL img_gdtr_rom
GLOBAL cs_sel_nucleo_rom
GLOBAL ds_sel_nucleo_rom
GLOBAL init_idt
GLOBAL clear_isr_idt
GLOBAL img_idtr

;------------------------- Inicialización GDT -------------------------------

    gdt_rom:
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00     ; Descriptor nulo
      ds_sel_nucleo_rom   equ $ - gdt_rom
        db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x92, 0xCF, 0x00     ; Selector de datos del nucleo
      cs_sel_nucleo_rom   equ $ - gdt_rom
        db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x9A, 0xCF, 0x00     ; Selector de código del nucleo
      ds_sel_usuario_rom  equ $ - gdt_rom + 0x03
        db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xF2, 0xCF, 0x00     ; Selector de datos de usuario
      cs_sel_usuario_rom  equ $ - gdt_rom + 0x03
        db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFA, 0xCF, 0x00     ; Selector de código de usuario
      tss_rom             equ $ - gdt_rom
        db 0x00, 0x00, 0x00, 0x00, 0x00, 0x89, 0x40, 0x00     ; Descriptor de TSS

      long_gdt_rom  equ $ - gdt_rom    ; Largo de la gdt

      ;  |7|6|5|4|3|2|1|0|  Byte 0 del descriptor GDT
      ;   `-`-`-`-`-`-`-`---- Bits 0-7 del Límite

      ;  |7|6|5|4|3|2|1|0|  Byte 1 del descriptor GDT
      ;   `-`-`-`-`-`-`-`---- Bits 8-15 del Límite

      ;  |7|6|5|4|3|2|1|0|  Byte 2 del descriptor GDT
      ;   `-`-`-`-`-`-`-`---- Bits 0-7 de la Base del Segmento

      ;  |7|6|5|4|3|2|1|0|  Byte 3 del descriptor GDT
      ;   `-`-`-`-`-`-`-`---- Bits 8-15 de la Base del Segmento

      ;  |7|6|5|4|3|2|1|0|  Byte 4 del descriptor GDT
      ;   `-`-`-`-`-`-`-`---- Bits 16-23 de la Base del Segmento

      ;  |7|6|5|4|3|2|1|0|  Byte 5 del descriptor GDT (Access byte)
      ;   | | | | | | | `---- A (Accessed): Si es "0" el segmento no fue accedido, si es "1" sí. Este bit es puesto a uno por el microprocesador.
      ;   | | | | | | `----- Codigo: R (Readable): Si es "0" no se puede leer  sobre el segmento // Datos: W (Writable): Si es "0" no se puede escribir sobre el segmento
      ;   | | | | | `------ Codigo: C (Conforming): Si es "1" el segmento de código sólo puede ser ejecutado si CPL es mayor que DPL // Datos: ED (Direction): Si es "0" el segmento se expande hacia arriba.
      ;   | | | | `------- E (Executable): Si es "1" es un selector de código, si es "o" es un selector de datos
      ;   | | | `-------- S (Descriptor type): "1" para descriptores de código y datos y "0" para descriptores de sistema
      ;   | `-`--------- DPL (Descriptor Privilege Level): 0=SO ... 3:User
      ;   `------------ P (Segment Present Flag)

      ;  |7|6|5|4|3|2|1|0|  Byte 6 del descriptor GDT
      ;   | | | | `-`-`-`---- Bits 16-19 del Límite
      ;   | | `-`----------- "0"
      ;   | `-`------------ Sz (Size bit): "0" para 16 bits y "1" para 32 bits
      ;   `--------------- Gr (Granularity):  Si es "0" el límite está en bloques de 1B, si es "1" el límite está en bloques de 4 KiB

      ;  |7|6|5|4|3|2|1|0|  Byte 7 del descriptor GDT
      ;   `-`-`-`-`-`-`-`---- Bits 24-31 de la Base

    img_gdtr_rom:               ; Escribo primero la longitud y luego la GDT
      dw long_gdt_rom - 1       ; dw me agrega 1 byte en cero antes: 0x0017 (3 elementos de 8 bytes: 23 -> 0x17)
      dd gdt_rom

    img_gdtr:               ; Escribo primero la longitud y luego la GDT
      dw long_gdt - 1       ; dw me agrega 1 byte en cero antes: 0x0017 --- 3 elementos de 8 bytes: 23 -> 0x17
      dd gdt


    init_gdt:
      ; Copio la GDT a RAM
      push gdt_rom       ; Pusheo ORIGEN
      push gdt            ; Pusheo DESTINO
      push long_gdt_rom  ; Pusheo LARGO
      call copy           ; LLamo a la rutina en RAM
      pop eax             ; Saco los 3 push que hice antes
      pop eax
      pop eax

      ; Cargo el limite y base del descriptor de la TSS
      mov ebp, gdt
      mov eax, TSS
      mov ebx, TSS_Lenght
      mov [ebp + 0x08*5], bx          ; Byte 0 y 1: Límite TSS
      mov [ebp + 0x08*5 + 0x02], ax   ; Byte 2 y 3: Base TSS (0-15)
      rol eax, 16
      mov [ebp + 0x08*5 + 0x04], al   ; Byte 4: Base TSS (16-23)
      mov [ebp + 0x08*5 + 0x07], ah   ; Byte 4: Base TSS (24-31)

      ; Cargo la GDTR con la gdt nueva
      lgdt [cs:img_gdtr]

      ; Cargo los selectores de datos con los nuevos valores
      mov ax, ds_sel_nucleo
      mov ds, ax
      mov ss, ax

    ret


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

      ; Excepcion de System Call (SC), codigo 128 (0x0E)
      push isr_system_call
      push 0x80
      call load_isr_idt
      pop eax
      pop eax

      ; Cargo la IDT
      lidt [cs:img_idtr]

    ret

    load_isr_idt:
      mov esi, idt
      mov ebp, esp        ; Copio el puntero a la pila, para no usarlo directamente
      mov ecx, [ebp + 4]  ; Numero de excepción / interrupción
      mov edi, [ebp + 8]  ; Dirección del handler

      ;  |7|6|5|4|3|2|1|0|  Byte 0 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 0-7 del Offset

      ;  |7|6|5|4|3|2|1|0|  Byte 1 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 8-15 del Offset
      mov [esi + ecx*8],di

      ;  |7|6|5|4|3|2|1|0|  Byte 2 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Selector se segmento (primera parte)

      ;  |7|6|5|4|3|2|1|0|  Byte 3 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Selector se segmento (segunda parte)
      mov ax, cs_sel_nucleo
      mov [esi + ecx*8 +2], ax

      ;  |7|6|5|4|3|2|1|0|  Byte 4 del descriptor IDT
      ;   | | | `-`-`-`-`---- Reservado
      ;   `-`-`------------- "000"
      mov al, 0x00
      mov [esi + ecx*8 +4], al

      ;  |7|6|5|4|3|2|1|0|  Byte 5 del descriptor IDT
      ;   | | | | | `-`-`---- "110"
      ;   | | | | `--------- D (Size of gate): 1=32bits   0=16bits
      ;   | | | `---------- "0"
      ;   | `-`----------- DPL (Descriptor Privilege Level): 0=SO ... 3:User
      ;   `-------------- P (Segment Present Flag)
      mov al, 0x8E  ;0x8E = 1 00 0 1 110 ==> Segmento Presente, Permisos elevados, tamaño del gate de 32bits
      mov [esi + ecx*8 +5], al

      ;  |7|6|5|4|3|2|1|0|  Byte 6 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 16-23 del Offset

      ;  |7|6|5|4|3|2|1|0|  Byte 7 del descriptor IDT
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
section .tablas_de_sistema nobits
USE32
ALIGN 16

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL TSS_esp0
GLOBAL TSS_ss0
GLOBAL TSS_esp2
GLOBAL TSS_ss2
GLOBAL TSS_cr3
GLOBAL TSS_eip
GLOBAL TSS_eflags
GLOBAL TSS_eax
GLOBAL TSS_ebx
GLOBAL TSS_ecx
GLOBAL TSS_edx
GLOBAL TSS_esp
GLOBAL TSS_ebp
GLOBAL TSS_esi
GLOBAL TSS_edi
GLOBAL TSS_cs
GLOBAL TSS_ds
GLOBAL TSS_ss
GLOBAL TSS_simd
GLOBAL TSS_Lenght

;-------------------------------- TAREA 0 ---------------------------------------

  TSS:      ; Total 564 bytes (0x270)

  TSS_tarea_0:
    TSS_Backlink:
      resw 1
    TSS_reservado_1:
      resw 1
    TSS_esp0:
      resd 1
    TSS_ss0:
      resw 1
    TSS_reservado_2:
      resw 1
    TSS_esp1:
      resd 1
    TSS_ss1:
      resw 1
    TSS_reservado_3:
      resw 1
    TSS_esp2:
      resd 1
    TSS_ss2:
      resw 1
    TSS_reservado_4:
      resw 1
    TSS_cr3:
      resd 1
    TSS_eip:
      resd 1
    TSS_eflags:
      resd 1
    TSS_eax:
      resd 1
    TSS_ecx:
      resd 1
    TSS_edx:
      resd 1
    TSS_ebx:
      resd 1
    TSS_esp:
      resd 1
    TSS_ebp:
      resd 1
    TSS_esi:
      resd 1
    TSS_edi:
      resd 1
    TSS_es:
      resw 1
    TSS_reservado_5:
      resw 1
    TSS_cs:
      resw 1
    TSS_reservado_6:
      resw 1
    TSS_ss:
      resw 1
    TSS_reservado_7:
      resw 1
    TSS_ds:
      resw 1
    TSS_reservado_8:
      resw 1
    TSS_fs:
      resw 1
    TSS_reservado_9:
      resw 1
    TSS_gs:
      resw 1
    TSS_reservado_A:
      resw 1
    TSS_ldtr:
      resw 1
    TSS_reservado_B:
      resw 1
    TSS_bit_t:
      resw 1
    TSS_Offset_Bipmap:
      resw 1
    TSS_ajuste:
      resb 8
    TSS_simd:
      resb 512

  TSS_Lenght equ $ - TSS    ; Largo de la TSS

  TSS_tarea_1:
    resb 624

  TSS_tarea_2:
    resb 624
