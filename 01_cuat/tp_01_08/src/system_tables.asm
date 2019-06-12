USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16
section .tablas_de_sistema nobits

  ;--------- GDT ------------
  GLOBAL gdt
  GLOBAL ds_sel
  GLOBAL cs_sel

  gdt:
    resb 8              ; Descriptor nulo
    ds_sel equ $-gdt
    resb 8              ; Selector de datos nulo
    cs_sel equ $-gdt
    resb 8              ; Selector de codigo nulo

    long_gdt equ $-gdt    ; Largo de la gdt vacía

  ;--------- IDT ------------
  GLOBAL idt
  idt:
     resb 8*255  ; Reservo las 255 entradas de 8 bytes de la tabla (1024 x 64 bytes)

  long_idt equ $-idt


section .init progbits
  ;--------- Inicialización GDT ------------
  GLOBAL img_gdtr

    img_gdtr:               ; Escribo primero la longitud y luego la GDT
      dw long_gdt - 1       ; dw me agrega 1 byte en cero antes: 0x0017 --- 3 elementos de 8 bytes: 23 -> 0x17
      dd gdt

  ;--------- Inicialización IDT ------------
  GLOBAL init_idt
  GLOBAL clear_isr_idt
  GLOBAL img_idtr
  EXTERN ist_irq_000_de
  EXTERN isr_irq_006_ud
  EXTERN isr_irq_008_df
  EXTERN isr_irq_013_gp
  EXTERN isr_irq_032_pit
  EXTERN isr_irq_033_keyboard

    img_idtr:
       dw long_idt-1
       dd idt

    init_idt:
      ; Excepcion de división por cero (DE), codigo 0 (0x00)
      push ist_irq_000_de     ; Pusheo el handler
      push 0x00               ; Pusheo el numero de interrupción
      call load_isr_idt   ; LLamo a la función para cargar la IDT
      pop eax                 ; Saco lo que puse en pila
      pop eax

      ; Excepcion de Opcode inválido (UD), codigo 6 (0x06)
      push isr_irq_006_ud
      push 0x06
      call load_isr_idt
      pop eax
      pop eax

      ; Excepcion de Doble Falta (DF), codigo 8 (0x08)
      push isr_irq_008_df
      push 0x08
      call load_isr_idt
      pop eax
      pop eax

      ; Excepcion de General Protection (GP), codigo 13 (0x0D)
      push isr_irq_013_gp
      push 0x0D
      call load_isr_idt
      pop eax
      pop eax

    ret

    EXTERN cs_sel_prim

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
