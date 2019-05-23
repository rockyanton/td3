section .tablas_de_sistema

  ;--------- GDT ------------
  GLOBAL img_gdtr
  GLOBAL ds_sel
  GLOBAL cs_sel

  gdt:
    db 0,0,0,0,0,0,0,0                ; Descriptor nulo
    ds_sel equ $-gdt
    db 0xFF,0xFF,0,0,0,0x92,0xCF,0    ; Selector de datos
    cs_sel equ $-gdt
    db 0xFF,0xFF,0,0,0,0x9A,0xCF,0    ; Selector de codigo

    long_gdt equ $-gdt    ; Largo de la gdt

  img_gdtr:               ; Escribo primero la longitud y luego la GDT
    dw long_gdt - 1       ; dw me agrega 1 byte en cero antes: 0x0017 (3 elementos de 8 bytes: 23 -> 0x17)
    dd gdt

  ;--------- IDT ------------
