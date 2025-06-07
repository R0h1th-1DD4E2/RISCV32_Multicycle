# RISC-V32I Makefile for Multicycle Core Testing
# Supports both Assembly and C programs

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
LDFLAGS = -T linker.ld -nostdlib

# ROM size for multicycle core (typically 4KB-16KB)
ROM_SIZE = 8192  # 8KB ROM - good size for multicycle core testing

# Default target
all: test_asm test_c

# Assembly program targets
test_asm: program_asm.hex program_asm.bin program_asm.mem
	@echo "Assembly program built successfully"
	@$(SIZE) program_asm.elf

test_c: program_c.hex program_c.bin program_c.mem
	@echo "C program built successfully"
	@$(SIZE) program_c.elf

# Assembly program build rules
program_asm.o: program.s
	$(AS) $(ASFLAGS) -o $@ $<

program_asm.elf: program_asm.o
	$(LD) $(LDFLAGS) -o $@ program_asm.o

# C program build rules
program_c.o: program.c
	$(CC) $(CFLAGS) -c -o $@ $<

crt0.o: crt0.s
	$(AS) $(ASFLAGS) -o $@ $<

program_c.elf: program_c.o crt0.o
	$(LD) $(LDFLAGS) -o $@ crt0.o program_c.o

# Generate hex files (Intel HEX format)
%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

# Generate binary files
%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

# Generate memory files for Verilog simulation
%.mem: %.bin
	xxd -ps -c 4 $< | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $@

# Generate disassembly for debugging
%.dis: %.elf
	$(OBJDUMP) -d $< > $@

# Generate symbol table
%.sym: %.elf
	$(OBJDUMP) -t $< > $@

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

# Verification targets
verify: verify_asm verify_c

verify_asm: program_asm.bin
	@echo "=== Assembly Program Verification ==="
	@SIZE_BYTES=$$(stat -c%s program_asm.bin); \
	echo "Binary size: $$SIZE_BYTES bytes"; \
	if [ $$SIZE_BYTES -gt $(ROM_SIZE) ]; then \
		echo "ERROR: Program too large for $(ROM_SIZE) byte ROM!"; \
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
		echo "ERROR: Program too large for $(ROM_SIZE) byte ROM!"; \
		exit 1; \
	else \
		echo "OK: Program fits in $(ROM_SIZE) byte ROM"; \
	fi
	@echo "Hex dump (first 64 bytes):"
	@hexdump -C program_c.bin | head -4

# Generate linker script dynamically
generate_files: linker.ld crt0.s program.s program.c

# Clean targets
clean:
	rm -f *.o *.elf *.hex *.bin *.mem *.dis *.sym

distclean: clean
	rm -f linker.ld crt0.s program.s program.c

# Help target
help:
	@echo "RISC-V32I Makefile for Multicycle Core"
	@echo "======================================"
	@echo "Targets:"
	@echo "  all         - Build both assembly and C programs"
	@echo "  test_asm    - Build assembly program"
	@echo "  test_c      - Build C program"
	@echo "  analyze_asm - Analyze assembly program"
	@echo "  analyze_c   - Analyze C program"
	@echo "  verify      - Verify both programs fit in ROM"
	@echo "  clean       - Remove build files"
	@echo "  distclean   - Remove all generated files"
	@echo ""
	@echo "Configuration:"
	@echo "  ROM_SIZE = $(ROM_SIZE) bytes"
	@echo "  ARCH = $(ARCH)"
	@echo "  ABI = $(ABI)"
	@echo ""
	@echo "Output files:"
	@echo "  *.hex - Intel HEX format (for most tools)"
	@echo "  *.bin - Raw binary"
	@echo "  *.mem - Verilog memory format"

.PHONY: all test_asm test_c analyze_asm analyze_c verify verify_asm verify_c clean distclean help generate_files
