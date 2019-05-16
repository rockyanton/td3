# Makefile para TD3 UTN FRBA
# Version: 5.0
# Año: 2018

# NOTA: Los paths relativos deben especificarse SIN el "./"
#		Los archivos assembler deben tener extension .asm


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++ DEFINICIONES +++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Carpeta donde se encuentran los archivos fuente (.asm)
CARPETA_SRC = src

# Carpeta donde se desea generar el archivo binario (.bin)
CARPETA_BIN = bin

# Carpeta donde se desea generar el archivo de Formato Ejecutable y Linkeable (.elf)
CARPETA_ELF = bin

# Carpeta donde se desean guardar los archivos del log (.log)
CARPETA_LOG = log

# Nombre del archivo binario generado
OUTPUT_NAME = bios

# Lista de directorios
DIRECTORY = src/ bin/ log/

# Flags del compilador
# "-felf32": Formato de salida elf 32 bits
CFLAGS = -f elf32

# Flags del linker
# "-z max-page-size=0x01000": Tamaño maximo de pagina
# "-m elf_i386": Emula un procesador i386
LFLAGS = -z max-page-size=0x01000 -m elf_i386

# Compilador
COMPILER = nasm

# Linker
LINKER = ld

# Path y nombre del binario (.bin)
OUTPUT_BIN = $(CARPETA_BIN)/$(OUTPUT_NAME).bin

# Path y nombre del archivo de salida en formato linkeable y ejecutable (.elf)
OUTPUT_ELF = $(CARPETA_ELF)/$(OUTPUT_NAME).elf

# Path y nombre de los archivos fuente (.asm)
SRCS = $(wildcard $(CARPETA_SRC)/*.asm)

# Define una funcion para crear la estructura de carpetas
define CREAR_ESTRUCTURA
	@echo	''
	@echo	'-----> Creando estructura de carpetas'

	mkdir -p $(DIRECTORY)
endef


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++ REGLAS ++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

all: crearEstructura clean compilar
	@echo	''
	@echo	'Ejecutando bochs'
	bochs -qf ./$(CARPETA_SUP)/bochsrc.txt -q
	rm *.ini

$(OUTPUT_BIN): $(OBJS)
	@echo	''
	@echo	'-----> Linkeando' $^ 'a binario'

	#$(LINKER) $(LFLAGS) --oformat=binary $^ -o $@

	@echo	''
	@echo	'tamaño en bytes:'
	stat -c%s "$(OUTPUT_BIN)"

$(OUTPUT_ELF): $(OBJS)
	@echo	''
	@echo	'-----> Linkeando' $^ 'a ELF'

	$(LINKER) $(LFLAGS) $^ -o $@

./$(CARPETA_OBJ)/%.o: ./$(CARPETA_SRC)/%.asm
	@echo	''
	@echo	'-----> Compilando fuente' $<

	$(COMPILER) $(CFLAGS) $< -o $(OUTPUT_BIN) -l $(subst $(CARPETA_OBJ)/,$(CARPETA_LST)/,$(@:.o=.lst))


.PHONY: compilar
compilar: clean $(OUTPUT_BIN)
	@echo	''
	@echo	'-----> Generando listados de hexadecimales y ELFs'

	#hexdump -C $(OUTPUT_BIN) > ./$(CARPETA_TXT)/$(OUTPUT_NAME)_hexdump.txt
	#objdump $(ODFLAGS) $(OUTPUT_ELF) > ./$(CARPETA_TXT)/$(OUTPUT_NAME)_objdump.txt
	#readelf -a $(OUTPUT_ELF) > ./$(CARPETA_TXT)/$(OUTPUT_NAME)_readelf.txt

	@echo	''
	@echo	''
	@echo	'LISTO! n_n'
	@echo	''


.PHONY: crearEstructura
crearEstructura: $(DIRECTORY)

$(DIRECTORY):
	$(CREAR_ESTRUCTURA)

clean:
	@echo	''
	@echo	'-----> Limpiando'

	rm -f *.o
	rm -f ./$(CARPETA_BIN)/*.bin
	rm -f ./$(CARPETA_ELF)/*.elf
	rm -f ./*.log
	rm -f ./*.ini
