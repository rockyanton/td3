;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++ RUTINA TECLADO +++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;--------- Parámetros globales ------------
GLOBAL rutina_teclado     ; Para poder usar esa etiqueta en otro archivo
section .teclado
USE32       ; Le tengo que forzar a que use 32 bits porque arranca por defecto en 16

  ;--------- Rutina de teclado ------------
  rutina_teclado:
    breakpoint
    ret
