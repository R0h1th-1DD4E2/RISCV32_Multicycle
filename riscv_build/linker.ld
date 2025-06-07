/* Linker script for RISC-V32I Multicycle Core */
/* ROM Size: 8KB (8192 bytes) */

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 8K
    RAM (rwx) : ORIGIN = 0x10000000, LENGTH = 4K
}

ENTRY(_start)

SECTIONS
{
    . = 0x00000000;
    
    .text : {
        *crt0.o(.text)      /* Boot code first */
        *(.text)            /* Program code */
        *(.text.*)
        . = ALIGN(4);
    } > ROM
    
    .rodata : {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } > ROM
    
    .data : {
        *(.data)
        *(.data.*)
        . = ALIGN(4);
    } > ROM
    
    /* Symbols for program size checking */
    _end = .;
    _program_size = _end - 0x00000000;
    
    /* Ensure we don't exceed ROM size */
    ASSERT(_program_size <= 8192, "Program exceeds ROM size!")
    
    /* RAM section (not loaded, just for allocation) */
    .bss : {
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _bss_end = .;
    } > RAM
    
    /* Stack at top of RAM */
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
