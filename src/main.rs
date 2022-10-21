#![no_std]
#![no_main]
#![feature(alloc_error_handler)]

extern crate alloc;

use core::arch::global_asm;

mod binary_heap;
mod first;
mod heap;
mod panic;
mod second;
mod test;

global_asm!(include_str!("entry.s"));

#[no_mangle]
fn main() {
    first::tests::all();
    second::tests::all();
    binary_heap::tests::all();
    test::exit();
}
