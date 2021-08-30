MEMORY
{
  rom      (rx)  : ORIGIN = 0x10000000, LENGTH = 0x0001000
  ram      (rwx) : ORIGIN = 0x20000000, LENGTH = 0x0008000
}

STACK_SIZE = 0x2000;

/* Section Definitions */
SECTIONS
{
    .text :
    {
        KEEP(*(.vectors .vectors.*))
        *(.text*)
        *(.rodata*)
    } > rom

    /* .bss section which is used for uninitialized data */
    .bss (NOLOAD) :
    {
        *(.bss*)
        *(COMMON)
    } > ram

    .data :
    {
        *(.data*);
    } > ram AT >rom

    /* stack section */
    .stack (NOLOAD):
    {
        . = ALIGN(8);
         _stack = .;
        . = . + STACK_SIZE;
        . = ALIGN(8);
    } > ram

    _end = . ;
}