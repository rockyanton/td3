;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++ PIT 8254 (TIMER) => IRQ 0 +++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%define PIT_8253_CHANNEL_BASE_DATA_PORT 0x40
%define PIT_8253_CHANNEL_COUNT 3
%define PIT_8253_CMD_PORT 0x43

%define PIT_8253_CMD_CHANNEL_OFFSET 6
%define PIT_8253_CMD_OPMODE_OFFSET  1
%define PIT_8253_LOHI_ACCESS_MODE   0x30

SECTION .init progbits
GLOBAL _pit_configure
USE32
_pit_configure:
  pushad
  mov  dx, word 0
  cmp  dx, PIT_8253_CHANNEL_COUNT
  jge  .bad_channel
  push dx
  shl  dl, PIT_8253_CMD_CHANNEL_OFFSET
  mov  al, byte 3
  shl  al, PIT_8253_CMD_OPMODE_OFFSET
  or   al, PIT_8253_LOHI_ACCESS_MODE
  or   al, dl
  pop  dx
  out  PIT_8253_CMD_PORT, al
  add  dx, PIT_8253_CHANNEL_BASE_DATA_PORT
  mov  ax, word 11932 ; 1 ms
  out  dx, al
  mov  al, ah
  out  dx, al
  xor  eax, eax
  jmp .return
.bad_channel:
   mov eax, 1
.return:
   popad
   ret
