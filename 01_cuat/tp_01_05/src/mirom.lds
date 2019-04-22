__INICIO_PILA = 0x1FFFB000;
__SIZE_PILA = 0x4000;
__FIN_PILA = __INICIO_PILA + __SIZE_PILA;   /* Tamaño de pila = 16k */

MEMORY
{
  ram (rwx) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000
  rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFF0
  rom_reset (rx) : ORIGIN = 0xFFFFFFF0, LENGTH = 0x10
}
          /* El ". = DIR" es memoria virtual (VMA) ---- El "AT(DIR)" es LMA*/
SECTIONS                  /* Las secciones se definen en orden creciente de posiciones de memorias a donde se ubicarán */
{                         /* El "." indica la posición de memoria donde ubicar las siguientes secciones de código (VMA) */
  .init 0xFFFF0000 :      /* nombre de la sección a copiar */
    {*(.init)} AT >rom    /* Entre paréntesis la LMA donde está la sección a copiar/ubicar. El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */

  .rutinas 0x00000000 :
    { __INICIO_RAM_RUTINAS = .;
    __INICIO_ROM_RUTINAS = LOADADDR(.rutinas);
    __INICIO_RUTINA_COPY_EN_ROM = __INICIO_ROM_RUTINAS;
    copy.elf(.copy);
    *(.rutinas);
    __LONGITUD_RUTINAS = . - __INICIO_RAM_RUTINAS; } AT >rom

  /* .nucleo 0x00300000 :
    AT >rom
    {*(.nucleo)} >ram */

  .reset 0xFFFFFFF0:      /* Cambio la ubicación del puntero "." */
    {*(.reset)} AT >rom_reset
}
