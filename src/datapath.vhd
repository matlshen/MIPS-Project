library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity datapath is
    port (
        -- Top Level / Interface
        clk             : in std_logic;
        rst             : in std_logic;
        InPort0_en      : in std_logic;
        InPort1_en      : in std_logic;
        InPortSwitches  : in std_logic_vector(9 downto 0);  -- Before zero extension
        OutPort         : out std_logic_vector(31 downto 0);
        -- Controller
        PCWriteCond     : in std_logic;
        PCWrite         : in std_logic;
        IorD            : in std_logic;
        MemRead         : in std_logic;
        MemWrite        : in std_logic;
        MemToReg        : in std_logic;
        IRWrite         : in std_logic;
        JumpAndLink     : in std_logic;
        IsSigned        : in std_logic;
        PCSource        : in std_logic_vector(1 downto 0);
        ALUSrcB         : in std_logic_vector(1 downto 0);
        ALUSrcA         : in std_logic_vector(1 downto 0);
        RegWrite        : in std_logic;
        RegDst          : in std_logic;
        IR31downto26    : out std_logic_vector(5 downto 0);
        -- ALU Control
        OPSelect        : in ALU_OP_t;
        HI_en           : in std_logic;
        LO_en           : in std_logic;
        ALU_LO_HI       : in std_logic_vector(1 downto 0);
        IR5downto0      : out std_logic_vector(5 downto 0));
    end datapath;

architecture str of datapath is
    signal PCSrcIn2     : std_logic_vector(31 downto 0);    -- In2 of PC Src select MUX
    signal PCInput      : std_logic_vector(31 downto 0);    -- Selection between ALUResult, ALUOutReg, IR&PC
    signal PC           : std_logic_vector(31 downto 0);    -- Output from program counter register
    signal PC_en        : std_logic;                        -- Combinational logic from controller
    signal MemAddrSel   : std_logic_vector(31 downto 0);    -- Selection between PC and ALUOutSel
    signal MemData      : std_logic_vector(31 downto 0);    -- Output from main memory
    signal InPort       : std_logic_vector(31 downto 0);    -- Zero extended switch input
    signal IR           : std_logic_vector(31 downto 0);    -- Output from instruction register
    signal MemDataReg   : std_logic_vector(31 downto 0);    -- Output from memory data register

    signal WriteReg     : std_logic_vector(4 downto 0);     -- Selection between IR[20:16] and IR[15:11]
    signal WriteData    : std_logic_vector(31 downto 0);    -- Selection between ALUOutSel and MemData
    signal ReadData1    : std_logic_vector(31 downto 0);    -- Output from registers file
    signal ReadData2    : std_logic_vector(31 downto 0);    -- Output from registers file
    signal RegA         : std_logic_vector(31 downto 0);    -- Output from Reg A
    signal RegB         : std_logic_vector(31 downto 0);    -- Output from Reg B
    signal IR15_0Extend : std_logic_vector(31 downto 0);    -- Sign extend output for IR[15:0]
    signal IR25_21Extend: std_logic_vector(31 downto 0);    -- Zero extend IR[25:21]

    signal ALUInput0    : std_logic_vector(31 downto 0);    -- Selection between PC and Reg A
    signal ALUInput1    : std_logic_vector(31 downto 0);    -- Selection between Reg B, 4, IR[15:0], shift left
    signal ALUSrcBIn3   : std_logic_vector(31 downto 0);    -- In3 of ALU Src B MUX
    signal ALUResult    : std_logic_vector(31 downto 0);    -- ALU result output
    signal ALUResultHi  : std_logic_vector(31 downto 0);    -- Hi bytes of ALU result output
    signal BranchTaken  : std_logic;                        -- ALU branch output
    signal ALUOutReg    : std_logic_vector(31 downto 0);    -- Output from ALU Out Reg
    signal LOReg        : std_logic_vector(31 downto 0);    -- Output from LO Reg
    signal HIReg        : std_logic_vector(31 downto 0);    -- Output from HI Reg
    signal ALUOutSel    : std_logic_vector(31 downto 0);    -- Selection between ALUOutReg, LOReg, HIReg

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

    component SIGN_EXTEND is
        generic (
            IN_WIDTH  : natural;
            OUT_WIDTH : natural);
        port (
            IsSigned : in  std_logic;
            input    : in  std_logic_vector(IN_WIDTH-1  downto 0);
            output   : out std_logic_vector(OUT_WIDTH-1 downto 0));
    end component;

    component MEMORY is
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            -- From datapath
            addr      : in  std_logic_vector(31 downto 0);
            RdData    : out std_logic_vector(31 downto 0);
            WrData    : in  std_logic_vector(31 downto 0);
            -- From Controller
            MemRead   : in std_logic;
            MemWrite  : in std_logic;
            -- From Top Level / Interface
            InPort1_en : in  std_logic;
            InPort0_en : in  std_logic;
            InPort     : in  std_logic_vector(31 downto 0); -- InPort0/InPort1
            OutPort    : out std_logic_vector(31 downto 0)
        );
    end component;

    component REGISTERS_FILE is 
        port (
            clk           : in std_logic;
            rst           : in std_logic;
            RegWrite      : in std_logic;                       -- Write enable from controller
            JumpAndLink   : in std_logic;                       -- From controller
    
            ReadReg1      : in std_logic_vector(4 downto 0);    -- Read address 1
            ReadReg2      : in std_logic_vector(4 downto 0);    -- Read address 2
            WriteRegister : in std_logic_vector(4 downto 0);    -- Write address
            WriteData     : in std_logic_vector(31 downto 0);   -- Write data
    
            ReadData1     : out std_logic_vector(31 downto 0);  -- Read data 1
            ReadData2     : out std_logic_vector(31 downto 0)); -- Read data 2
    end component;

    component ALU is
        generic (
          WIDTH     : integer := 32);
        port (
          input1    : in std_logic_vector(WIDTH-1 downto 0);
          input2    : in std_logic_vector(WIDTH-1 downto 0);
          shift     : in std_logic_vector(4 downto 0);
          op        : in ALU_OP_t;
          result    : out std_logic_vector(WIDTH-1 downto 0);
          result_hi : out std_logic_vector(WIDTH-1 downto 0);
          branch    : out std_logic);
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

    U_MEMORY_MUX : MUX_2x1
        generic map (WIDTH => 32)
        port map (
            in0     => PC,
            in1     => ALUOutReg,
            sel     => IorD,
            output  => MemAddrSel);

    U_MEMORY : MEMORY
        port map (
            clk         => clk,
            rst         => rst,
            addr        => MemAddrSel,
            RdData      => MemData,
            WrData      => RegB,
            MemRead     => MemRead,
            MemWrite    => MemWrite,
            InPort1_en  => InPort1_en,
            InPort0_en  => InPort0_en,
            InPort      => InPort,
            OutPort     => OutPort);

    InPort <= std_logic_vector(to_unsigned(0, 22)) & InPortSwitches;

    U_INSTRUCTION_REGISTER : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => IRWrite,
            input   => MemData,
            output  => IR);

    U_MEMORY_DATA_REGISTER : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => '1',
            input   => MemData,
            output  => MemDataReg);

    U_WRITE_REG_MUX : MUX_2x1
        generic map (WIDTH => 5)
        port map (
            in0     => IR(20 downto 16),
            in1     => IR(15 downto 11),
            sel     => RegDst,
            output  => WriteReg);
    
    U_WRITE_DATA_MUX : MUX_2x1
        generic map (WIDTH => 32)
        port map (
            in0     => ALUOutSel,
            in1     => MemDataReg,
            sel     => MemToReg,
            output  => WriteData);

    U_REGISTERS_FILE : REGISTERS_FILE
        port map (
            clk             => clk,
            rst             => rst,
            RegWrite        => RegWrite,
            JumpAndLink     => JumpAndLink,
            ReadReg1        => IR(25 downto 21),
            ReadReg2        => IR(20 downto 16),
            WriteRegister   => WriteReg,
            WriteData       => WriteData,
            ReadData1       => ReadData1,
            ReadData2       => ReadData2);

    U_REGISTER_A : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => '1',
            input   => ReadData1,
            output  => RegA);

    U_REGISTER_B : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => '1',
            input   => ReadData2,
            output  => RegB);

    U_SIGN_EXTEND : SIGN_EXTEND
        generic map (
            IN_WIDTH    => 16,
            OUT_WIDTH   => 32)
        port map (
            IsSigned    => IsSigned,
            input       => IR(15 downto 0),
            output      => IR15_0Extend);

    U_ALU_SRC_A_MUX : MUX_4x1
        generic map (WIDTH => 32)
        port map (
            in0     => PC,
            in1     => RegA,
            in2     => IR25_21Extend,
            in3     => std_logic_vector(to_unsigned(0, 32)),    -- Invalid selection
            sel     => ALUSrcA,
            output  => ALUInput0);

    IR25_21Extend <= std_logic_vector(resize(unsigned(IR(25 downto 21)), 32));
            
    U_ALU_SRC_B_MUX : MUX_4x1
        generic map (WIDTH => 32)
        port map (
            in0     => RegB,
            in1     => std_logic_vector(to_unsigned(4, 32)),    -- '4'
            in2     => IR15_0Extend,
            in3     => ALUSrcBIn3,
            sel     => ALUSrcB,
            output  => ALUInput1);

    ALUSrcBIn3 <= std_logic_vector(shift_left(unsigned(IR15_0Extend), 2)); -- (IR15_0Extend << 2)

    U_ALU : ALU
        generic map (WIDTH => 32)
        port map (
            input2      => ALUInput1,
            input1      => ALUInput0,
            shift       => IR(10 downto 6),
            op          => OPSelect,
            result      => ALUResult,
            result_hi   => ALUResultHi,
            branch      => BranchTaken);

    U_ALU_OUT_REG : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => '1',
            input   => ALUResult,
            output  => ALUOutReg);

    U_ALU_LO_REG : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => LO_en,
            input   => ALUResult,
            output  => LOReg);

    U_ALU_HI_REG : REG
        generic map (WIDTH => 32)
        port map (
            clk     => clk,
            rst     => rst,
            en      => HI_en,
            input   => ALUResultHi,
            output  => HIReg);

    U_PC_SOURCE_MUX : MUX_4x1
        generic map (WIDTH => 32)
        port map (
            in0     => ALUResult,
            in1     => ALUOutReg,
            in2     => PCSrcIn2,
            in3     => std_logic_vector(to_unsigned(0, 32)),    -- Invalid selection
            sel     => PCSource,
            output  => PCInput);

    PCSrcIn2 <= PC(31 downto 28) & IR(25 downto 0) & "00";

    U_ALU_OUT_MUX : MUX_4x1
        generic map (WIDTH => 32)
        port map (
            in0     => ALUOutReg,
            in1     => LOReg,
            in2     => HIReg,
            in3     => std_logic_vector(to_unsigned(0, 32)),    -- Invalid selection
            sel     => ALU_LO_HI,
            output  => ALUOutSel);
    
    IR31downto26    <= IR(31 downto 26);
    IR5downto0      <= IR(5 downto 0);
    
end str;