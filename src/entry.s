    .section .text.entry
    .global _start
_start:
    la sp, _stack_top
    call main

    .section .data.stack
    .global _stack_bottom
_stack_bottom:
    .space 4096 * 16
    .global _stack_top
_stack_top:
