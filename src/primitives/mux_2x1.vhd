library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2x1 is
    generic (
        WIDTH : positive);
    port(
        in0    : in std_logic_vector(WIDTH-1 downto 0);
        in1    : in std_logic_vector(WIDTH-1 downto 0);
        sel    : in std_logic;
        output : out std_logic_vector(WIDTH-1 downto 0));
end mux_2x1;

architecture bhv of mux_2x1 is 
begin --bhv
    process(in0, in1, sel)
    begin --process
        if (sel = '0') then
            output <= in0;
        else
            output <= in1;
        end if;
    end process;
end bhv;