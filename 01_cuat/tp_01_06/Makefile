# Makefile para TD3 UTN FRBA
# Rodrigo Anton - Leg. 144.129-2
# Version: 1.0
# Año: 2019

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++ DEFINICIONES +++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Carpeta donde se encuentran los archivos fuente (.asm)
CARPETA_SRC = src

# Carpeta donde se desea generarán los archivos objeto (.elf)
CARPETA_BIN = bin

# Nombre del archivo binario final (.bin)
OUTPUT_BIN = bios.bin

# Flags del compilador
# "-f elf32": Formato de salida elf 32 bits
CFLAGS = -f elf32

# Flags del LD
# "-z max-page-size=0x1000": Tamaño maximo de pagina
# "-m elf_i386": Emula un procesador i386
# "-T": Usa mi script para linkear
# "-Map memory.map": Guarda el mapa de linkeo en el archivo memory.map
#
LFLAGS = -z max-page-size=0x1000 -Map memory.map --oformat=binary -m elf_i386 -T

# Compilador
CC = nasm

# LD
LD = ld

# Path y nombre de los archivos fuente (.asm)
SRC = $(wildcard $(CARPETA_SRC)/*.asm)

# Path y nombre de los archivos objeto (.elf)
OBJ = $(subst $(CARPETA_SRC)/,$(CARPETA_BIN)/,$(SRC:.asm=.elf))


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++ REGLAS ++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

all: $(OUTPUT_BIN)

	@echo	'==> Ejecutando bochs'
	bochs -qf ./run.cfg
	@echo	'==> Limpiando temporales'
	rm *.ini
	rm *.log

$(OUTPUT_BIN):  $(CARPETA_SRC)/linker.lds $(OBJ)
	@echo "==> Linkeando $^ a $@"
	$(LD) $(LFLAGS) $^ -o $@

$(CARPETA_BIN)/%.elf: $(CARPETA_SRC)/%.asm
	@echo "==> Compilando $<"
	$(CC) $(CFLAGS) $< -o $@

$(CARPETA_BIN):
	mkdir -p $@

clean:
	@echo "==> Limpiando"
	@rm -f ./*.log
	@rm -f ./*.ini
	@rm -f ./*.bin
	@rm -f ./*.map
	@rm -f ./$(CARPETA_BIN)/*
