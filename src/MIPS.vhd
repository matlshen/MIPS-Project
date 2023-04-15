library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.MIPS_LIB.all;

entity MIPS is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        InPortSwitches  : in std_logic_vector(9 downto 0);
        OutPort         : out std_logic_vector(31 downto 0);
    )
end MIPS;

architecture STR of MIPS is
    signal InPort      : std_logic_vector(31 downto 0);
    signal OutPort     : std_logic_vector(31 downto 0);
    signal InPort_en   : std_logic_vector(1 downto 0);
    signal InPort1_en  : std_logic;
    signal InPort0_en  : std_logic;

    signal PCWriteCond : std_logic; -- enables the PC register if the “Branch” signal is asserted. Input to the datapath, output from the controller.
    signal PCWrite     : std_logic; -- enables the PC register. Input to the datapath, output from the controller.
    signal IorD        : std_logic; -- select between the PC or the ALU output as the memory address. Input to the datapath, output from the controller.
    signal MemRead     : std_logic; -- enables memory read. Input to the datapath, output from the controller.
    signal MemWrite    : std_logic; -- enables memory write. Input to the datapath, output from the controller.
    signal MemToReg    : std_logic_vector(1 downto 0); -- select between “Memory data register” or “ALU output” as input to “write data” signal. Input to the datapath, output from the controller.
    signal IRWrite     : std_logic; -- enables the instruction register. Input to the datapath, output from the controller.
    signal JumpAndLink : std_logic; -- when asserted, $s31 will be selected as the write register. Input to the datapath, output from the controller.
    signal IsSigned    : std_logic; -- when asserted, “Sign Extended” will output a 32-bit sign extended representation of 16-bit input. Input to the datapath, output from the controller.
    signal PCSource    : std_logic_vector(1 downto 0); -- select between the “ALU output”, “ALU OUT Reg”, or a “shifted to left PC” as an input to PC. Input to the datapath, output from the controller.
    signal ALUSrcA     : std_logic; -- select between RegA or Pc as the Input1 of the ALU. Input to the datapath, output from the controller.
    signal ALUSrcB     : std_logic_vector(1 downto 0); -- select between RegB, “4”, IR15-0, or “shifted IR15-0” as the Input2 of the ALU. Input to the datapath, output from the controller.
    signal RegWrite    : std_logic; -- enables the register file. Input to the datapath, output from the controller.
    signal RegDst      : std_logic; -- select between IR20-16 or IR15-11 as the input to the “Write Reg”. Input to the datapath, output from the controller.
    signal IR31downto26: std_logic_vector(5 downto 0); -- IR31-26 (the OPCode): Will be decoded by the controller to determine what instruction to execute. Input to the CONTROLLER, output from the datapath.
    signal IR5downto0: std_logic_vector(5 downto 0);

    signal OpSelect  : std_logic_vector(ALU_SEL_SIZE-1 downto 0);
    signal IR20downto16 : std_logic_vector(4 downto 0);

    signal HI_en       : std_logic;
    signal LO_en       : std_logic;
    signal ALU_LO_HI   : std_logic_vector(1 downto 0);
begin --STR
    U_DATAPATH : entity work.datapath
        port map (
            -- Top Level / Interface
            clk             => clk,
            rst             => rst,
            InPort0_en      => InPort0_en,
            InPort1_en      => InPort1_en,
            InPortSwitches  => InPortSwitches,
            OutPort         => OutPort,
            -- Controller
            PCWriteCond     => PCWriteCond,
            PCWrite         => PCWrite,
            IorD            => IorD,
            MemRead         => MemRead,
            MemWrite        => MemWrite,
            MemToReg        => MemToReg,
            IRWrite         => IRWrite,
            JumpAndLink     => JumpAndLink,
            IsSigned        => IsSigned,
            PCSource        => PCSource,
            ALUOp           => ALUOp,
            ALUSrcB         => ALUSrcB,
            ALUSrcA         => ALUSrcA,
            RegWrite        => RegWrite,
            RegDst          => RegDst,
            IR31downto26    => IR31downto26,
            -- ALU Control
            HI_en           => HI_en,
            LO_en           => LO_en,
            ALU_LO_HI       => ALU_LO_HI,
            IR5downto0      => IR5downto0);

    U_CONTROLLER : entity work.controller
        port (
            clk             => clk,
            rst             => rst,
            -- Datapath 
            IR31downto26    => IR31downto26,
            IR5downto0      => IR5downto0,
            PCWriteCond     => PCWriteCond,
            PCWrite         => PCWrite,
            IorD            => IorD,
            MemRead         => MemRead,
            MemWrite        => MemWrite,
            MemToReg        => MemToReg,
            IRWrite         => IRWrite,
            JumpAndLink     => JumpAndLink,
            IsSigned        => IsSigned,
            PCSource        => PCSource,
            OPSelect        => OpSelect,
            ALUSrcB         => ALUSrcB,
            ALUSrcA         => ALUSrcA,
            RegWrite        => RegWrite,
            RegDst          => RegDst);

    U_ALU
end STR;