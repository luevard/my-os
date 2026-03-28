ENTRY(_main)
OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
SECTIONS
{
    . = 0x10000;

    .text :
    {
        *(.multiboot)
        *(.text*)
    }

    .rodata :
    {
        *(.rodata*)
    }

    .data :
    {
        *(.data*)
    }

    .bss :
    {
        *(COMMON)
        *(.bss*)
    }
}