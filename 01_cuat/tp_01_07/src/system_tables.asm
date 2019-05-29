section .tablas_de_sistema nobits

  ;--------- GDT ------------
  GLOBAL gdt
  GLOBAL long_gdt
  GLOBAL img_gdtr
  GLOBAL ds_sel
  GLOBAL cs_sel

  gdt:
    dq 0x0                ; Descriptor nulo
    ds_sel equ $-gdt
    dq 0x0                ; Selector de datos nulo
    cs_sel equ $-gdt
    dq 0x0                ; Selector de codigo nulo

    long_gdt equ $-gdt    ; Largo de la gdt vacía

  img_gdtr:               ; Escribo primero la longitud y luego la GDT
    dw long_gdt - 1       ; dw me agrega 1 byte en cero antes: 0x0017 --- 3 elementos de 8 bytes: 23 -> 0x17
    dd gdt

  ;--------- IDT ------------
  GLOBAL idt

  GLOBAL img_idtr
  idt:
     TIMES 0x255 dq 0x0

  long_idt equ $-idt

  img_idtr:
     dw long_idt-1
     dd idt

section .init
    init_idt:
      ; Excepcion de división por cero (DE), codigo 0
      push handler_de
      push 0x00
      call load_handler_idt
      pop eax
      pop eax

      ; Excepcion de Opcode inválido (UD), codigo 6
      push handler_ud
      push 0x06
      call load_handler_idt
      pop eax
      pop eax

      ; Excepcion de Doble Falta (DF), codigo 8
      push handler_df
      push 0x08
      call load_handler_idt
      pop eax
      pop eax

      ; Excepcion de General Protection (GP), codigo 13
      push handler_gp
      push 0x0D
      call load_handler_idt
      pop eax
      pop eax

    ret


    EXTERN cs_sel_prim

    load_handler_idt:
      mov esi, idt
      mov ebp, esp        ; Copio el puntero a la pila, para no usarlo directamente
      mov ecx, [ebp + 4]  ; Numero de excepción / interrupción
      mov edi, [ebp + 8]  ; Dirección del handler

      ;  |7|6|5|4|3|2|1|0|  Bit 0 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 0-7 del Offset

      ;  |7|6|5|4|3|2|1|0|  Bit 1 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 8-15 del Offset
      mov [esi + ecx*8],si

      ;  |7|6|5|4|3|2|1|0|  Bit 2 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Selector se segmento (primera parte)

      ;  |7|6|5|4|3|2|1|0|  Bit 3 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Selector se segmento (segunda parte)
      mov [esi + ecx*8 +2],cs_sel_prim

      ;  |7|6|5|4|3|2|1|0|  Bit 4 del descriptor IDT
      ;   | | | `-`-`-`-`---- Reservado
      ;   `-`-`------------- "000"
      mov [esi + ecx*8 +4],0x0

      ;  |7|6|5|4|3|2|1|0|  Bit 5 del descriptor IDT
      ;   | | | | | `-`-`---- "110"
      ;   | | | | `--------- D (Size of gate): 1=32bits   0=16bits
      ;   | | | `---------- "0"
      ;   | `-`----------- DPL (Descriptor Privilege Level): 0=SO ... 3:User
      ;   `-------------- P (Segment Present Flag)
      mov [esi + ecx*8 +4],0x8E   ;0x8E = 1 00 0 1 110 ==> Segmento Presente, Permisos elevados, tamaño del gate de 32bits

      ;  |7|6|5|4|3|2|1|0|  Bit 6 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 16-23 del Offset

      ;  |7|6|5|4|3|2|1|0|  Bit 7 del descriptor IDT
      ;   `-`-`-`-`-`-`-`---- Bits 24-31 del Offset
      rol esi,16    ; Lo roto para obtener la parte alta
      mov [esi + ecx*8 +6],si

      ret
