all:
	nasm -f elf32 -o bin/main.elf src/main.asm
	nasm -f elf32 -o bin/copy.elf src/copy.asm
	ld -z max-page-size=0x1000 -Map src/memory.map -m elf_i386 -T src/linker.lds bin/main.elf bin/copy.elf -o bin/bios.elf
	ld -z max-page-size=0x1000 --oformat=binary -m elf_i386 -T src/linker.lds bin/main.elf bin/copy.elf -o bin/bios.bin
