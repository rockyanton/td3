all:
		nasm -f elf32 -o ejer5.elf ejer5.asm
		ld -z max-page-size=0x1000 -m elf_i386 -T mirom.lds ejer5.elf -o mirom.elf
		ls -z max_page_size=0x1000 -m elf_i386 -T mirom.lds ejer5.elf -o mirom.bin
