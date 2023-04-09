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
    signal op           : ALU_OP_t;
    signal shift        : std_logic_vector(4 downto 0) := (others=>'0');
    signal result       : std_logic_vector(WIDTH-1 downto 0);
    signal result_hi    : std_logic_vector(WIDTH-1 downto 0);
    signal branch       : std_logic := '0';

    signal big_num      : unsigned(63 downto 0);   -- For handling large numbers and positive based literals
    signal expected     : std_logic_vector(WIDTH*2-1 downto 0);
    signal done         : std_logic := '0';
begin --TB
	UUT: entity work.alu
        generic map ( WIDTH => WIDTH )
        port map (
            input1      => input1,
            input2      => input2,
            op          => op,
            shift       => shift,
            result      => result,
            result_hi   => result_hi,
            branch      => branch);

    process
    begin --process

        -- addition of 10 + 15
        input1      <= std_logic_vector(to_unsigned(10, WIDTH));
        input2      <= std_logic_vector(to_unsigned(15, WIDTH));
        op          <= ALU_ADDU;
        expected    <= std_logic_vector(to_unsigned(25, WIDTH*2));
        wait for 10 ns;
        assert(result_hi&result = expected) report "ADDU result incorrect" severity failure;
        assert(branch = '0') report "ADDU branch incorrect" severity failure;

        -- subtraction of 25 - 10
        input1      <= std_logic_vector(to_unsigned(25, WIDTH));
        input2      <= std_logic_vector(to_unsigned(10, WIDTH));
        op          <= ALU_SUBU;
        expected    <= std_logic_vector(to_unsigned(15, WIDTH*2));
        wait for 10 ns;
        assert(result_hi&result = expected) report "SUBU result incorrect" severity failure;
        assert(branch = '0') report "SUBU branch incorrect" severity failure;

        -- multiplication (signed) of 10 * (-4)
        input1      <= std_logic_vector(to_signed(10, WIDTH));
        input2      <= std_logic_vector(to_signed(-4, WIDTH));
        op          <= ALU_MULT;
        expected    <= std_logic_vector(to_signed(-40, WIDTH*2));
        wait for 10 ns;
        assert(result_hi&result = expected) report "MULT result incorrect" severity failure;
        assert(branch = '0') report "MULT branch incorrect" severity failure;

        -- multiplication (unsigned) of 65536 * 131072
        input1      <= std_logic_vector(to_unsigned(65536, WIDTH));
        input2      <= std_logic_vector(to_unsigned(131072, WIDTH));
        op          <= ALU_MULTU;
        expected    <= std_logic_vector(to_unsigned(65536, WIDTH) * to_unsigned(131072, WIDTH));
        wait for 10 ns;
        assert(result_hi&result = expected) report "MULTU result incorrect" severity failure;
        assert(branch = '0') report "MULTU branch incorrect" severity failure;

        -- AND of 0x0000_FFFF * 0xFFFF_1234
        input1      <= x"0000_FFFF";
        input2      <= x"FFFF_1234";
        op          <= ALU_AND;
        expected    <= std_logic_vector(to_signed(16#0000_FFFF#, WIDTH*2) and to_signed(16#FFFF_1234#, WIDTH*2));
        wait for 10 ns;
        assert(result_hi&result = expected) report "AND result incorrect" severity failure;
        assert(branch = '0') report "AND branch incorrect" severity failure;

        -- shift right logical of 0x0000_000F by 4
        input1      <= x"0000_000F";
        input2      <= std_logic_vector(to_unsigned(0, WIDTH));
        shift       <= std_logic_vector(to_unsigned(4 ,5));
        op          <= ALU_SRL;
        expected    <= x"0000_0000_0000_0000";
        wait for 10 ns;
        assert(result_hi&result = expected) report "SRL result incorrect" severity failure;
        assert(branch = '0') report "SRL branch incorrect" severity failure;

        -- shift right arithmetic of 0xF000_0008 by 1
        input1      <= x"F000_0008";
        input2      <= std_logic_vector(to_unsigned(0, WIDTH));
        shift       <= std_logic_vector(to_unsigned(1 ,5));
        op          <= ALU_SRA;
        wait for 10 ns;
        assert(result = std_logic_vector(shift_right(to_signed(16#F000_0008#, WIDTH), 1))) report "SRA result incorrect" severity failure;
        assert(result_hi = std_logic_vector(to_unsigned(0, WIDTH))) report "SRA result_hi incorrect" severity failure;
        assert(branch = '0') report "SRA branch incorrect" severity failure;

        -- shift right arithmetic of 0x0000_0008 by 1
        input1  <= std_logic_vector(to_unsigned(16#0000_0008#, WIDTH));
        input2  <= std_logic_vector(to_unsigned(0, WIDTH));
        shift   <= std_logic_vector(to_unsigned(1 ,5));
        op      <= ALU_SRA;
        wait for 10 ns;
        assert(result = std_logic_vector(shift_right(to_signed(16#0000_0008#, WIDTH), 1))) report "SRA result incorrect" severity failure;
        assert(result_hi = std_logic_vector(to_unsigned(0, WIDTH))) report "SRA result_hi incorrect" severity failure;
        assert(branch = '0') report "SRA branch incorrect" severity failure;

        -- set on less (unsigned) than using 10 and 15
        input1  <= std_logic_vector(to_signed(10, WIDTH));
        input2  <= std_logic_vector(to_signed(15, WIDTH));
        op      <= ALU_SLTU;
        wait for 10 ns;
        assert(result_hi&result = std_logic_vector(to_signed(1, WIDTH*2))) report "SLTU result incorrect" severity failure;
        assert(branch = '0') report "SLTU branch incorrect" severity failure;

        -- set on less (signed) than using 15 and 10
        input1  <= std_logic_vector(to_signed(15, WIDTH));
        input2  <= std_logic_vector(to_signed(10, WIDTH));
        op      <= ALU_SLT;
        wait for 10 ns;
        assert(result_hi&result = std_logic_vector(to_unsigned(0, WIDTH*2))) report "SLT result incorrect" severity failure;
        assert(branch = '0') report "SLT branch incorrect" severity failure;

        -- branch taken output = '0' for 5<=0
        input1  <= std_logic_vector(to_signed(5, WIDTH));
        input2  <= std_logic_vector(to_signed(0, WIDTH));
        op      <= ALU_BLTE;
        wait for 10 ns;
        assert(result_hi&result = std_logic_vector(to_unsigned(0, WIDTH*2))) report "BLTE result incorrect" severity failure;
        assert(branch = '0') report "BLTE branch incorrect" severity failure;

        -- branch taken output = '1' for 5>0
        input1  <= std_logic_vector(to_signed(5, WIDTH));
        input2  <= std_logic_vector(to_signed(0, WIDTH));
        op      <= ALU_BGT;
        wait for 10 ns;
        assert(result_hi&result = std_logic_vector(to_unsigned(0, WIDTH*2))) report "BGT result incorrect" severity failure;
        assert(branch = '1') report "BGT branch incorrect" severity failure;
        
        done <= '1';
        report "All tests passed!";
        wait;
    end process;

end SIMPLE;