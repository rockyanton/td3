EXTERN __LONGITUD_RUTINAS
EXTERN __INICIO_ROM_RUTINAS
EXTERN __INICIO_RAM_RUTINAS

GLOBAL copy

section .copy
USE32
  copy:
    mov esi, __INICIO_ROM_RUTINAS
    mov edi, __INICIO_RAM_RUTINAS
    mov ecx, __LONGITUD_RUTINAS
  ciclo:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jne ciclo
    ret
