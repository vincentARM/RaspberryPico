MEMORY
{
  rom      (rx)  : ORIGIN = 0x10000100, LENGTH = 0x0002000
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH = 0x0008000
}

STACK_SIZE = 0x2000;

/* Section Definitions */
SECTIONS
{
    .text :
    {
       /*  KEEP(*(.vectors .vectors.*)) */
        *(.text*)
        *(.rodata*)
    } > rom

    _debutRomData = . ;
    .data :
    {
      _debutRamData = . ;
        *(.data*);
    } > ram AT >rom
     /* .bss section which is used for uninitialized data */
     _debutRamBss = . ;
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram

    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
        . = . + STACK_SIZE;
        _stack = .;
        . = ALIGN(8);
    } > ram

    _end = . ;
}