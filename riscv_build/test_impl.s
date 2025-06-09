# RISC-V32I Instruction Test Suite
# Tests: lw, sw, add, addi, jal, la instructions
# Stores test results for verification

.section .text
.globl _start

_start:
    # Initialize test data address using la (Load Address)
    la  x5, test_data       # x5 = base address for test data
    
    # ===========================================
    # TEST 1: ADDI (Add Immediate) Instruction
    # ===========================================
    addi x1, x0, 42         # x1 = 0 + 42 = 42
    addi x2, x1, 8          # x2 = 42 + 8 = 50
    addi x3, x2, -10        # x3 = 50 + (-10) = 40
    
    # Store ADDI test results
    sw  x1, 0(x5)           # Store 42 at test_data + 0
    sw  x2, 4(x5)           # Store 50 at test_data + 4
    sw  x3, 8(x5)           # Store 40 at test_data + 8
    
    # ===========================================
    # TEST 2: ADD Instruction
    # ===========================================
    addi x6, x0, 15         # x6 = 15
    addi x7, x0, 25         # x7 = 25
    add  x8, x6, x7         # x8 = 15 + 25 = 40
    add  x9, x8, x1         # x9 = 40 + 42 = 82
    add  x10, x0, x0        # x10 = 0 + 0 = 0 (test with zero)
    
    # Store ADD test results
    sw  x8, 12(x5)          # Store 40 at test_data + 12
    sw  x9, 16(x5)          # Store 82 at test_data + 16
    sw  x10, 20(x5)         # Store 0 at test_data + 20
    
    # ===========================================
    # TEST 3: SW (Store Word) Instruction
    # ===========================================
    addi x11, x0, 100       # x11 = 100
    addi x12, x0, 200       # x12 = 200
    addi x13, x0, 300       # x13 = 300
    
    # Test different offsets with sw
    sw  x11, 24(x5)         # Store 100 at test_data + 24
    sw  x12, 28(x5)         # Store 200 at test_data + 28
    sw  x13, 32(x5)         # Store 300 at test_data + 32
    
    # Test sw with register offset calculation
    addi x14, x0, 36        # x14 = 36 (offset)
    add  x15, x5, x14       # x15 = base + offset
    addi x16, x0, 999       # x16 = 999
    sw  x16, 0(x15)         # Store 999 at test_data + 36
    
    # ===========================================
    # TEST 4: Call subroutine using JAL
    # ===========================================
    jal x1, test_subroutine # Call subroutine, x1 = return address
    
    # After return from subroutine
    addi x17, x0, 777       # x17 = 777 (to verify we returned)
    sw  x17, 44(x5)         # Store 777 at test_data + 44
    
    # ===========================================
    # TEST 5: LW (Load Word) Verification
    # ===========================================
    # Load back all stored values to verify sw/lw work correctly
    lw  x18, 0(x5)          # Load first ADDI result (should be 42)
    lw  x19, 4(x5)          # Load second ADDI result (should be 50)
    lw  x20, 8(x5)          # Load third ADDI result (should be 40)
    lw  x21, 12(x5)         # Load first ADD result (should be 40)
    lw  x22, 16(x5)         # Load second ADD result (should be 82)
    lw  x23, 20(x5)         # Load third ADD result (should be 0)
    lw  x24, 24(x5)         # Load first SW test (should be 100)
    lw  x25, 28(x5)         # Load second SW test (should be 200)
    lw  x26, 32(x5)         # Load third SW test (should be 300)
    lw  x27, 36(x5)         # Load offset SW test (should be 999)
    lw  x28, 40(x5)         # Load subroutine result (should be 555)
    lw  x29, 44(x5)         # Load post-subroutine value (should be 777)
    
    # ===========================================
    # TEST 6: Complex Address Calculation Test
    # ===========================================
    # Test la with different addressing modes
    la  x30, complex_data   # Load address of complex_data
    addi x31, x0, 1111      # x31 = 1111
    sw  x31, 0(x30)         # Store at complex_data
    lw  x31, 0(x30)         # Load it back to verify
    
    # Final test: add loaded values
    add x1, x18, x19        # x1 = 42 + 50 = 92
    add x2, x21, x22        # x2 = 40 + 82 = 122
    sw  x1, 48(x5)          # Store final test 1
    sw  x2, 52(x5)          # Store final test 2
    
    jal x0, end_program     # Jump to end (infinite loop)

# ===========================================
# SUBROUTINE: Test JAL instruction
# ===========================================
test_subroutine:
    # This subroutine tests that jal works correctly
    addi x4, x0, 555        # x4 = 555
    sw  x4, 40(x5)          # Store 555 at test_data + 40
    
    # Return to caller using jalr (return address is in x1)
    jalr x0, 0(x1)          # Return to address in x1

# ===========================================
# END PROGRAM
# ===========================================
end_program:
    # Infinite loop to halt execution
    jal x0, end_program

.section .data
test_data:
    # Reserve space for test results (14 words = 56 bytes)
    .word 0x00000000        # +0:  ADDI test 1 (expected: 42)
    .word 0x00000000        # +4:  ADDI test 2 (expected: 50)  
    .word 0x00000000        # +8:  ADDI test 3 (expected: 40)
    .word 0x00000000        # +12: ADD test 1 (expected: 40)
    .word 0x00000000        # +16: ADD test 2 (expected: 82)
    .word 0x00000000        # +20: ADD test 3 (expected: 0)
    .word 0x00000000        # +24: SW test 1 (expected: 100)
    .word 0x00000000        # +28: SW test 2 (expected: 200)
    .word 0x00000000        # +32: SW test 3 (expected: 300)
    .word 0x00000000        # +36: SW offset test (expected: 999)
    .word 0x00000000        # +40: Subroutine test (expected: 555)
    .word 0x00000000        # +44: Post-subroutine (expected: 777)
    .word 0x00000000        # +48: Final test 1 (expected: 92)
    .word 0x00000000        # +52: Final test 2 (expected: 122)

complex_data:
    .word 0x00000000        # Complex addressing test (expected: 1111)

# ===========================================
# EXPECTED MEMORY LAYOUT AFTER EXECUTION:
# ===========================================
# test_data + 0x00: 0x0000002A (42 decimal)
# test_data + 0x04: 0x00000032 (50 decimal)
# test_data + 0x08: 0x00000028 (40 decimal)
# test_data + 0x0C: 0x00000028 (40 decimal)
# test_data + 0x10: 0x00000052 (82 decimal)
# test_data + 0x14: 0x00000000 (0 decimal)
# test_data + 0x18: 0x00000064 (100 decimal)
# test_data + 0x1C: 0x000000C8 (200 decimal)
# test_data + 0x20: 0x0000012C (300 decimal)
# test_data + 0x24: 0x000003E7 (999 decimal)
# test_data + 0x28: 0x0000022B (555 decimal)
# test_data + 0x2C: 0x00000309 (777 decimal)
# test_data + 0x30: 0x0000005C (92 decimal)
# test_data + 0x34: 0x0000007A (122 decimal)
# complex_data:     0x00000457 (1111 decimal)

# ===========================================
# REGISTER STATE AT END (for verification):
# ===========================================
# x1:  return address from jal + final add result (92)
# x2:  final add result (122)
# x5:  address of test_data
# x18: 42 (loaded from memory)
# x19: 50 (loaded from memory)
# x20: 40 (loaded from memory)
# x21: 40 (loaded from memory)
# x22: 82 (loaded from memory)
# x23: 0 (loaded from memory)
# x24: 100 (loaded from memory)
# x25: 200 (loaded from memory)
# x26: 300 (loaded from memory)
# x27: 999 (loaded from memory)
# x28: 555 (loaded from memory)
# x29: 777 (loaded from memory)
# x30: address of complex_data
# x31: 1111 (loaded back from complex_data)

# ===========================================
# INSTRUCTION COVERAGE:
# ===========================================
# ✓ ADDI: Tested with positive, negative, and zero values
# ✓ ADD:  Tested with various register combinations
# ✓ SW:   Tested with different offsets and addressing modes
# ✓ LW:   Tested by loading back all stored values
# ✓ JAL:  Tested with subroutine call and return
# ✓ LA:   Tested with label address loading
