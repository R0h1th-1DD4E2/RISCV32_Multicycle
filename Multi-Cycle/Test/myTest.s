#Test all instructions of rv32i isa for RISC-V processor:
#Instructions                                   #Calculation                    #PC         #Note

# I type instruction related to register file
main:       addi    x1, x0, 1                   # x1 = 1                        0           #initialized reg 1
            addi    x2, x0, 16                  # x2 = 16                       4           #initialized reg 2
            addi    x3, x0, -3                  # x3 = -3                       8           #initialized reg 3
            addi    x4, x0, 0                   # x4 = 0                        C           #reg for status

            addi    x5, x3, 12                  # x5 = (-3+12) = 9              10
          //  slli    x6, x2, 2                   # x6 = (16 << 2) = 64           14
            slti    x7, x2, -16                 # x7 = (16 > -16) = 0           18
           // sltiu   x8, x2, -16                 # x8 = (u(16) < u(-16))= 1      1C
           // xori    x9, x2, 18                  # x9 = (16 XOR 18) = 2          20
           // srli    x10,x3, 3                   # x10= (-3 >>3) = 536870911     24          #sign changed
           // srai    x11,x3, 3                   # x11= (-3 >>> 3) = -1          28          #sign not changed
            ori     x12,x3, 3                   # x12= (-3 | 3) = -1            2c
            andi    x13,x3, 3                   # x13= (-3 & 3) = 1             30

            # R type instructions
            add     x14, x2, x1                 # x14= (16 + 1) = 17            34
            sub     x15, x2, x1                 # x15= (16 - 1) = 15            38
           // sll     x16, x2, x1                 # x16= (16 << 1) = 32           3c
            slt     x17, x2, x3                 # x17= (16 > -3) = 0            40
           // sltu    x18, x2, x3                 # x18= (u(16) < u(-3)) = 1      44
            // xor     x19, x2, x1                 # x19= (16 XOR 1) = 17          48
            // srl     x20, x2, x1                 # x20= (16 >> 1) = 8            4C
            // sra     x21, x2, x1                 # x21= (16 >>> 1) = 8           50
            or      x22, x2, x1                # x22= (16 OR 1) = 17            54
            and     x23, x2, x1                 # x23= (16 AND 1) = 0           58
