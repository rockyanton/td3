;section .reset
;arranque:
;db 4
;db 3
;times 16-($-arranque) db 0

;section .init
;db 9
;nop

section .reset
arranque:
  USE 16
  mov ax,0
  jmp ax
  times 16-($-arranque) db 0

section .init
gdt:
  db 0,0,0,0,0,0,0,0 ; Descriptor nulo
  ds_sel equ $-gdt
  db 0xFF,0xFF,0,0,0,0x92,0xCF,0
  cs_sel equ $-gdt
  db 0xFF,0xFF,0,0,0,0x9A,0xCF,0

long_gdt equ $-gdt

img_gdtr:
  ;dw 3*8-1  ; 3 elementos de 8 bytes: 23 -> 0x17
  dw long_dgt-1         ; dw me agrega 1 byte en cero antes: 0x0017
  dd gdt

inicio:
  cli
  db 0x66               ; Requerido para direcciones mayores
  lgdt [cs:img_gdtr]    ;que 0x00FFFFFFF.
  mov eax, cr0          ;Habiltación bit de modo protegido.
  or eax,1
  mov cr0, eax

  jmp dword cs_sel:modo_proteg

use32
modo_proteg:
  mov ax,ds_sel
  mov ds,ax

; jmp $    ; LOOP en la misma instrucción
