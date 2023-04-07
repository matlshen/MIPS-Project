library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity datapath is
    port (
        clk             : in std_logic;
        rst             : in std_logic;

        InPort0         : in std_logic_vector(31 downto 0);
        InPort1         : in std_logic_vector(31 downto 0); -- TODO: fix these
        PCWriteCond     : in std_logic;
        PCWrite         : in std_logic;
        IorD            : in std_logic;
        MemRead         : in std_logic;
        MemWrite        : in std_logic;
        MemToReg        : in std_logic;
        IRWrite         : in std_logic;
        JumpAndLink     : in std_logic;
        IsSigned        : in std_logic;
        PCSource        : in std_logic;
        ALUOp           : in ALU_OP;
        ALUSrcB         : in std_logic_vector(1 downto 0);
        ALUSrcA         : in std_logic;
        RegWrite        : in std_logic;
        RegDest         : in std_logic;

        ALUOPSel        : in ALU_OP_t;
        HI_en           : in std_logic;
        LO_en           : in std_logic;
        ALU_LO_HI       : in std_logic_vector(1 downto 0);

        IR31downto26    : out std_logic_vector(5 downto 0);
        IR5downto0      : out std_logic_vector(5 downto 0);
        OutPort         : out std_logic_vector(31 downto 0);
    )
end datapath;

architecture str of datapath is
    signal PC           : std_logic_vector(31 downto 0);    -- Output from program counter register
    signal MemAddrSel   : std_lgoic_vector(31 downto 0);    -- Selection between PC and ALUOutSel
    signal MemData      : std_logic_vector(31 downto 0);    -- Output from main memory
    signal IR           : std_logic_vector(31 downto 0);    -- Output from instruction register
    signal MemDataReg   : std_logic_vector(31 downto 0);    -- Output from memory data register

    signal WriteReg     : std_logic_vector(4 downto 0);     -- Selection between IR[20:16] and IR[15:11]
    signal WriteData    : std_logic_vector(31 downto 0);    -- Selection between ALUOutSel and MemData
    signal ReadData     : std_logic_vector(63 downto 0);    -- Output from registers file
    signal RegA         : std_logic_vector(31 downto 0);    -- Output from Reg A
    signal RegB         : std_logic_vector(31 downto 0);    -- Output from Reg B

    signal ALUInput0    : std_logic_vector(31 downto 0);    -- Selection between PC and Reg A
    signal ALUInput1    : std_logic_vector(31 downto 0);    -- Selection between Reg B, 4, IR[15:0], shift left
    signal ALUResult    : std_logic_vector(31 downto 0);    -- ALU result output
    signal ALUResultHi  : std_logic_vector(31 downto 0);    -- Hi bytes of ALU result output
    signal BranchTaken  : std_logic;                        -- ALU branch output
    signal ALUOutReg    : std_logic_vector(31 downto 0);    -- Output from ALU Out Reg
    signal LOReg        : std_logic_vector(31 downto 0);    -- Output from LO Reg
    signal HIReg        : std_logic_vector(31 downto 0);    -- Output from HI Reg



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

    U_PROGRAM_COUNTER : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => PC_en,
            input   => PCInput,
            output  => PC);

    PC_en <= ((BranchTaken and PCWriteCond) or PCWrite);

end str;