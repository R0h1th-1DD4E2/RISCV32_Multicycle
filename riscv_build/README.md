# RISC-V32I Multicycle Core Makefile

This Makefile is designed for building and testing programs on RISC-V32I multicycle processor cores. It supports both assembly and C programs, generating various output formats suitable for simulation and hardware testing.

## Prerequisites

### Required Tools
You need the RISC-V GNU Toolchain installed on your system:

```bash
# Ubuntu/Debian
sudo apt-get install gcc-riscv64-unknown-elf

# Arch Linux
sudo pacman -S riscv64-unknown-elf-gcc
```

### Required Files
Before using the Makefile, you need these files in your project directory:

1. **linker.ld** - Linker script defining memory layout
2. **crt0.s** - C runtime startup code (for C programs)
3. **program.s** - Your assembly program
4. **program.c** - Your C program

*Note: Use `make generate_files` if you need template versions of these files.*

## Quick Start

### Building Programs

```bash
# Build both assembly and C programs
make all

# Build only assembly program
make test_asm

# Build only C program  
make test_c
```

### Analyzing Your Programs

```bash
# Analyze assembly program (size, memory layout, disassembly)
make analyze_asm

# Analyze C program
make analyze_c
```

### Verifying ROM Size

```bash
# Check if programs fit in the configured ROM size (8KB default)
make verify
```

## Output Files

The Makefile generates several output formats:

| Extension | Description | Use Case |
|-----------|-------------|----------|
| `.hex` | Intel HEX format | Most simulators and programmers |
| `.bin` | Raw binary | Direct memory loading |
| `.mem` | Verilog memory format | Verilog/SystemVerilog testbenches |
| `.dis` | Disassembly | Debugging and analysis |
| `.sym` | Symbol table | Debugging |

## Configuration

### ROM Size
Default ROM size is 8KB (8192 bytes). To change it:

```bash
make ROM_SIZE=4096 all    # 4KB ROM
make ROM_SIZE=16384 all   # 16KB ROM
```

### Architecture Settings
- **Architecture**: RV32I (32-bit RISC-V Integer)
- **ABI**: ilp32 (Integer, Long, Pointer = 32-bit)

These are optimized for multicycle cores and typically don't need changing.

## Example Workflow

### For Assembly Programming:

1. **Create your assembly program** (`program.s`):
   ```assembly
   .section .text
   .global _start
   
   _start:
       li x1, 42        # Load immediate
       li x2, 8         # Load immediate
       add x3, x1, x2   # Add registers
       # ... more instructions
   ```

2. **Build and test**:
   ```bash
   make test_asm
   make analyze_asm
   make verify_asm
   ```

3. **Use the output**:
   - Load `program_asm.hex` into your simulator
   - Or use `program_asm.mem` in Verilog testbenches

### For C Programming:

1. **Create your C program** (`program.c`):
   ```c
   int main() {
       int a = 42;
       int b = 8;
       int c = a + b;
       return c;
   }
   ```

2. **Build and test**:
   ```bash
   make test_c
   make analyze_c
   make verify_c
   ```

### Getting Help

```bash
# Show all available targets and configuration
make help
```

### Cleaning Up

```bash
# Remove build files
make clean

# Remove all generated files (including templates)
make distclean
```

## Advanced Usage

### Custom Linker Script
Modify `linker.ld` to match your processor's memory map:

```ld
MEMORY {
    ROM : ORIGIN = 0x00000000, LENGTH = 8K
    RAM : ORIGIN = 0x10000000, LENGTH = 4K
}
```

### Debugging
Generate detailed analysis:

```bash
make program_asm.dis  # Disassembly
make program_asm.sym  # Symbol table
hexdump -C program_asm.bin  # Raw hex dump
```

### Batch Processing
Process multiple files:

```bash
# Build everything and verify
make all verify analyze_asm analyze_c
```

## File Structure

```
project/
├── Makefile           # This makefile
├── linker.ld         # Memory layout definition
├── crt0.s            # C startup code
├── program.s         # Assembly source
├── program.c         # C source
├── program_asm.*     # Assembly build outputs
└── program_c.*       # C build outputs
```
