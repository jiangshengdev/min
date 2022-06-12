const VIRT_TEST: u32 = 0x100000;
const FINISHER_PASS: u32 = 0x5555;

pub fn exit() -> ! {
    unsafe {
        *(VIRT_TEST as *mut u32) = FINISHER_PASS;
    };

    loop {}
}
