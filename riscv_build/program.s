# Test programs
# Test Assembly Program for RISC-V32I Multicycle Core
.section .text
.globl _start

_start:
    # Initialize base address
    add x5, x0, x0          # x5 = 0
    
    # Simple load-compute-store test
    lw  x1, 0(x5)           # Load from address 0
    lw  x2, 4(x5)           # Load from address 4
    
    # Arithmetic operations
    add x3, x1, x2          # x3 = x1 + x2
    sub x4, x1, x2          # x4 = x1 - x2
    add x6, x3, x4          # x6 = x3 + x4
    
    # Store results
    sw  x3, 8(x5)           # Store sum
    sw  x4, 12(x5)          # Store difference
    sw  x6, 16(x5)          # Store final result
    
    # Simple loop counter test
    add x7, x0, x0          # x7 = 0 (counter)
    
loop:
    addi x7, x7, 1          # x7++
    sw  x7, 20(x5)          # Store counter
    
    # Simple delay loop
    add x8, x0, x0          # x8 = 0
delay:
    addi x8, x8, 1          # x8++
    sub x9, x8, x7          # Compare with counter
    bne x9, zero, delay     # Continue delay if not equal
    
    jal x0, loop            # Infinite loop

.section .data
    .word 0x12345678        # Test data
    .word 0x87654321        # Test data
    .word 0x00000000        # Space for results
    .word 0x00000000
    .word 0x00000000
    .word 0x00000000        # Space for counter
