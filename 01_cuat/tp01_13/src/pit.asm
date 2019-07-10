;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++ DEFINES +++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%define breakpoint  xchg bx,bx


%define PIT_8253_CHANNEL_BASE_DATA_PORT 0x40
%define PIT_8253_CHANNEL_COUNT          0x03
%define PIT_8253_CMD_PORT               0x43

%define PIT_8253_CMD_CHANNEL_OFFSET 0x06
%define PIT_8253_CMD_OPMODE_OFFSET  0x01
%define PIT_8253_LOHI_ACCESS_MODE   0x30

%define PIT_8253_CHANNEL_0  0x00

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++ PIT 8254 (TIMER) => IRQ x20 +++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;--------- Parámetros globales ------------
USE32
SECTION .init progbits

;--------- Variables externas ------------

;--------- Variables compartidas -----------
GLOBAL _pit_configure

;-------------------------------------------------------------------------------
_pit_configure:
  pushad
  xor edx, edx    ; Borro registro
  ;  Bits         Usage
  ; 6 and 7      Select channel :
  ;                 0 0 = Channel 0
  ;                 0 1 = Channel 1
  ;                 1 0 = Channel 2
  ;                 1 1 = Read-back command (8254 only)
  ; 4 and 5      Access mode :
  ;                 0 0 = Latch count value command
  ;                 0 1 = Access mode: lobyte only
  ;                 1 0 = Access mode: hibyte only
  ;                 1 1 = Access mode: lobyte/hibyte
  ; 1 to 3       Operating mode :
  ;                 0 0 0 = Mode 0 (interrupt on terminal count)
  ;                 0 0 1 = Mode 1 (hardware re-triggerable one-shot)
  ;                 0 1 0 = Mode 2 (rate generator)
  ;                 0 1 1 = Mode 3 (square wave generator)
  ;                 1 0 0 = Mode 4 (software triggered strobe)
  ;                 1 0 1 = Mode 5 (hardware triggered strobe)
  ;                 1 1 0 = Mode 2 (rate generator, same as 010b)
  ;                 1 1 1 = Mode 3 (square wave generator, same as 011b)
  ; 0            BCD/Binary mode: 0 = 16-bit binary, 1 = four-digit BCD
  mov dl, PIT_8253_CHANNEL_0    ; Elijo canal 0
  mov ecx, edx                  ; Salvo canal en otro registro
  shl dl, PIT_8253_CMD_CHANNEL_OFFSET ; Shifteo para poner el canal en el bit 6
  xor eax, eax    ; Borro registro
  mov al, 0x03    ; Operating mode "011": Square Wave Generator
  shl al, PIT_8253_CMD_OPMODE_OFFSET  ; Shifteo para ponerlo en el bit 1
  or  al, PIT_8253_LOHI_ACCESS_MODE   ; "0011 0000": Acces mode lobyte/hibyte
  or  al, dl      ; Agrego en los bits 6-7 el canal
  out PIT_8253_CMD_PORT, al   ; Lo mando por el puerto de salida al PIT
  add cx, PIT_8253_CHANNEL_BASE_DATA_PORT ; Cargo el puerto de salida del canal del pit
  mov dx, cx
  mov ax, 11932 ; 1.193182MHz * 10ms = 11932 ==> Interrumpe cada 10ms
  out dx, al    ; Le envío al canal el primer byte
  mov al, ah    ; Invierto
  out dx, al    ; Le envío al canal el segundo byte
  popad
  ret
