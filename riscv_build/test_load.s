    .section .text
    .globl _start

_start:
    # Load immediate values into registers
    addi x1, x0, 8     # x1 = 8
    addi x2, x0, 4     # x2 = 4

    # Store to memory
    addi x3, x0, 0      # x3 = 0 (base address)
    sw   x1, 0(x3)      # store x1 (5) at mem[0]
    sw   x2, 4(x3)      # store x2 (10) at mem[4]

    # Load from memory
    lw   x4, 0(x1)      # x4 = mem[8] → 4
    lw   x5, 4(x2)      # x5 = mem[ ] → 8

end:
    bne x6, x0, end     # infinite loop to stop CPU
