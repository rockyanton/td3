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

;-------------------------------------------------------------
  cambiar_tarea:
    guardar_contexto:
      push eax
      push ebx
      mov ebx, [tarea_actual]
      mov eax, TSS_tarea_0   ; Default: Tarea 0

      cmp ebx, 0x01
      jnz no_guardo_tarea_1
        mov eax, TSS_tarea_1
      no_guardo_tarea_1:

      cmp ebx, 0x02
      jnz no_guardo_tarea_2
        mov eax, TSS_tarea_2
      no_guardo_tarea_2:

      pop ebx

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
      pop ebx
      pop ebx
      mov [eax + TSS_eip], ebx
      pop ebx
      mov [eax + TSS_cs], bx
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
      jnz cambio_indicadores
        fxsave [eax + TSS_simd]  ; Save x87 FPU, MMX Technology, and SSE State

    cambio_indicadores:

      mov esi, [tarea_actual]
      mov edi, [tarea_futura]
      mov [tarea_actual], edi

      xor ebx, ebx
      mov [tarea_futura], dword 0x00   ; Default: siguiente tarea es la 0
      mov bx, tss_sel_0

      cmp esi, 0x01   ; Si estaba en la 1, la tarea actual es la 0 y la siguiente la 2
      jnz no_tarea_1
        mov [tarea_futura], dword 0x02
        mov bx, tss_sel_1
      no_tarea_1:

      cmp esi, 0x02   ; Si estaba en la 2, la tarea actual es la 0 y la siguiente la 1
      jnz no_tarea_2
        mov [tarea_futura], dword 0x01
        mov bx, tss_sel_2
      no_tarea_2:

      mov cl, [gdt + ebx + 0x05] ; Byte 5, Acceso
      and cl, 0xFD
      mov [gdt + ebx + 0x05], cl ; Borro el flag de bussy

    paginar_tarea_futura:

      mov ebx, directorio_0   ; Defaul tarea 0

      cmp edi, 0x01
      jnz no_paginar_1
        mov ebx, directorio_1
      no_paginar_1:

      cmp edi, 0x02
      jnz no_paginar_2
        mov ebx, directorio_2
      no_paginar_2:

      mov cr3, ebx

    cargo_puntero_tss:

      cmp edi, 0x00
      jnz no_ini_0
        mov eax, TSS_tarea_0
      no_ini_0:

      cmp edi, 0x01
      jnz no_ini_1
        mov eax, TSS_tarea_1
      no_ini_1:

      cmp edi, 0x02
      jnz no_ini_2
        mov eax, TSS_tarea_2
      no_ini_2:

    chequeo_si_inicializada:

      mov ebx, [eax + TSS_cr3]
      cmp ebx, 0x00
      jnz cargo_tss
        call inicializar_tarea

    cargo_tss:

      mov bx, tss_sel_0  ; Defaul tarea 0

      cmp edi, 0x01
      jnz no_tss_1
        mov bx, tss_sel_1
      no_tss_1:

      cmp edi, 0x02
      jnz no_tss_2
        mov bx, tss_sel_2
      no_tss_2:

      ltr bx

    copiar_contexto:
      mov ebx, cr0          ; Traigo los registros de control 0
      or ebx, 0x8						; Pongo en 1 el bit 3 (Task Switched): Allows saving x87 task context upon a task switch only after x87 instruction used
      mov cr0, ebx          ; Guardo los cambios
      push edi
      ;call mostrar_tarea
      pop edi
      mov bx, [eax + TSS_ss]
      mov ss, bx
      mov bx, [eax + TSS_ds]
      mov ds, bx
      mov ebx, [eax + TSS_ebx]
      mov ecx, [eax + TSS_ecx]
      mov esi, [eax + TSS_esi]
      mov edi, [eax + TSS_edi]
      mov ebp, [eax + TSS_ebp]
      mov esp, [eax + TSS_esp]
      ; PILA:
      ; 3- eip ret tarea
      ; 2- cs tarea
      ; 1- eflags tarea
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
    push dword tarea_terminada  ; Cuando la tarea termine con el ret, quiero que vuelva ahí
    ; PILA:
    ; 3- eip ret tarea
    ; 2- cs tarea
    ; 1- eflags tarea
    pushfd
    xor eax, eax
    mov ax, cs
    push eax
    push dword tarea_0

    call cambiar_tarea

;-------------------------------------------------------------
  arrancar_scheduler:
    mov [pila_nucleo], esp
    mov [tarea_actual], DWORD 0x00
    mov [tarea_futura], DWORD 0x01
    xor eax, eax    ; Pusheo eip, cs y eflags vacíos
    push eax
    push eax
    push eax
    sti ; Enciendo las interrupciones
    call cambiar_tarea

;-------------------------------------------------------------
  inicializar_tarea:
    mov ebp, esp                ; Guardo la pila
    mov esp, __FIN_PILA_USUARIO_TAREA_0_LIN  ; Todas tienen la pila en la misma direccion de memoria
    push DWORD tarea_terminada  ; Cuando la tarea termine con el ret, quiero que vaya ahí
    mov [eax + TSS_esp], esp    ; Guardo la pila con la posición actualizada
    mov esp, ebp                ; Restauro la pila anterior
    mov [eax + TSS_eip], DWORD tarea_0   ; Todas arrancan en la misma posicion de memoria
    pushfd
    pop ecx
    mov [eax + TSS_eflags], ecx
    mov [eax + TSS_ds], WORD ds_sel_nucleo
    mov [eax + TSS_ss], WORD ds_sel_nucleo
    mov [eax + TSS_cs], WORD cs_sel_nucleo
    mov [eax + TSS_es], es
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
  tarea_inicializada:
    resd 1
  pila_nucleo:
    resd 1
