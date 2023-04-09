library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_file is 
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
end registers_file;

architecture async_read of registers_file is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array;    -- Array of 32 registers
begin -- async_read

    process(clk, rst) is
    begin -- process
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (clk'event and clk='1') then
            if (RegWrite = '1') then
                if (JumpAndLink = '1') then
                    regs(31) <= WriteData;
                else
                    regs(to_integer(unsigned(WriteRegister))) <= WriteData;
                end if; -- JumpAndLink = '1'
            end if; -- RegWrite = '1'
        end if; -- rst = '1'
    end process;

    ReadData1 <= regs(to_integer(unsigned(ReadReg1)));
    ReadData2 <= regs(to_integer(unsigned(ReadReg2)));

end async_read;