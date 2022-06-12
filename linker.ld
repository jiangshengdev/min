ENTRY(_start)

SECTIONS {
    . = 0x80000000;

    .text : {
        _text_start = .;
        *(.text.entry)
        *(.text .text.*)
        . = ALIGN(4K);
        _text_end = .;
    }

    .rodata : {
        _rodata_start = .;
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        . = ALIGN(4K);
        _rodata_end = .;
    }

    .data : {
        _data_start = .;
        *(.data.stack)
        *(.data .data.*)
        *(.sdata .sdata.*)
        . = ALIGN(4K);
        _data_end = .;
    }

    .bss : {
        _bss_start = .;
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        . = ALIGN(4K);
        _bss_end = .;
    }

    _end = .;
}
