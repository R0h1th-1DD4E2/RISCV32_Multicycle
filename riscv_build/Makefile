# RISC-V32I Makefile for Multicycle Core Testing
# Supports both Assembly and C programs with generic compilation

# Toolchain configuration
PREFIX = riscv64-unknown-elf-
CC = $(PREFIX)gcc
AS = $(PREFIX)as
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
SIZE = $(PREFIX)size

# Architecture and ABI for RV32I
ARCH = rv32i
ABI = ilp32

# Compiler flags for multicycle core
CFLAGS = -march=$(ARCH) -mabi=$(ABI) -O2 -nostdlib -nostartfiles -ffreestanding
ASFLAGS = -march=$(ARCH) -mabi=$(ABI)
LDFLAGS = -T linker.ld -nostdlib -nostartfiles

# ROM size for multicycle core validation
ROM_SIZE = 8192

# Default targets
all: test_asm test_c

test_asm: program_asm.hex program_asm.bin program_asm.mem program_asm.map
	@echo "Assembly program built successfully"
	@$(SIZE) program_asm.elf

test_c: program_c.hex program_c.bin program_c.mem program_c.map
	@echo "C program built successfully"
	@$(SIZE) program_c.elf

# Specific program build rules
program_asm.o: program.s
	$(AS) $(ASFLAGS) -o $@ $<

program_asm.elf: program_asm.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ program_asm.o

program_c.o: program.c
	$(CC) $(CFLAGS) -c -o $@ $<

crt0.o: crt0.s
	$(AS) $(ASFLAGS) -o $@ $<

program_c.elf: program_c.o crt0.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ crt0.o program_c.o

# Generic compilation rules for any program
%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Assembly program linking
%.elf: %.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

# C program linking (requires crt0.o)
%_c.elf: %.o crt0.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ crt0.o $<

# Output format generation
%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.mem: %.bin
	xxd -ps -c 4 $< | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $@

%.map: %.elf
	$(OBJDUMP) -h $< > $@

%.dis: %.elf
	$(OBJDUMP) -d $< > $@

%.sym: %.elf
	$(OBJDUMP) -t $< > $@

# Convenience target for complete program build
%_all: %.hex %.bin %.mem %.map %.dis
	@echo "$* program built in all formats"
	@$(SIZE) $*.elf

# Analysis targets
analyze_asm: program_asm.dis program_asm.sym
	@echo "=== Assembly Program Analysis ==="
	@echo "Program size:"
	@$(SIZE) program_asm.elf
	@echo "\nMemory layout:"
	@$(OBJDUMP) -h program_asm.elf
	@echo "\nFirst 16 instructions:"
	@head -20 program_asm.dis

analyze_c: program_c.dis program_c.sym
	@echo "=== C Program Analysis ==="
	@echo "Program size:"
	@$(SIZE) program_c.elf
	@echo "\nMemory layout:"
	@$(OBJDUMP) -h program_c.elf
	@echo "\nFirst 16 instructions:"
	@head -20 program_c.dis

# ROM size verification
verify: verify_asm verify_c

verify_asm: program_asm.bin
	@echo "=== Assembly Program Verification ==="
	@SIZE_BYTES=$$(stat -c%s program_asm.bin); \
	echo "Binary size: $$SIZE_BYTES bytes"; \
	if [ $$SIZE_BYTES -gt $(ROM_SIZE) ]; then \
		echo "ERROR: Program exceeds $(ROM_SIZE) byte ROM limit"; \
		exit 1; \
	else \
		echo "OK: Program fits in $(ROM_SIZE) byte ROM"; \
	fi
	@echo "Hex dump (first 64 bytes):"
	@hexdump -C program_asm.bin | head -4

verify_c: program_c.bin
	@echo "=== C Program Verification ==="
	@SIZE_BYTES=$$(stat -c%s program_c.bin); \
	echo "Binary size: $$SIZE_BYTES bytes"; \
	if [ $$SIZE_BYTES -gt $(ROM_SIZE) ]; then \
		echo "ERROR: Program exceeds $(ROM_SIZE) byte ROM limit"; \
		exit 1; \
	else \
		echo "OK: Program fits in $(ROM_SIZE) byte ROM"; \
	fi
	@echo "Hex dump (first 64 bytes):"
	@hexdump -C program_c.bin | head -4

# Cleanup
clean:
	rm -f *.o *.elf *.hex *.bin *.mem *.dis *.sym *.map

# Usage information
help:
	@echo "RISC-V32I Makefile for Multicycle Core"
	@echo "======================================"
	@echo "Standard targets:"
	@echo "  all           - Build default programs"
	@echo "  test_asm      - Build assembly program"
	@echo "  test_c        - Build C program"
	@echo "  verify        - Verify ROM size compliance"
	@echo "  clean         - Remove build artifacts"
	@echo ""
	@echo "Generic compilation (any program):"
	@echo "  make <name>.hex    - Assembly: <name>.s -> Intel HEX"
	@echo "  make <name>.bin    - Assembly: <name>.s -> Binary"
	@echo "  make <name>.mem    - Assembly: <name>.s -> Verilog memory"
	@echo "  make <name>_c.hex  - C: <name>.c -> Intel HEX"
	@echo "  make <name>_all    - Build all formats for <name>.s"
	@echo ""
	@echo "Analysis:"
	@echo "  make <name>.dis    - Generate disassembly"
	@echo "  make <name>.map    - Generate memory map"
	@echo "  make <name>.sym    - Generate symbol table"
	@echo ""
	@echo "Configuration:"
	@echo "  ROM_SIZE = $(ROM_SIZE) bytes"
	@echo "  ARCH = $(ARCH), ABI = $(ABI)"

.PHONY: all test_asm test_c analyze_asm analyze_c verify verify_asm verify_c clean help