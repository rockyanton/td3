all:
	nasm -f elf32 -o ejer5.elf ejer5.asm
	nasm -f elf32 -o copy.elf copy.asm
	ld -z max-page-size=0x1000 -Map ejer5.map -m elf_i386 -T mirom.lds ejer5.elf copy.elf -o mirom.elf
	ld -z max-page-size=0x1000 --oformat=binary -m elf_i386 -T mirom.lds ejer5.elf copy.elf -o mirom.bin
