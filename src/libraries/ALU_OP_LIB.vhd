library ieee;
use ieee.std_logic_1164.all;

package ALU_OP_LIB is
    type ALU_OP_t is
        (ALU_ADDU, ALU_SUBU, ALU_MULT, ALU_MULTU,
        ALU_AND, ALU_OR, ALU_XOR, ALU_SRL,
        ALU_SLL, ALU_SRA, ALU_SLT, ALU_SLTU,
        ALU_BEQ, ALU_BNE, ALU_BLEZ, ALU_BGEZ,
        ALU_BLTZ, ALU_BGTZ);
end ALU_OP_LIB;