# RISC-V32I Fibonacci Series Program (n=10)
# Calculates first 10 Fibonacci numbers and stores them in safe memory location
.section .text
.globl _start
_start:
    # Initialize base address for data storage (safe location after program)
    la  x5, data_section    # x5 = address of data_section (safe location)
    
    # Initialize Fibonacci variables
    add x1, x0, x0          # x1 = 0 (F(0))
    addi x2, x0, 1          # x2 = 1 (F(1))
    
    # Store first two Fibonacci numbers
    sw  x1, 0(x5)           # Store F(0) = 0 at data_section
    sw  x2, 4(x5)           # Store F(1) = 1 at data_section + 4
    
    # Initialize counter and loop variables
    addi x3, x0, 2          # x3 = 2 (counter, starting from F(2))
    addi x4, x0, 10         # x4 = 10 (target count)
    addi x6, x0, 8          # x6 = 8 (memory offset, starting at data_section + 8)
    
fib_loop:
    # Check if we've calculated n numbers
    sub x7, x3, x4          # x7 = counter - target
    beq x7, x0, end_fib     # If counter == target, exit loop
    
    # Calculate next Fibonacci number
    add x8, x1, x2          # x8 = F(n-2) + F(n-1) = F(n)
    
    # Store current Fibonacci number
    add x9, x5, x6          # x9 = data_section + offset
    sw  x8, 0(x9)           # Store F(n) at current address
    
    # Update for next iteration
    add x1, x2, x0          # x1 = previous F(n-1) becomes new F(n-2)
    add x2, x8, x0          # x2 = current F(n) becomes new F(n-1)
    addi x3, x3, 1          # Increment counter
    addi x6, x6, 4          # Move to next memory location (4 bytes)
    
    jal x0, fib_loop        # Jump back to loop
    
end_fib:
    # Display results by loading them back (optional verification)
    # Load and display first few Fibonacci numbers from safe location
    lw  x10, 0(x5)          # Load F(0) from data_section
    lw  x11, 4(x5)          # Load F(1) from data_section + 4
    lw  x12, 8(x5)          # Load F(2) from data_section + 8
    lw  x13, 12(x5)         # Load F(3) from data_section + 12
    lw  x14, 16(x5)         # Load F(4) from data_section + 16
    
    # Infinite loop to end program
halt:
    jal x0, halt            # Infinite loop

.section .data
data_section:
    # Reserve space for 10 Fibonacci numbers in safe memory location
    .word 0x00000000        # Space for F(0)
    .word 0x00000000        # Space for F(1)
    .word 0x00000000        # Space for F(2)
    .word 0x00000000        # Space for F(3)
    .word 0x00000000        # Space for F(4)
    .word 0x00000000        # Space for F(5)
    .word 0x00000000        # Space for F(6)
    .word 0x00000000        # Space for F(7)
    .word 0x00000000        # Space for F(8)
    .word 0x00000000        # Space for F(9)

# Alternative approach using immediate address (if you know the memory layout):
# You could also replace 'la x5, data_section' with:
# lui x5, 0x10000         # Load upper immediate (example: 0x10000000)
# This would place data at address 0x10000000, far from program code

# Expected Fibonacci sequence for n=10:
# F(0) = 0, F(1) = 1, F(2) = 1, F(3) = 2, F(4) = 3
# F(5) = 5, F(6) = 8, F(7) = 13, F(8) = 21, F(9) = 34

# Memory layout after execution (starting at data_section address):
# data_section + 0x00: 0x00000000 (F(0) = 0)
# data_section + 0x04: 0x00000001 (F(1) = 1)
# data_section + 0x08: 0x00000001 (F(2) = 1)
# data_section + 0x0C: 0x00000002 (F(3) = 2)
# data_section + 0x10: 0x00000003 (F(4) = 3)
# data_section + 0x14: 0x00000005 (F(5) = 5)
# data_section + 0x18: 0x00000008 (F(6) = 8)
# data_section + 0x1C: 0x0000000D (F(7) = 13)
# data_section + 0x20: 0x00000015 (F(8) = 21)
# data_section + 0x24: 0x00000022 (F(9) = 34)