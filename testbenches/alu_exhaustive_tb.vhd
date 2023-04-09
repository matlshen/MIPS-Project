library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity alu_exhaustive_tb is
end alu_exhaustive_tb;

architecture EXHAUSTIVE of alu_exhaustive_tb is
    constant WIDTH      : positive := 8;
	signal input1       : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
    signal input2       : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
    signal op           : ALU_OP_t;
    signal shift        : std_logic_vector(4 downto 0) := (others=>'0');
    signal result       : std_logic_vector(WIDTH-1 downto 0);
    signal result_hi    : std_logic_vector(WIDTH-1 downto 0);
    signal branch       : std_logic := '0';

    signal expected     : std_logic_vector(WIDTH*2-1 downto 0) := (others=>'0');
    signal expected_lo  : std_logic_vector(WIDTH-1 downto 0);
    signal expected_hi  : std_logic_vector(WIDTH-1 downto 0);
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
        for i in 0 to 2**(WIDTH)-1 loop -- input1
            for j in 0 to 2**(WIDTH)-1 loop -- input2

                input1 <= std_logic_vector(to_unsigned(i, WIDTH));
                input2 <= std_logic_vector(to_unsigned(j, WIDTH));


                op <= ALU_ADDU;
                expected_lo <= std_logic_vector(to_unsigned(i, WIDTH)+to_unsigned(j, WIDTH));
                expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                expected <= expected_hi&expected_lo;
                wait for 10 ns;
                assert(result = expected_lo) report "ALU_ADDU result incorrect" severity failure;
                assert(result_hi = expected_hi) report "ALU_ADDU result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_ADDU branch incorrect" severity failure;

                op <= ALU_SUBU;
                expected_lo <= std_logic_vector(to_unsigned(i, WIDTH)-to_unsigned(j, WIDTH));
                expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                expected <= expected_hi&expected_lo;
                wait for 10 ns;
                assert(result = expected_lo) report "ALU_SUBU result incorrect" severity failure;
                assert(result_hi = expected_hi) report "ALU_SUBU result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_SUBU branch incorrect" severity failure;

                op <= ALU_MULT;
                expected <= std_logic_vector(to_signed(i, WIDTH)*to_signed(j, WIDTH));
                expected_lo <= expected(WIDTH-1 downto 0);
                expected_hi <= expected(WIDTH*2-1 downto WIDTH);
                wait for 10 ns;
                assert(result_hi & result = expected) report "ALU_MULT result&result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_MULT branch incorrect" severity failure;

                op <= ALU_MULTU;
                expected <= std_logic_vector(to_unsigned(i, WIDTH)*to_unsigned(j, WIDTH));
                expected_lo <= expected(WIDTH-1 downto 0);
                expected_hi <= expected(WIDTH*2-1 downto WIDTH);
                wait for 10 ns;
                assert(result_hi&result = expected) report "ALU_MULTU result&result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_MULTU branch incorrect" severity failure;

                op <= ALU_AND;
                expected_lo <= std_logic_vector(to_unsigned(i, WIDTH) and to_unsigned(j, WIDTH));
                expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                expected <= expected_hi&expected_lo;
                wait for 10 ns;
                assert(result = expected_lo) report "ALU_AND result incorrect" severity failure;
                assert(result_hi = expected_hi) report "ALU_AND result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_AND branch incorrect" severity failure;

                op <= ALU_OR;
                expected_lo <= std_logic_vector(to_unsigned(i, WIDTH) or to_unsigned(j, WIDTH));
                expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                expected <= expected_hi&expected_lo;
                wait for 10 ns;
                assert(result = expected_lo) report "ALU_OR result incorrect" severity failure;
                assert(result_hi = expected_hi) report "ALU_OR result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_OR branch incorrect" severity failure;

                op <= ALU_XOR;
                expected_lo <= std_logic_vector(to_unsigned(i, WIDTH) xor to_unsigned(j, WIDTH));
                expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                expected <= expected_hi&expected_lo;
                wait for 10 ns;
                assert(result = expected_lo) report "ALU_XOR result incorrect" severity failure;
                assert(result_hi = expected_hi) report "ALU_XOR result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_XOR branch incorrect" severity failure;


                for k in 0 to 2**5-1 loop
                    
                    shift <= std_logic_vector(to_unsigned(k,5));
                    wait for 10 ns;

                    op <= ALU_SRL;
                    expected_lo <= std_logic_vector(SHIFT_RIGHT(to_unsigned(i, WIDTH), k));
                    expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                    expected <= expected_hi&expected_lo;
                    wait for 10 ns;
                    assert(result = expected_lo) report "ALU_SRL result incorrect" severity failure;
                    assert(result_hi = expected_hi) report "ALU_SRL result_hi incorrect" severity failure;
                    assert(branch = '0') report "ALU_SRL branch incorrect" severity failure;

                    op <= ALU_SLL;
                    expected_lo <= std_logic_vector(SHIFT_LEFT(to_unsigned(i, WIDTH), k));
                    expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                    expected <= expected_hi&expected_lo;
                    wait for 10 ns;
                    assert(result = expected_lo) report "ALU_SLL result incorrect" severity failure;
                    assert(result_hi = expected_hi) report "ALU_SLL result_hi incorrect" severity failure;
                    assert(branch = '0') report "ALU_SLL branch incorrect" severity failure;

                    op <= ALU_SRA;
                    expected_lo <= std_logic_vector(SHIFT_RIGHT(to_signed(i, WIDTH), k));
                    expected_hi <= std_logic_vector(to_unsigned(0,WIDTH));
                    expected <= expected_hi&expected_lo;
                    wait for 10 ns;
                    assert(result = expected_lo) report "ALU_SRA result incorrect" severity failure;
                    assert(result_hi = expected_hi) report "ALU_SRA result_hi incorrect" severity failure;
                    assert(branch = '0') report "ALU_SRA branch incorrect" severity failure;

                end loop; 
                

                op <= ALU_SLT;
                wait for 10 ns;
                if (to_signed(i, WIDTH) < to_signed(j, WIDTH)) then
                    assert(result = std_logic_vector(to_unsigned(1,WIDTH))) report "ALU_SLT result incorrect" severity failure;
                else
                    assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_SLT result incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_SLT result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_SLT branch incorrect" severity failure;

                op <= ALU_SLTU;
                wait for 10 ns;
                if (to_unsigned(i, WIDTH) < to_unsigned(j, WIDTH)) then
                    assert(result = std_logic_vector(to_unsigned(1,WIDTH))) report "ALU_SLTU result incorrect" severity failure;
                else
                    assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_SLTU result incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_SLTU result_hi incorrect" severity failure;
                assert(branch = '0') report "ALU_SLTU branch incorrect" severity failure;

                -- end set ons
                -- start branches

                op <= ALU_BEQ;
                wait for 10 ns;
                if (to_signed(i, WIDTH) = to_signed(j, WIDTH)) then
                    assert(branch = '1') report "ALU_BEQ branch incorrect" severity failure;
                else
                    assert(branch = '0') report "ALU_BEQ branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BEQ result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BEQ result incorrect" severity failure;

                op <= ALU_BNE;
                wait for 10 ns;
                if (to_signed(i, WIDTH) = to_signed(j, WIDTH)) then
                    assert(branch = '0') report "ALU_BNE branch incorrect" severity failure;
                else
                    assert(branch = '1') report "ALU_BNE branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BNE result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BNE result incorrect" severity failure;

                op <= ALU_BLEZ;
                wait for 10 ns;
                if (to_signed(i, WIDTH) <= to_signed(0, WIDTH)) then
                    assert(branch = '1') report "ALU_BLEZ branch incorrect" severity failure;
                else
                    assert(branch = '0') report "ALU_BLEZ branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BLEZ result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BLEZ result incorrect" severity failure;

                op <= ALU_BGTZ;
                wait for 10 ns;
                if (to_signed(i, WIDTH) > to_signed(0, WIDTH)) then
                    assert(branch = '1') report "ALU_BGTZ branch incorrect" severity failure;
                else
                    assert(branch = '0') report "ALU_BGTZ branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BGTZ result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BGTZ result incorrect" severity failure;

                op <= ALU_BLTZ;
                wait for 10 ns;
                if (to_signed(i, WIDTH) < to_signed(0, WIDTH)) then
                    assert(branch = '1') report "ALU_BLTZ branch incorrect" severity failure;
                else
                    assert(branch = '0') report "ALU_BLTZ branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BLTZ result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BLTZ result incorrect" severity failure;

                op <= ALU_BGEZ;
                wait for 10 ns;
                if (to_signed(i, WIDTH) >= to_signed(0, WIDTH)) then
                    assert(branch = '1') report "ALU_BGEZ branch incorrect" severity failure;
                else
                    assert(branch = '0') report "ALU_BGEZ branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BGEZ result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "ALU_BGEZ result incorrect" severity failure;

                --end branches

            end loop;   -- input 2
        end loop;   -- input 1

        done <= '1';
        report "All tests passed!";
        wait;
    end process;

end EXHAUSTIVE;