ELF := target/riscv64gc-unknown-none-elf/debug/min
BIN := $(ELF).bin

clean:
	@cargo clean

build:
	@cargo build
	@rust-objcopy -O binary -S \
		$(ELF) $(BIN)

run: build
	@qemu-system-riscv64 -M virt \
		-display none -serial stdio \
		-smp cores=8 \
		-device loader,file=$(BIN),addr=0x80000000

server: build
	@qemu-system-riscv64 -s -S -M virt \
		-display none -serial stdio \
		-smp cores=8 \
		-device loader,file=$(BIN),addr=0x80000000

client:
	@riscv64-unknown-elf-gdb \
		-ex "file $(ELF)" \
		-ex "target remote localhost:1234"

symbol:
	@rust-nm -C -g -v -x $(ELF)

size:
	@rust-size -A -x $(ELF)

dump:
	@rust-objdump -C -S $(ELF) > min.disasm

all: clean build symbol size dump
