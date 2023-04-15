library ieee;
use ieee.std_logic_1164.all;

package MIPS_FUNC_LIB is
    --IR[5:0]
    constant FUNC_SLL   : unsigned(7 downto 0) := x"00";
    constant FUNC_SRL   : unsigned(7 downto 0) := x"02";
    constant FUNC_SRA   : unsigned(7 downto 0) := x"03";
    constant FUNC_MULT  : unsigned(7 downto 0) := x"18";
    constant FUNC_MULTU : unsigned(7 downto 0) := x"19";
    constant FUNC_ADDU  : unsigned(7 downto 0) := x"21";
    constant FUNC_SUBU  : unsigned(7 downto 0) := x"23";
    constant FUNC_AND   : unsigned(7 downto 0) := x"24";
    constant FUNC_OR    : unsigned(7 downto 0) := x"25";
    constant FUNC_XOR   : unsigned(7 downto 0) := x"26";
    constant FUNC_SLT   : unsigned(7 downto 0) := x"2A";
    constant FUNC_SLTU  : unsigned(7 downto 0) := x"2B";
    --IR[31:26]
    constant OP_ADDIU   : unsigned(7 downto 0) := x"09";
    constant OP_SUBIU   : unsigned(7 downto 0) := x"10";
    constant OP_SLTI    : unsigned(7 downto 0) := x"0A";
    constant OP_SLTIU   : unsigned(7 downto 0) := x"0B";
    constant OP_ANDI    : unsigned(7 downto 0) := x"0C";
    constant OP_ORI     : unsigned(7 downto 0) := x"0D";
    constant OP_XORI    : unsigned(7 downto 0) := x"0E";
    constant OP_LW      : unsigned(7 downto 0) := x"23";
    constant OP_SW      : unsigned(7 downto 0) := x"2B";
end MIPS_FUNC_LIB;