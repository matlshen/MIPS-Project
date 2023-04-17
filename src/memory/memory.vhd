library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        -- From datapath
        address     : in  std_logic_vector(31 downto 0);    -- Memory address
        data        : out std_logic_vector(31 downto 0);    -- Read data from memory
        RegB        : in  std_logic_vector(31 downto 0);    -- Write data
        -- From Controller
        MemRead     : in std_logic;
        MemWrite    : in std_logic;
        -- From Top Level / Interface
        InPort1_en  : in  std_logic;
        InPort0_en  : in  std_logic;
        InPort      : in  std_logic_vector(31 downto 0);    -- InPort0/InPort1
        OutPort     : out std_logic_vector(31 downto 0)
    );
end memory;

architecture ARCH of memory is

    signal OutPort_en   : std_logic;
    signal ram_wren     : std_logic;

    signal InPort0      : std_logic_vector(31 downto 0);
    signal InPort1      : std_logic_vector(31 downto 0);
    signal RamOut       : std_logic_vector(31 downto 0);

    signal OutMuxSel    : std_logic_vector(1 downto 0);

begin -- ARCH

    -- Write Process
    process(address, MemWrite)
    begin 
        OutPort_en <= '0';
        ram_wren <= '0';
        
        if (MemWrite = '1') then
            if (address = x"0000FFFC") then -- write to the output port ($0000FFFC) and not the RAM
                OutPort_en <= '1';
            else -- write to the RAM and output port
                OutPort_en <= '1';
                ram_wren <= '1';
            end if; 
        end if;

    end process;

    -- Read Process
    process (MemRead, address)
    begin -- process
        if (MemRead = '1') then
            if (address = x"0000FFF8") then
                OutMuxSel <= "00"; -- INPORT0
            elsif (address = x"0000FFFC") then
                OutMuxSel <= "01";  -- INPORT1
            else -- Any other address is in RAM
                OutMuxSel <= "10"; -- RAM
            end if;
        else
            OutMuxSel <= "11";  -- Read 0s if MemRead is not enabled
        end if;
    end process;


    U_OUT_MUX: entity work.mux_4x1
        generic map (   WIDTH => 32 )
        port map (
            in0    => InPort0,
            in1    => InPort1,
            in2    => RamOut,
            in3    => (others => '0'),
            sel    => OutMuxSel,
            output => data);

    U_IN_PORT_0_REG: entity work.reg
        generic map (   WIDTH => 32 )
        port map (
            clk    => clk,
            rst    => '0',
            en     => InPort0_en,
            input  => InPort,
            output => InPort0);

    U_IN_PORT_1_REG: entity work.reg
        generic map (   WIDTH => 32 )
        port map (
            clk    => clk,
            rst    => '0',
            en     => InPort1_en,
            input  => InPort,
            output => InPort1);

    U_RAM: entity work.ram
        port map (
            address	=> address(9 downto 2),
            clock   => clk,
            data	=> RegB,
            wren	=> ram_wren,
            q		=> RamOut);

    U_OUT_PORT_REG: entity work.reg
        generic map (   WIDTH => 32 )
        port map (
            clk    => clk,
            rst    => rst,
            en     => OutPort_en,
            input  => RegB,
            output => OutPort);

end ARCH;