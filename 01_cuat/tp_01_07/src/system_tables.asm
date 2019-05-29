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
    dq 0x0    ; Selector de datos
    cs_sel equ $-gdt
    dq 0x0    ; Selector de codigo

    long_gdt equ $-gdt    ; Largo de la gdt

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

     ;dw handler_timer
     ;dw cs_sel
     ;db 0x0
     ;db 0x8E
     ;dw 0xFFFF

section .init
  init_idt:
