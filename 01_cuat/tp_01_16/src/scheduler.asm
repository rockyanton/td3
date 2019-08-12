;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++++++++++ HANDLERS +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .scheduler

;--------- Variables externas ------------
EXTERN paginar_tareas
EXTERN copy
EXTERN mostrar_tarea
EXTERN tarea_0
EXTERN tarea_1
EXTERN tarea_2
EXTERN TSS_tarea_0
EXTERN TSS_tarea_1
EXTERN TSS_tarea_2
EXTERN TSS_esp0
EXTERN TSS_ss0
EXTERN TSS_cr3
EXTERN TSS_eip
EXTERN TSS_eflags
EXTERN TSS_eax
EXTERN TSS_ebx
EXTERN TSS_ecx
EXTERN TSS_edx
EXTERN TSS_esp
EXTERN TSS_ebp
EXTERN TSS_esi
EXTERN TSS_edi
EXTERN TSS_cs
EXTERN TSS_ds
EXTERN TSS_es
EXTERN TSS_ss
EXTERN TSS_simd
EXTERN TSS_Lenght
EXTERN TSS_Offset_Bitmap
EXTERN TSS_Bitmap
EXTERN __FIN_PILA_NUCLEO_TAREA_0_LIN
EXTERN __FIN_PILA_USUARIO_TAREA_0_LIN
EXTERN directorio_nucleo
EXTERN directorio_0
EXTERN directorio_1
EXTERN directorio_2
EXTERN ds_sel_nucleo
EXTERN cs_sel_nucleo
EXTERN ds_sel_usuario
EXTERN cs_sel_usuario
EXTERN gdt
EXTERN tss_sel_0
EXTERN tss_sel_1
EXTERN tss_sel_2

;--------- Variables compartidas -----------
GLOBAL cambiar_tarea
GLOBAL arrancar_scheduler
GLOBAL tarea_actual
GLOBAL tarea_terminada

;-------------------------------------------------------------
  cambiar_tarea:
    guardar_contexto:
      push eax
      push edi
      mov edi, [tarea_actual]

      call get_TSS

      pop edi

      mov [eax + TSS_ebx], ebx
      mov [eax + TSS_ecx], ecx
      mov [eax + TSS_edx], edx
      pop ebx
      mov [eax + TSS_eax], ebx
      mov [eax + TSS_edi], edi
      mov [eax + TSS_esi], esi
      mov [eax + TSS_ebp], ebp
      ; PILA:
      ; 1- eip ret isr_irq_00_pit / tarea_terminada / start_scheduler
      ; 2- eip ret tarea
      ; 3- cs tarea
      ; 4- eflags tarea
      ; 5- ESP PL3
      ; 6- SS PL3
      pop ebx
      pop ebx
      mov [eax + TSS_eip], ebx
      pop ecx
      mov [eax + TSS_cs], cx
      pop ebx
      mov [eax + TSS_eflags], ebx
      mov [eax + TSS_esp], esp
      mov bx, ds
      mov [eax + TSS_ds], bx
      mov bx, ss
      mov [eax + TSS_ss], bx
      mov bx, es
      mov [eax + TSS_es], bx

      mov ebx, cr0    ; Traigo los registros de control 0
      and ebx, 0x08   ; Chequeo si el bit 3 (Task Switched) está en 1 (Allows saving x87 task context upon a task switch only after x87 instruction used)
      cmp ebx, 0x08
      jnz no_guardo_simd
        fxsave [eax + TSS_simd]  ; Save x87 FPU, MMX Technology, and SSE State
      no_guardo_simd:

      cmp cx, cs_sel_usuario
      jnz no_guardo_pl3
        pop ebx
        mov [eax + TSS_esp], ebx
        pop ebx
        mov [eax + TSS_ss], bx
      no_guardo_pl3:

    cambio_indicadores:

      mov esp, [pila_nucleo]    ; Cargo la pila núcleo, para no tocar la de la tarea
      mov esi, [tarea_actual]
      mov edi, [tarea_futura]
      mov [tarea_actual], edi

      xor ebx, ebx
      mov [tarea_futura], dword 0x00   ; Default: siguiente tarea es la 0

      cmp esi, 0x01   ; Si estaba en la 1, la tarea actual es la 0 y la siguiente la 2
      jnz no_tarea_1
        mov [tarea_futura], dword 0x02
      no_tarea_1:

      cmp esi, 0x02   ; Si estaba en la 2, la tarea actual es la 0 y la siguiente la 1
      jnz no_tarea_2
        mov [tarea_futura], dword 0x01
      no_tarea_2:

    paginar_tarea_futura:

      mov ecx, directorio_0   ; Defaul tarea 0

      cmp edi, 0x01
      jnz no_paginar_1
        mov ecx, directorio_1
      no_paginar_1:

      cmp edi, 0x02
      jnz no_paginar_2
        mov ecx, directorio_2
      no_paginar_2:

      mov cr3, ecx

    cargo_puntero_tss:
      call get_TSS

    cargo_selector_tss:
      xor ebx, ebx
      mov bx, tss_sel_0  ; Defaul tarea 0

      cmp edi, 0x01
      jnz no_tss_1
        mov bx, tss_sel_1
      no_tss_1:

      cmp edi, 0x02
      jnz no_tss_2
        mov bx, tss_sel_2
      no_tss_2:

    chequeo_si_inicializada:
      mov cl, [gdt + ebx + 0x05] ; Byte 5, Acceso
      mov dl, cl
      and dl, 0x02    ; Flag de busy
      and cl, 0xFD
      mov [gdt + ebx + 0x05], cl ; Borro el flag de bussy

      cmp dl, 0x00    ; Si el flag de busy estaba en 0, la tarea arranca de nuevo, sino continúa
      jnz cargo_tss
        call inicializar_tarea

    cargo_tss:
      ltr bx

    cargo_contexto:
      mov cx, [eax + TSS_cs]
      mov bx, cs_sel_nucleo
      cmp cx, bx
      jnz cargo_usuario
      jmp cargo_nucleo

      cargo_nucleo:
        mov esp, [eax + TSS_esp]
        mov bx, [eax + TSS_ss]
        mov ss, bx
        jmp cargo_registros

      cargo_usuario:
        xor ebx, ebx
        mov bx, [eax + TSS_ss]
        push ebx
        mov ebx,  [eax + TSS_esp]
        push ebx
        jmp cargo_registros

    cargo_registros:
      mov ebx, cr0          ; Traigo los registros de control 0
      or ebx, 0x8						; Pongo en 1 el bit 3 (Task Switched): Allows saving x87 task context upon a task switch only after x87 instruction used
      mov cr0, ebx          ; Guardo los cambios
      ;push edi
      ;call mostrar_tarea
      ;pop edi
      mov bx, [eax + TSS_ds]
      mov ds, bx
      mov bx, [eax + TSS_es]
      mov es, bx
      mov ebx, [eax + TSS_ebx]
      mov ecx, [eax + TSS_ecx]
      mov esi, [eax + TSS_esi]
      mov edi, [eax + TSS_edi]
      mov ebp, [eax + TSS_ebp]
      ; PILA:
      ; 1- eip ret tarea
      ; 2- cs tarea
      ; 3- eflags tarea
      ; 4- ESP PL3
      ; 5- SS PL3
      mov edx, [eax + TSS_eflags]
      push edx
      xor edx, edx
      mov dx, [eax + TSS_cs]
      push edx
      mov edx, [eax + TSS_eip]
      push edx
      mov edx, [eax + TSS_eax]
      push edx
      mov edx, [eax + TSS_edx]
      pop eax

    tarea_siguiente:
      iret

;-------------------------------------------------------------
  tarea_terminada:
    add esp, 0x04  ; Para borrar el EIP del call
    mov edi, [tarea_actual]

    xor ebx, ebx
    mov bx, tss_sel_0  ; Defaul tarea 0

    cmp edi, 0x01
    jnz no_fin_1
      mov bx, tss_sel_1
    no_fin_1:

    cmp edi, 0x02
    jnz no_fin_2
      mov bx, tss_sel_2
    no_fin_2:

    mov cl, [gdt + ebx + 0x05] ; Byte 5, Acceso
    and cl, 0xFD
    mov [gdt + ebx + 0x05], cl ; Borro el flag de bussy

    call cambiar_tarea

;-------------------------------------------------------------
  get_TSS:

    cmp edi, 0x01
    jnz no_get_1
      mov eax, TSS_tarea_1
      jmp end_get_TSS
    no_get_1:

    cmp edi, 0x02
    jnz no_get_2
      mov eax, TSS_tarea_2
      jmp end_get_TSS
    no_get_2:

    mov eax, TSS_tarea_0    ; Default Tarea 0

    end_get_TSS:
      ret

;-------------------------------------------------------------
  arrancar_scheduler:
    ;mov [pila_nucleo], esp
    mov [tarea_actual], DWORD 0x00
    mov [tarea_futura], DWORD 0x01
    mov [pila_nucleo], esp
    xor eax, eax    ; Pusheo eip, cs y eflags vacíos
    push eax
    push eax
    push eax
    sti ; Enciendo las interrupciones
    call cambiar_tarea

;-------------------------------------------------------------
  inicializar_tarea:
    mov [eax + TSS_esp], DWORD __FIN_PILA_USUARIO_TAREA_0_LIN    ; Guardo la pila con la posición actualizada (Todas tienen la pila en la misma direccion de memoria)
    mov [eax + TSS_eip], DWORD tarea_0   ; Todas arrancan en la misma posicion de memoria
    mov [eax + TSS_eflags], DWORD 0x202
    mov [eax + TSS_ds], WORD ds_sel_usuario
    mov [eax + TSS_ss], WORD ds_sel_usuario
    mov [eax + TSS_es], WORD ds_sel_usuario
    mov [eax + TSS_cs], WORD cs_sel_usuario
    mov ecx, cr3
    mov [eax + TSS_cr3], ecx
    mov [eax + TSS_esp0], DWORD __FIN_PILA_NUCLEO_TAREA_0_LIN   ; Todas tienen la pila en la misma direccion de memoria
    mov [eax + TSS_ss0], WORD ds_sel_nucleo
    mov [eax + TSS_Offset_Bitmap], WORD TSS_Bitmap

    ret


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++ DATOS +++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------- Parámetros globales ------------
USE32
section .datos nobits

;--------- Parámetros globales ------------

;--------- Variables externas ------------

;--------- Variables compartidas -----------


  tarea_actual:
    resd 1
  tarea_futura:
    resd 1
  pila_nucleo:
    resd 1
