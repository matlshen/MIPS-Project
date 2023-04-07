library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_4x1 is
    generic (
        WIDTH : positive);
    port(
        in0    : in std_logic_vector(WIDTH-1 downto 0);
        in1    : in std_logic_vector(WIDTH-1 downto 0);
        in2    : in std_logic_vector(WIDTH-1 downto 0);
        in3    : in std_logic_vector(WIDTH-1 downto 0);
        sel    : in std_logic_vector(1 downto 0);
        output : out std_logic_vector(WIDTH-1 downto 0));
end mux_4x1;

architecture bhv of mux_4x1 is 
begin --bhv
    process(in0, in1, in2, in3, sel)
    begin --process
        case sel is 
            when "00" =>
                output <= in0;
            when "01" =>
                output <= in1;
            when "10" =>
                output <= in2;
            when "11" =>
                output <= in3;
            when others =>
                output <= (others => '0');
        end case;
    end process;
end bhv;