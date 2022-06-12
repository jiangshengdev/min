use core::panic::PanicInfo;

use crate::test;

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    test::exit();
}
