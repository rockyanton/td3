SECTION                 /* Las secciones se definen en orden creciente de posiciones de memorias a donde se ubicarán */
{
  . = 0xFFFF0000;       /* El "." indica la posición de memoria donde ubicar las siguientes secciones de código (VMA) */
  .init :               /* nombre de la sección a copiar */
  AT (0xF0000)          /* Entre paréntesis la LMA donde está la sección a copiar/ubicar */
    {*(.init)}          /* El "*" define que todas las secciones con ese nombre se copien/ubiquen en la dirección apuntada por "." */

  . = 0xFFFFFFF0;       /* Cambio la ubicación del puntero "." */
  .reset :
  AT (0xFFFF0)
    {*(.reset)}
}
