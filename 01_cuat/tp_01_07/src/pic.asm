;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++++++++++++++++++++++ PIC 8259 (MASTER AND SLAVE) ++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%define MASTER_PIC_8259_CMD_PORT   0x20
%define MASTER_PIC_8259_DATA_PORT  0x21

%define SLAVE_PIC_8259_CMD_PORT    0xA0
%define SLAVE_PIC_8259_DATA_PORT   0xA1

%define PIC_8259_EOI               0x20

SECTION .init progbits
GLOBAL _pic_configure
USE32
_pic_configure:

   ;  |7|6|5|4|3|2|1|0|  ICW1 => CMD PORT MASTER (0X20)
	 ;   | | | | | | | `---- 1=ICW4 is needed, 0=no ICW4 needed
	 ;   | | | | | | `----- 1=single 8259, 0=cascading 8259's
	 ;   | | | | | `------ 1=4 byte interrupt vectors, 0=8 byte int vectors
	 ;   | | | | `------- 1=level triggered mode, 0=edge triggered mode
	 ;   | | | `-------- must be 1 for ICW1 (port must also be 20h or A0h)
	 ;   `------------- must be zero for PC systems
   mov al, 0x11   ; 00010001 => IRQs activas por flanco de subida, cascadeados, e ICW4
   out MASTER_PIC_8259_CMD_PORT, al

	;   |7|6|5|4|3|2|1|0|  ICW2  => DATA PORT MASTER (0x21)
	;    | | | | | `-------- 000= on 80x86 systems
	;    `----------------- A7-A3 of 80x86 interrupt vector
   mov al, 0x20   ; 00100000  =>  El PIC 1 arranca en INT tipo 'base_1' (A5)
   out MASTER_PIC_8259_DATA_PORT, al

   ;  |7|6|5|4|3|2|1|0|  ICW3 for Master Device  => DATA PORT MASTER (0x21)
	 ;   | | | | | | | `---- 1=interrupt request 0 has slave, 0=no slave
	 ;   | | | | | | `----- 1=interrupt request 1 has slave, 0=no slave
	 ;   | | | | | `------ 1=interrupt request 2 has slave, 0=no slave
	 ;   | | | | `------- 1=interrupt request 3 has slave, 0=no slave
	 ;   | | | `-------- 1=interrupt request 4 has slave, 0=no slave
	 ;   | | `--------- 1=interrupt request 5 has slave, 0=no slave
	 ;   | `---------- 1=interrupt request 6 has slave, 0=no slave
	 ;   `----------- 1=interrupt request 7 has slave, 0=no slave
   mov al, 0x04    ; 01000000  =>  PIC 1 Master, Slave, Ingresa Int x IRQ2 (6???)
   out MASTER_PIC_8259_DATA_PORT, al

   ;  |7|6|5|4|3|2|1|0|  ICW4  => DATA PORT MASTER (0x21)
	 ;   | | | | | | | `---- 1 for 80x86 mode, 0 = MCS 80/85 mode                   Bits 32 (Buffering Mode)
	 ;   | | | | | | `----- 1 = auto EOI, 0=normal EOI                               00	 not buffered
	 ;   | | | | `-------- slave/master buffered mode (see below)                    01	 not buffered
	 ;   | | | `--------- 1 = special fully nested mode (SFNM), 0=sequential         10	 buffered mode slave (PC mode)
	 ;   `-------------- unused (set to zero)                                        11	 buffered mode master (PC mode)
   mov al, 0x01   ; 00000001  =>  Modo 8086
   out MASTER_PIC_8259_DATA_PORT, al

   ;  |7|6|5|4|3|2|1|0|  OCW1 - IMR Interrupt Mask Register  => DATA PORT MASTER (0x21)
	 ;   | | | | | | | `---- 0 = service IRQ0, 1 = mask off
	 ;   | | | | | | `----- 0 = service IRQ1, 1 = mask off
	 ;   | | | | | `------ 0 = service IRQ2, 1 = mask off
	 ;   | | | | `------- 0 = service IRQ3, 1 = mask off
	 ;   | | | `-------- 0 = service IRQ4, 1 = mask off
	 ;   | | `--------- 0 = service IRQ5, 1 = mask off
	 ;   | `---------- 0 = service IRQ6, 1 = mask off
	 ;   `----------- 0 = service IRQ7, 1 = mask off
   mov al, 0xFF ; 11111111 => Deshabilito todas las interrupciones por hardware
   out MASTER_PIC_8259_DATA_PORT, al

   ; ICW1 => CMD PORT SLAVE (0XA0)
   mov al, 0x11   ; 00010001 => IRQs activas por flanco de subida, cascadeados, e ICW4
   out SLAVE_PIC_8259_CMD_PORT, al

   ; ICW 2  => DATA PORT SLAVE (0xA1)
   mov al, 0x28   ; 00101000  =>  El PIC 2 arranca en INT tipo 'base_2' (A5 y A3)
   out SLAVE_PIC_8259_DATA_PORT, al

   ;  |7|6|5|4|3|2|1|0|  ICW3 for Slave Device  => DATA PORT SLAVE (0xA1)
	 ;   | | | | | `-------- master interrupt request slave is attached to
	 ;   `----------------- must be zero
   mov al, 0x02   ; 00000010  =>  PIC 2 Slave, Ingresa Int por IRQ2
   out SLAVE_PIC_8259_DATA_PORT, al

   ; ICW 4  => DATA PORT SLAVE (0xA1)
   mov al, 0x01  ; 00000001 =>  Modo 8086
   out SLAVE_PIC_8259_DATA_PORT, al

   ;  OCW1 - IMR Interrupt Mask Register  => DATA PORT SLAVE (0xA1)
   mov al, 0xFF   ; 11111111  => Deshabilito todas las interrupciones por hardware
   out SLAVE_PIC_8259_DATA_PORT, al
