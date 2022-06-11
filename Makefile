ELF := target/riscv64gc-unknown-none-elf/debug/min-sys
BIN := $(ELF).bin

clean:
	@cargo clean

build:
	@cargo build
	@rust-objcopy -S -O binary \
		$(ELF) $(BIN)

run: build
	@qemu-system-riscv64 -M virt \
		-display none -serial stdio \
		-device loader,file=$(BIN),addr=0x80000000

server: build
	@qemu-system-riscv64 -s -S -M virt \
		-display none -serial stdio \
		-device loader,file=$(BIN),addr=0x80000000

client:
	@riscv64-unknown-elf-gdb-py \
		-ex "file $(ELF)" \
		-ex "target remote localhost:1234"

symbol:
	@rust-nm -x -g $(ELF)

size:
	@rust-size -A -x $(ELF)

dump:
	@rust-objdump -S $(ELF)
