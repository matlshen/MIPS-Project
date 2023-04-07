library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity datapath is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        InPort0     : in std_logic_vector(31 downto 0);
        InPort1     : in std_logic_vector(31 downto 0); -- TODO: fix these
        PCWriteCond : in std_logic;
        PCWrite     : in std_logic;
        IorD        : in std_logic;
        MemRead     : in std_logic;
        MemWrite    : in std_logic;
        MemToReg    : in std_logic;
        IRWrite     : in std_logic;
        JumpAndLink : in std_logic;
        IsSigned    : in std_logic;
        PCSource    : in std_logic;
        ALUOp       : in ALU_OP;
        ALUSrcB     : in std_logic_vector(1 downto 0);
        ALUSrcA     : in std_logic;
        RegWrite    : in std_logic;
        RegDest     : in std_logic;
    )
end datapath;

architecture str of datapath is
    signal PC           : std_logic_vector(31 downto 0);    -- Program counter register
    signal IR           : std_logic_vector(31 downto 0);    -- Instruction register

    component REG is
        generic (
            WIDTH : positive);
        port (
            clk    : in std_logic;
            rst    : in std_logic;
            en     : in std_logic;
            input  : in std_logic_vector(WIDTH-1 downto 0);
            output : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component MUX_2x1 is
        generic (
            WIDTH : positive);
        port(
            in0    : in std_logic_vector(WIDTH-1 downto 0);
            in1    : in std_logic_vector(WIDTH-1 downto 0);
            sel    : in std_logic;
            output : out std_logic_vector(WIDTH-1 downto 0));
    end component;

    component MUX_4x1 is
        generic (
            WIDTH : positive);
        port(
            in0    : in std_logic_vector(WIDTH-1 downto 0);
            in1    : in std_logic_vector(WIDTH-1 downto 0);
            in2    : in std_logic_vector(WIDTH-1 downto 0);
            in3    : in std_logic_vector(WIDTH-1 downto 0);
            sel    : in std_logic_vector(1 downto 0);
            output : out std_logic_vector(WIDTH-1 downto 0));
    end component;

begin --str
end str;;