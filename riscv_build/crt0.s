# C Runtime Startup for RISC-V32I Multicycle Core
# Save as: crt0.s

.section .text
.globl _start

_start:
    # Initialize stack pointer
    lui sp, %hi(_stack_top)
    addi sp, sp, %lo(_stack_top)
    
    # Clear BSS section
    lui t0, %hi(_bss_start)
    addi t0, t0, %lo(_bss_start)
    lui t1, %hi(_bss_end)
    addi t1, t1, %lo(_bss_end)
    
bss_clear_loop:
    # Check if we're done
    sub t2, t1, t0
    beq t2, zero, bss_clear_done
    
    # Clear word and advance
    sw zero, 0(t0)
    addi t0, t0, 4
    jal zero, bss_clear_loop
    
bss_clear_done:
    # Call main function
    jal ra, main
    
    # If main returns, loop forever
end_loop:
    jal zero, end_loop
