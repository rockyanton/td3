GLOBAL copy     ; Significa que cualquiera lo puede usar

section .copy     ; Instruccion para el linker
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16

  copy:
    mov ebp, esp
    mov ecx, [ebp + 4]
    mov edi, [ebp + 8]
    mov esi, [ebp + 12]

  ciclo:
    mov al, [esi]     ; mov solo copia de memoria a registro y viceversa
    mov [edi], al     ; entonces tengo que traerlo a registro y despues guardarlo
    inc esi           ; Incremento los punteros
    inc edi
    dec ecx           ; Cuando llega a cero me levanta el flag de zero
    jne ciclo         ; El jne se fija en el flag de zero
    ret
