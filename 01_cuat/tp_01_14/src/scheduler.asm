;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx
%define TSS_Lenght  0x240      ; 576 bytes

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
EXTERN TSS_eax
EXTERN TSS_ebx
EXTERN TSS_ecx
EXTERN TSS_edx
EXTERN TSS_edi
EXTERN TSS_esi
EXTERN TSS_ebp
EXTERN TSS_esp
EXTERN TSS_eip
EXTERN TSS_eflags
EXTERN TSS_cs
EXTERN TSS_ds
EXTERN TSS_es
EXTERN TSS_ss
EXTERN TSS_simd
EXTERN __FIN_PILA_NUCLEO_TAREA_0_LIN
EXTERN __TAREA_0_TEXT_LIN
EXTERN __TAREA_0_TEXT_ROM
EXTERN __TAREA_1_TEXT_ROM
EXTERN __TAREA_2_TEXT_ROM
EXTERN __TAREA_0_TEXT_LENGHT
EXTERN __TAREA_1_TEXT_LENGHT
EXTERN __TAREA_2_TEXT_LENGHT

;--------- Variables compartidas -----------
GLOBAL cambiar_tarea
GLOBAL arrancar_scheduler
GLOBAL tarea_actual

;-------------------------------------------------------------
  cambiar_tarea:
    guardar_contexto:
      push edi
      push edx
      push eax
      mov eax, [tarea_actual]
      mov edi, TSS_Lenght
      mul edi  ; (48 bytes)
      mov edi, eax
      pop eax
      pop edx

      mov [TSS_eax + edi], eax
      mov [TSS_ebx + edi], ebx
      mov [TSS_ecx + edi], ecx
      mov [TSS_edx + edi], edx
      pop edx
      mov [TSS_edi + edi], edx
      mov [TSS_esi + edi], esi
      mov [TSS_ebp + edi], ebp
      ; PILA:
      ; 1- eip ret isr_irq_00_pit / tarea_terminada / start_scheduler
      ; 2- eip ret tarea
      ; 3- cs tarea
      ; 4- eflags tarea
      pop eax
      pop eax
      mov [TSS_eip + edi], eax
      pop eax
      mov [TSS_cs + edi], ax
      pop eax
      mov [TSS_eflags + edi], eax
      mov [TSS_esp + edi], esp
      mov ax, ds
      mov [TSS_ds + edi], ax
      mov ax, ss
      mov [TSS_ss + edi], ax
      mov ax, es
      mov [TSS_es + edi], ax

      mov ebx, cr0    ; Traigo los registros de control 0
      and ebx, 0x08   ; Chequeo si el bit 3 (Task Switched) está en 1 (Allows saving x87 task context upon a task switch only after x87 instruction used)
      cmp ebx, 0x08
      jnz cambio_indicadores
        fxsave [TSS_simd + edi]  ; Save x87 FPU, MMX Technology, and SSE State

    cambio_indicadores:
      mov esi, [tarea_actual]
      mov edi, [tarea_futura]
      mov [tarea_actual], edi

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
      mov esp, [pila_nucleo]
      push edi
      call paginar_tareas
      pop edi

      mov eax, [tarea_inicializada]   ; Flag para saber si la tarea existe en ram
      mov ecx, edi
      mov edx, 0x01

      loop_shift_ini:
      cmp ecx, 0x00
      je end_loop_shift_ini
        shl edx, 0x01
        dec ecx
        jmp loop_shift_ini
      end_loop_shift_ini:

      and eax, edx
      cmp eax, 0x00         ; Si es 1, ya está inicalizada, voy a copiar el contexto. Si es 0 tengo copiarla primero
      jnz copiar_contexto
        mov eax, [tarea_inicializada]   ; Actualizo valor de flag
        and eax, edx
        mov [tarea_inicializada], eax
        call copiar_tarea

    copiar_contexto:
      mov ebx, cr0    ; Traigo los registros de control 0
      and ebx, 0x08   ; Chequeo si el bit 3 (Task Switched) está en 1 (Allows saving x87 task context upon a task switch only after x87 instruction used)
      cmp ebx, 0x08
      jnz no_copio_simd
        fxrstor [TSS_simd + edi]  ; Restore x87 FPU, MMX, XMM, and MXCSR State
      no_copio_simd:
      push edi
      call mostrar_tarea
      pop eax
      mov ecx, TSS_Lenght
      mul ecx  ; (560 bytes)
      mov edi, eax
      mov ax, [TSS_es + edi]
      ;mov es, ax
      mov ax, [TSS_ss + edi]
      mov ss, ax
      mov ax, [TSS_ds + edi]
      mov ds, ax

      mov eax, [TSS_eax + edi]
      mov ebx, [TSS_ebx + edi]
      mov ecx, [TSS_ecx + edi]
      mov esi, [TSS_esi + edi]
      mov ebp, [TSS_ebp + edi]
      mov esp, [TSS_esp + edi]
      ; PILA:
      ; 3- eip ret tarea
      ; 2- cs tarea
      ; 1- eflags tarea
      mov edx, [TSS_eflags + edi]
      push edx
      xor edx, edx
      mov dx, [TSS_cs + edi]
      push edx
      mov edx, [TSS_eip + edi]
      push edx
      mov edx, [TSS_edi + edi]
      push edx
      mov edx, [TSS_edx + edi]
      pop edi

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
    push dword tarea_0

    call cambiar_tarea

;-------------------------------------------------------------
  arrancar_scheduler:
    mov eax, esp
    mov [pila_nucleo], esp
    xor eax, eax    ; Pusheo eip, cs y eflags vacíos
    push eax
    push eax
    push eax
    sti ; Enciendo las interrupciones
    call cambiar_tarea

;-------------------------------------------------------------
  copiar_tarea:
    pushad

    cmp edi, 0x00
    jnz no_copio_tarea_0
      push __TAREA_0_TEXT_ROM     ; Pusheo ORIGEN
      push __TAREA_0_TEXT_LIN     ; Pusheo DESTINO
      push __TAREA_0_TEXT_LENGHT  ; Pusheo LARGO
      call copy                   ; LLamo a la rutina
      pop eax               ; Saco los 3 push que hice antes
      pop eax
      pop eax
    no_copio_tarea_0:

    cmp edi, 0x01
    jnz no_copio_tarea_1
      push __TAREA_1_TEXT_ROM     ; Pusheo ORIGEN
      push __TAREA_0_TEXT_LIN     ; Pusheo DESTINO
      push __TAREA_1_TEXT_LENGHT  ; Pusheo LARGO
      call copy                   ; LLamo a la rutina
      pop eax               ; Saco los 3 push que hice antes
      pop eax
      pop eax
    no_copio_tarea_1:

    cmp edi, 0x02
    jnz no_copio_tarea_2
      push __TAREA_2_TEXT_ROM     ; Pusheo ORIGEN
      push __TAREA_0_TEXT_LIN     ; Pusheo DESTINO
      push __TAREA_2_TEXT_LENGHT  ; Pusheo LARGO
      call copy                   ; LLamo a la rutina
      pop eax               ; Saco los 3 push que hice antes
      pop eax
      pop eax
    no_copio_tarea_2:

    popad
    mov ebp, esp  ; Guardo la pila
    mov ecx, __FIN_PILA_NUCLEO_TAREA_0_LIN  ; Todas tienen la pila en la misma direccion de memoria
    mov esp, ecx
    push dword tarea_terminada  ; Cuando la tarea termine con el ret, quiero que vaya ahí
    mov ecx, esp    ; Guardo la pila con la posición actualizada
    mov esp, ebp    ; Restauro la pila anterior

    mov eax, edi
    mov edx, TSS_Lenght
    mul edx
    mov [TSS_esp + eax], ecx
    mov [TSS_eip + eax], dword tarea_0   ; Todas arrancan en la misma posicion de memoria
    pushfd
    pop ecx
    mov [TSS_eflags + eax], ecx
    mov [TSS_ds + eax], ds
    mov [TSS_es + eax], es
    mov [TSS_ss + eax], ss
    mov [TSS_cs + eax], cs

    ret

;-------------------------------------------------------------
  tarea_actual:
    dd 0x00
  tarea_futura:
    dd 0x01
  tarea_inicializada:
    dd 0x00
  pila_nucleo:
    dd 0x00
