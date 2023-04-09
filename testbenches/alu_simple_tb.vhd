library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity alu_simple_tb is
end alu_simple_tb;

architecture SIMPLE of alu_simple_tb is
    constant WIDTH      : positive := 32;
	signal input1       : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
    signal input2       : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
    signal op           : std_logic_vector(ALU_SEL_SIZE-1 downto 0) := (others=>'0');
    signal shift        : std_logic_vector(4 downto 0) := (others=>'0');
    signal result       : std_logic_vector(WIDTH-1 downto 0);
    signal result_hi    : std_logic_vector(WIDTH-1 downto 0);
    signal branch       : std_logic := '0';

    signal done        : std_logic := '0';
    signal total       : std_logic_vector(width*2-1 downto 0) := (others=>'0');
    signal expected    : std_logic_vector(width-1 downto 0) := (others=>'0');
    signal expected_hi : std_logic_vector(width-1 downto 0) := (others=>'0');
begin --TB
	UUT: entity work.alu
        generic map ( WIDTH => WIDTH )
        port map (
            input1      => input1,
            input2      => input2,
            op          => op,
            shift       => shift,
            result      => result,
            result_hi   => result_hi);

    process
    begin --process

        -- addition of 10 + 15
        input1  <= std_logic_vector(to_unsigned(10, WIDTH));
        input2  <= std_logic_vector(to_unsigned(15, WIDTH));
        op      <= ALU_OP_ADDU;
        wait for 10 ns;
        assert(result&result_hi = std_logic_vector(to_unsigned(25, WIDTH*2))) report "OP_ADDU result incorrect" severity failure;
        assert(branch = '0') report "OP_ADDU branch incorrect" severity failure;

        -- subtraction of 25 - 10
        input1  <= std_logic_vector(to_unsigned(25, WIDTH));
        input2  <= std_logic_vector(to_unsigned(10, WIDTH));
        op      <= ALU_OP_SUBU;
        wait for 10 ns;
        assert(result&result_hi = std_logic_vector(to_unsigned(15, WIDTH*2))) report "OP_SUBU result incorrect" severity failure;
        assert(branch = '0') report "OP_SUBU branch incorrect" severity failure;

        -- multiplication (signed) of 10 * (-4)
        input1  <= std_logic_vector(to_signed(10, WIDTH));
        input2  <= std_logic_vector(to_signed(-4, WIDTH));
        op      <= ALU_OP_MULT;
        wait for 10 ns;
        assert(result&result_hi = std_logic_vector(to_signed(25, WIDTH*2))) report "OP_MULT result incorrect" severity failure;
        assert(branch = '0') report "OP_MULT branch incorrect" severity failure;

        -- multiplication (unsigned) of 65536 * 131072
        input1  <= std_logic_vector(to_unsigned(65536, WIDTH));
        input2  <= std_logic_vector(to_unsigned(131072, WIDTH));
        op      <= ALU_OP_MULTU;
        wait for 10 ns;
        assert(result&result_hi = std_logic_vector(to_unsigned(65536*131072, WIDTH*2))) report "OP_MULTU result incorrect" severity failure;
        assert(branch = '0') report "OP_MULTU branch incorrect" severity failure;
        
        done <= '1';
        report "All tests passed!";
        wait;
    end process;

end SIMPLE;