section .handlers

    handler_de:
      pushad
      push dw 0x0
      call save_exception
      popad
      iret

    handler_ud:
      iret

    handler_df:
      iret

    handler_gp:
      iret

    save_exception:
      mov ebp, esp        ; Copio el pintero a la pila, para no usarlo directamente
      mov ecx, [ebp + 4]  ; Saco el número de excepcion
