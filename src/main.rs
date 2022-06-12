#![no_std]
#![no_main]
#![feature(alloc_error_handler)]

use core::arch::global_asm;

mod heap;
mod panic;
mod test;

global_asm!(include_str!("entry.s"));

#[no_mangle]
fn main() {
    test::exit();
}
