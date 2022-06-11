ENTRY(_start)

SECTIONS {
    . = 0x80000000;

    .text : {
        *(.text.entry)
        *(.text .text.*)
        . = ALIGN(4K);
    }

    .data : {
        *(.data.stack)
        *(.data .data.*)
        . = ALIGN(4K);
    }
}
