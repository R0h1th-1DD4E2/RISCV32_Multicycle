# RISC-V32I Multicycle Core Makefile

This Makefile is designed for building and testing programs on RISC-V32I multicycle processor cores. It supports both assembly and C programs with flexible, generic compilation capabilities, generating various output formats suitable for simulation and hardware testing.

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
2. **crt0.s** - C runtime startup code (for C programs only)
3. **program.s** - Your assembly program (for default targets)
4. **program.c** - Your C program (for default targets)

## Quick Start

### Building Default Programs
```bash
# Build both assembly and C programs
make all

# Build only assembly program
make test_asm

# Build only C program
make test_c
```

### Generic Compilation (Any Program)
The Makefile supports compiling any assembly or C program, not just the default `program.s` and `program.c`:

```bash
# Assembly programs - compile any .s file
make fibonacci.hex          # fibonacci.s -> Intel HEX
make sorting.bin           # sorting.s -> Binary
make calculator.mem        # calculator.s -> Verilog memory format
make matrix_mult_all       # matrix_mult.s -> all formats

# C programs - compile any .c file (requires crt0.s)
make fibonacci_c.hex       # fibonacci.c -> Intel HEX
make sorting_c.bin        # sorting.c -> Binary
make calculator_c.mem     # calculator.c -> Verilog memory format
```

### Analyzing Your Programs
```bash
# Analyze specific programs
make analyze_asm          # Analyze default assembly program
make analyze_c           # Analyze default C program

# Generate analysis files for any program
make fibonacci.dis       # Disassembly
make fibonacci.sym       # Symbol table
make fibonacci.map       # Memory map
```

### Verifying ROM Size
```bash
# Check if default programs fit in ROM (8KB default)
make verify
make verify_asm         # Check assembly program only
make verify_c          # Check C program only
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
| `.map` | Memory map | Memory layout analysis |

## Generic Compilation Features

### Assembly Programs
Compile any assembly file with automatic dependency handling:
```bash
# Any assembly file: name.s -> name.hex/bin/mem
make bubble_sort.hex
make led_blink.bin
make uart_driver.mem
make interrupt_handler_all    # Generate all formats
```

### C Programs
Compile any C program (automatically links with crt0.s):
```bash
# Any C file: name.c -> name_c.hex/bin/mem
make matrix_multiply_c.hex
make digital_filter_c.bin
make state_machine_c.mem
```

### Batch Processing
Build multiple programs at once:
```bash
# Build all formats for a specific program
make fibonacci_all        # fibonacci.s -> .hex, .bin, .mem, .map, .dis

# Process multiple files
make program1.hex program2.hex program3.hex
```

## Configuration

### ROM Size
Default ROM size is 8KB (8192 bytes). Change it globally:
```bash
make ROM_SIZE=4096 all     # 4KB ROM
make ROM_SIZE=16384 all    # 16KB ROM
```

### Architecture Settings
- **Architecture**: RV32I (32-bit RISC-V Integer)
- **ABI**: ilp32 (Integer, Long, Pointer = 32-bit)
- **Optimization**: -O2 for C programs

These settings are optimized for multicycle cores and typically don't need changing.

## Example Workflows

### Assembly Programming Workflow
1. **Create your assembly program** (e.g., `fibonacci.s`):
```assembly
.section .text
.global _start

_start:
    li x1, 0        # First Fibonacci number
    li x2, 1        # Second Fibonacci number
    li x3, 10       # Counter for 10 iterations
    
loop:
    add x4, x1, x2  # Next Fibonacci number
    mv x1, x2       # Shift values
    mv x2, x4
    addi x3, x3, -1 # Decrement counter
    bnez x3, loop   # Branch if not zero
    
    # End program
    nop
```

2. **Build and analyze**:
```bash
make fibonacci.hex        # Generate hex file
make fibonacci.dis        # Generate disassembly
make fibonacci_all        # Generate all formats
```

3. **Verify size**:
```bash
# Check if it fits in ROM
SIZE_BYTES=$(stat -c%s fibonacci.bin)
echo "Program size: $SIZE_BYTES bytes"
```

### C Programming Workflow
1. **Create your C program** (e.g., `calculator.c`):
```c
int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    int result = 0;
    for (int i = 0; i < b; i++) {
        result = add(result, a);
    }
    return result;
}

int main() {
    int x = 6;
    int y = 7;
    int sum = add(x, y);
    int product = multiply(x, y);
    return product;
}
```

2. **Build and analyze**:
```bash
make calculator_c.hex     # Generate hex file
make calculator_c.dis     # See generated assembly
```

### Multi-Program Project
```bash
# Build multiple programs
make bootloader.hex kernel.hex app1.hex app2.hex

# Analyze all programs
make bootloader.dis kernel.dis app1.dis app2.dis

# Verify all fit in ROM
for prog in bootloader kernel app1 app2; do
    make ${prog}.bin
    SIZE=$(stat -c%s ${prog}.bin)
    echo "$prog: $SIZE bytes"
done
```

## Advanced Features

### Memory Layout Analysis
```bash
# Generate detailed memory information
make program.map         # Section headers
make program.sym         # Symbol table with addresses
objdump -h program.elf   # Detailed section information
```

### Size Optimization
```bash
# Compare different optimization levels
CFLAGS="-march=rv32i -mabi=ilp32 -Os" make program_c.hex  # Size optimization
CFLAGS="-march=rv32i -mabi=ilp32 -O3" make program_c.hex  # Speed optimization
```

### Custom Linker Scripts
Modify `linker.ld` for your specific memory layout:
```ld
MEMORY {
    ROM : ORIGIN = 0x00000000, LENGTH = 8K
    RAM : ORIGIN = 0x10000000, LENGTH = 4K
    IO  : ORIGIN = 0x20000000, LENGTH = 1K
}

SECTIONS {
    .text : { *(.text*) } > ROM
    .data : { *(.data*) } > RAM
    .bss  : { *(.bss*) } > RAM
}
```

### Debugging Support
```bash
# Generate debugging information
make program.dis         # Assembly listing
make program.sym         # Symbol addresses
hexdump -C program.bin   # Raw hex dump
```

## Available Make Targets

### Standard Targets
- `all` - Build default programs (program.s and program.c)
- `test_asm` - Build assembly program with analysis
- `test_c` - Build C program with analysis
- `clean` - Remove build artifacts
- `help` - Show usage information

### Generic Targets (work with any filename)
- `<name>.hex` - Assembly source to Intel HEX
- `<name>.bin` - Assembly source to binary
- `<name>.mem` - Assembly source to Verilog memory
- `<name>.dis` - Generate disassembly
- `<name>.map` - Generate memory map
- `<name>.sym` - Generate symbol table
- `<name>_c.hex` - C source to Intel HEX (requires crt0.s)
- `<name>_all` - Generate all formats for assembly program

### Analysis Targets
- `analyze_asm` - Analyze default assembly program
- `analyze_c` - Analyze default C program
- `verify` - Verify both programs fit in ROM
- `verify_asm` - Verify assembly program size
- `verify_c` - Verify C program size

## Configuration Variables

You can override these when calling make:
```bash
make ROM_SIZE=4096 ARCH=rv32im ABI=ilp32 program.hex
```

- `ROM_SIZE` - Maximum program size in bytes (default: 8192)
- `ARCH` - RISC-V architecture (default: rv32i)
- `ABI` - Application Binary Interface (default: ilp32)
- `PREFIX` - Toolchain prefix (default: riscv64-unknown-elf-)

## File Structure
```
project/
├── Makefile              # This makefile
├── linker.ld            # Memory layout definition
├── crt0.s               # C startup code
├── program.s            # Default assembly source
├── program.c            # Default C source
├── my_program.s         # Custom assembly programs
├── calculator.c         # Custom C programs
├── program_asm.*        # Assembly build outputs
├── program_c.*          # C build outputs
├── my_program.*         # Custom program outputs
└── calculator_c.*       # Custom C program outputs
```

## Getting Help
```bash
# Show comprehensive help
make help

# Show file sizes after building
make test_asm test_c
```

This Makefile provides a complete development environment for RISC-V32I multicycle core programming, supporting everything from simple test programs to complex multi-file projects.