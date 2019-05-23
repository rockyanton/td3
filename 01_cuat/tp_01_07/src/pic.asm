%define MASTER_PIC_8259_CMD_PORT   0x20
%define MASTER_PIC_8259_DATA_PORT  0x21

%define SLAVE_PIC_8259_CMD_PORT    0xA0
%define SLAVE_PIC_8259_DATA_PORT   0xA1

%define PIC_8259_EOI               0x20

SECTION .pic_init progbits
GLOBAL _pic_configure
USE32
_pic_configure:
   ;; ICW1: IRQs activas x flanco, cascada, e ICW4
   mov al, 0x11
   out MASTER_PIC_8259_CMD_PORT, al
   ;; ICW2: El PIC 1 arranca en INT tipo 'base_1'
   mov al, 0x20
   out MASTER_PIC_8259_DATA_PORT, al
   ;; ICW3: PIC 1 Master, Slave, Ingresa Int x IRQ2
   mov al, 0x4
   out MASTER_PIC_8259_DATA_PORT, al
   ;; ICW4: Modo 8086
   mov al, 0x1
   out MASTER_PIC_8259_DATA_PORT, al
   ;; Enmascaro interrupciones del PIC 1 según 'mask_1'
   mov al, 0xFF
   out MASTER_PIC_8259_DATA_PORT, al
   ;; ICW1: IRQs activas x flanco, cascada, e ICW4
   mov al, 0x11
   out SLAVE_PIC_8259_CMD_PORT, al
   ;; ICW 2: El PIC 2 arranca en INT tipo 'base_2'
   mov al, 0x28
   out SLAVE_PIC_8259_DATA_PORT, al
   ;; ICW 3: PIC 2 Slave, Ingresa Int x IRQ2
   mov al, 0x2
   out SLAVE_PIC_8259_DATA_PORT, al
   ;; ICW 4: Modo 8086
   mov al, 0x1
   out SLAVE_PIC_8259_DATA_PORT, al
   ;; Enmascaro interrupciones del PIC 2 según 'mask_2'
   mov al, 0xFF
   out SLAVE_PIC_8259_DATA_PORT, al
