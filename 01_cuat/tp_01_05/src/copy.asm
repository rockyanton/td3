EXTERN __LONGITUD_RUTINAS       ; Cuando junto todos los módulos el linker script me define el valor
EXTERN __INICIO_ROM_RUTINAS     ; Fuente
EXTERN __INICIO_RAM_RUTINAS     ; Destino

GLOBAL copy     ; Significa que cualquiera lo puede usar

section .copy     ; Instruccion para el linker
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16

  copy:
    mov esi, __INICIO_ROM_RUTINAS
    mov edi, __INICIO_RAM_RUTINAS
    mov ecx, __LONGITUD_RUTINAS

  ciclo:
    mov al, [esi]     ; mov solo copia de memoria a registro y viceversa
    mov [edi], al     ; entonces tengo que traerlo a registro y despues guardarlo
    inc esi           ; Incremento los punteros
    inc edi
    dec ecx
    jne ciclo
    ; Todo esto puede ser reemplazado por "CLD" y "REP MOVSB".
    ret
