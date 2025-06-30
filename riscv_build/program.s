.section .text
.globl _start

_start:
    # --------- Initialization (addi) ---------
    addi  x1,  x0, 15       # x1 = 15
    addi  x2,  x0, -3       # x2 = -3
    addi  x3,  x0, 7        # x3 = 7
    addi  x4,  x0, 1        # x4 = 1
    
    # --------- ADD / ADDI ----------
    add   x5,  x1, x2       # x5 = 15 + (-3) = 12
    addi  x6,  x1, -5       # x6 = 15 + (-5) = 10
    
    # --------- SUB ----------
    sub   x7,  x1, x2       # x7 = 15 - (-3) = 18
    
    # --------- AND / ANDI ----------
    and   x8,  x1, x3       # x8 = 15 & 7 = 7
    andi  x9,  x1, 5        # x9 = 15 & 5 = 5
    
    # --------- OR / ORI ----------
    or    x10, x1, x3       # x10 = 15 | 7 = 15
    ori   x11, x1, 2        # x11 = 15 | 2 = 15
    
    # --------- XOR / XORI ----------
    xor   x12, x1, x3       # x12 = 15 ^ 7 = 8
    xori  x13, x1, 5        # x13 = 15 ^ 5 = 10
    
    # --------- SLT / SLTI ----------
    slt   x14, x2, x1       # x14 = (-3 < 15) = 1
    slti  x15, x2, 0        # x15 = (-3 < 0) = 1
    
    # --------- SLTU / SLTIU ----------
    sltu  x16, x2, x1       # x16 = 0 (unsigned comparison)
    sltiu x17, x2, 1        # x17 = 0 (unsigned comparison)
    
    # --------- SLL / SLLI ----------
    sll   x18, x1, x4       # x18 = 15 << 1 = 30
    slli  x19, x1, 2        # x19 = 15 << 2 = 60
    
    # --------- SRL / SRLI ----------
    srl   x20, x1, x4       # x20 = 15 >> 1 = 7
    srli  x21, x1, 2        # x21 = 15 >> 2 = 3
    
    # --------- SRA / SRAI ----------
    sra   x22, x2, x4       # x22 = -3 >> 1 = -2 (arithmetic)
    srai  x23, x2, 2        # x23 = -3 >> 2 = -1 (arithmetic)

    # --------- BRANCH INSTRUCTIONS ----------
    # Test BEQ (Branch if Equal)
    addi  x24, x0, 10       # x24 = 10
    addi  x25, x0, 10       # x25 = 10
    beq   x24, x25, equal_branch    # Should branch since 10 == 10
    addi  x26, x0, 99       # This should be skipped
    
equal_branch:
    addi  x26, x0, 1        # x26 = 1 (executed if branch taken)
    
    # Test BNE (Branch if Not Equal)
    bne   x1, x2, not_equal_branch  # Should branch since 15 != -3
    addi  x27, x0, 99       # This should be skipped
    
not_equal_branch:
    addi  x27, x0, 2        # x27 = 2 (executed if branch taken)
    
    # Test BLT (Branch if Less Than)
    blt   x2, x1, less_than_branch  # Should branch since -3 < 15
    addi  x28, x0, 99       # This should be skipped
    
less_than_branch:
    addi  x28, x0, 3        # x28 = 3 (executed if branch taken)
    
    # Test BGE (Branch if Greater or Equal)
    bge   x1, x2, greater_equal_branch  # Should branch since 15 >= -3
    addi  x29, x0, 99       # This should be skipped
    
greater_equal_branch:
    addi  x29, x0, 4        # x29 = 4 (executed if branch taken)
    
    # Test BLTU (Branch if Less Than Unsigned)
    bltu  x4, x1, less_than_unsigned_branch  # Should branch since 1 < 15 (unsigned)
    addi  x30, x0, 99       # This should be skipped
    
less_than_unsigned_branch:
    addi  x30, x0, 5        # x30 = 5 (executed if branch taken)
    
    # Test BGEU (Branch if Greater or Equal Unsigned)
    bgeu  x1, x4, greater_equal_unsigned_branch  # Should branch since 15 >= 1 (unsigned)
    addi  x31, x0, 99       # This should be skipped
    
greater_equal_unsigned_branch:
    addi  x31, x0, 6        # x31 = 6 (executed if branch taken)

    # --------- JAL INSTRUCTION ----------
    # JAL saves PC+4 to rd and jumps to target
    jal   x1, function1     # Save return address in x1, jump to function1
    addi  x5, x5, 100       # This executes after function1 returns
    
    # --------- JALR INSTRUCTION ----------  
    # Set up for JALR demonstration
    addi  x6, x0, 0         # Clear x6 for use as base
    la    x7, function2     # Load address of function2 into x7
    jalr  x2, x7, 0         # Save PC+4 in x2, jump to address in x7+0
    addi  x8, x8, 200       # This executes after function2 returns
    
    # Jump to end
    jal   x0, end_program   # Unconditional jump to end

# --------- FUNCTION DEFINITIONS ----------
function1:
    addi  x10, x0, 42       # x10 = 42 (some work in function1)
    addi  x11, x11, 1       # Increment x11
    jalr  x0, x1, 0         # Return using address in x1

function2:
    addi  x12, x0, 84       # x12 = 84 (some work in function2)  
    addi  x13, x13, 2       # Increment x13
    jalr  x0, x2, 0         # Return using address in x2

end_program:
    # --------- Infinite Loop ----------
    beq   x0, x0, end_program   # Infinite loop (always branch)