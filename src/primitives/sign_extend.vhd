library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is
    generic (
        IN_WIDTH  : natural;
        OUT_WIDTH : natural);
    port (
        IsSigned : in  std_logic;
        input    : in  std_logic_vector(IN_WIDTH-1  downto 0);
        output   : out std_logic_vector(OUT_WIDTH-1 downto 0));
end sign_extend;

architecture BHV of sign_extend is
begin --BHV
    process(IsSigned, input)
    begin --process
        if (IsSigned = '1') then
            output <= std_logic_vector(resize( signed(input), OUT_WIDTH));
        else
            output <= std_logic_vector(resize(unsigned(input), OUT_WIDTH));
        end if;
    end process;
end BHV;