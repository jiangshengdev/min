#![no_std]
#![no_main]
#![feature(alloc_error_handler)]

extern crate alloc;

use core::arch::global_asm;

mod heap;
mod panic;
mod stack;
mod test;

global_asm!(include_str!("entry.s"));

#[no_mangle]
fn main() {
    stack::tests::all();
    test::exit();
}
