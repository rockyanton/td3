;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++ RUTINA COPY +++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
section .copy
USE32
;--------- Parámetros globales ------------

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL copy

;-----------------------------------------------------------------------------
  ;--------- Levanto los valores de pila ------------
  copy:                 ; Como es una pila, los saco en el orden inverso a como los cargué
    mov ebp, esp        ; Copio el puntero a la pila, para no usarlo directamente
    mov ecx, [ebp + 4]  ; Copio el LARGO
    mov edi, [ebp + 8]  ; Copio el DESTINO
    mov esi, [ebp + 12] ; Copio el ORIGEN

  ;--------- Loop para copia ------------
  ciclo:
    mov al, [esi]     ; La intrucciíon "mov" solo copia de memoria a registro y viceversa.
    mov [edi], al     ; Entonces tengo que traerlo a registro y despues guardarlo
    inc esi           ; Incremento los punteros
    inc edi
    dec ecx           ; Decremento el largo. Cuando llega a cero me levanta el flag de zero
    jne ciclo         ; El jne se fija en el flag de zero
    ret
