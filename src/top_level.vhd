library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity top_level is
    port (
        clk50MHz : in  std_logic;

        switches : in  std_logic_vector(9 downto 0);
        buttons  : in  std_logic_vector(1 downto 0);

        led      : out std_logic_vector(9 downto 0);
        led0     : out std_logic_vector(6 downto 0);
        led0_dp  : out std_logic;
        led1     : out std_logic_vector(6 downto 0);
        led1_dp  : out std_logic;
        led2     : out std_logic_vector(6 downto 0);
        led2_dp  : out std_logic;
        led3     : out std_logic_vector(6 downto 0);
        led3_dp  : out std_logic;
        led4     : out std_logic_vector(6 downto 0);
        led4_dp  : out std_logic;
        led5     : out std_logic_vector(6 downto 0);
        led5_dp  : out std_logic
    );
end top_level;

architecture STR of top_level is
    signal rst         : std_logic;

    signal InPort      : std_logic_vector(31 downto 0);
    signal OutPort     : std_logic_vector(31 downto 0);
    signal InPort_en   : std_logic_vector(1 downto 0);
    signal InPort1_en  : std_logic;
    signal InPort0_en  : std_logic;
    -- Controller
    signal PCWriteCond : std_logic;
    signal PCWrite     : std_logic;
    signal IorD        : std_logic;
    signal MemRead     : std_logic;
    signal MemWrite    : std_logic;
    signal MemToReg    : std_logic_vector(1 downto 0);
    signal IRWrite     : std_logic;
    signal JumpAndLink : std_logic;
    signal IsSigned    : std_logic;
    signal PCSource    : std_logic_vector(1 downto 0);
    signal ALUSrcA     : std_logic_vector(1 downto 0);
    signal ALUSrcB     : std_logic_vector(1 downto 0);
    signal RegWrite    : std_logic;
    signal RegDst      : std_logic;
    signal IR31downto26: std_logic_vector(5 downto 0);
    signal IR20downto16 : std_logic_vector(4 downto 0);
    -- ALU Controller
    signal OpSelect     : ALU_OP_t;
    signal HI_en        : std_logic;
    signal LO_en        : std_logic;
    signal ALU_LO_HI    : std_logic_vector(1 downto 0);
    signal IR5downto0: std_logic_vector(5 downto 0);
begin --STR

    rst <= not buttons(1);

    InPort1_en <= switches(9);
    InPort0_en <= (not switches(9));
    InPort <= std_logic_vector(to_unsigned(0,23) & unsigned(switches(8 downto 0)));

    U_DATAPATH: entity work.datapath
        port map (
            clk         => clk50MHz,
            rst         => rst,
            InPort1_en  => InPort1_en,
            InPort0_en  => InPort0_en,
            InPort      => InPort,
            OutPort      => OutPort,
            PCWriteCond  => PCWriteCond,
            PCWrite      => PCWrite,
            IorD         => IorD,
            MemRead      => MemRead,
            MemWrite     => MemWrite,
            MemToReg     => MemToReg,
            IRWrite      => IRWrite,
            JumpAndLink  => JumpAndLink,
            IsSigned     => IsSigned,
            PCSource     => PCSource,
            OpSelect     => OpSelect,
            ALUSrcA      => ALUSrcA,
            ALUSrcB      => ALUSrcB,
            RegWrite     => RegWrite,
            RegDst       => RegDst,
            IR31downto26 => IR31downto26,
            IR5downto0   => IR5downto0,
            IR20downto16 => IR20downto16,
            HI_en        => HI_en,
            LO_en        => LO_en,
            ALU_LO_HI    => ALU_LO_HI
        );

    U_CONTROLLER: entity work.controller
        port map (
            clk          => clk50MHz,
            rst          => rst,
            PCWriteCond  => PCWriteCond,
            PCWrite      => PCWrite,
            IorD         => IorD,
            MemRead      => MemRead,
            MemWrite     => MemWrite,
            MemToReg     => MemToReg,
            IRWrite      => IRWrite,
            JumpAndLink  => JumpAndLink,
            IsSigned     => IsSigned,
            PCSource     => PCSource,
            OpSelect     => OpSelect,
            ALUSrcA      => ALUSrcA,
            ALUSrcB      => ALUSrcB,
            RegWrite     => RegWrite,
            RegDst       => RegDst,
            IR31downto26 => IR31downto26,
            IR5downto0   => IR5downto0,
            IR20downto16 => IR20downto16,
            HI_en        => HI_en,
            LO_en        => LO_en,
            ALU_LO_HI    => ALU_LO_HI
        );

        led <= "0000000000";

        U_LED5 : entity work.decoder7seg 
            port map (
                input  => OutPort(23 downto 20),
                output => led5
            );
        led5_dp <= '1';

        U_LED4 : entity work.decoder7seg 
        port map (
            input  => OutPort(19 downto 16),
            output => led4
        );
        led4_dp <= '1';

        U_LED3 : entity work.decoder7seg 
        port map (
            input  => OutPort(15 downto 12),
            output => led3
        );
        led3_dp <= '1';

        U_LED2 : entity work.decoder7seg 
        port map (
            input  => OutPort(11 downto 8),
            output => led2
        );
        led2_dp <= '1';

        U_LED1 : entity work.decoder7seg 
        port map (
            input  => OutPort(7 downto 4),
            output => led1
        );
        led1_dp <= '1';

        U_LED0 : entity work.decoder7seg 
        port map (
            input  => OutPort(3 downto 0),
            output => led0
        );
        led0_dp <= '1';
end STR;