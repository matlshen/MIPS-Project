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
        for i in 0 to 2**(WIDTH)-1 loop -- input1
            for j in 0 to 2**(WIDTH)-1 loop -- input2

                input1 <= std_logic_vector(to_unsigned(i, WIDTH));
                input2 <= std_logic_vector(to_unsigned(j, WIDTH));

                -- start arithmetic operations

                op <= OP_ADD_U;
                wait for 10 ns;
                assert(result = std_logic_vector(to_unsigned(i, WIDTH)+to_unsigned(j, WIDTH))) report "OP_ADD_U result incorrect" severity failure;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_ADD_U result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_ADD_U branch incorrect" severity failure;

                op <= OP_SUB_U;
                wait for 10 ns;
                assert(result = std_logic_vector(to_unsigned(i, WIDTH)-to_unsigned(j, WIDTH))) report "OP_SUB_U result incorrect" severity failure;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SUB_U result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_SUB_U branch incorrect" severity failure;

                op <= OP_MULT_S;
                wait for 10 ns;
                assert(result_hi & result = std_logic_vector(to_signed(i, WIDTH)*to_signed(j, WIDTH))) report "OP_MULT_S result&result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_MULT_S branch incorrect" severity failure;

                op <= OP_MULT_U;
                wait for 10 ns;
                assert(result_hi&result = std_logic_vector(to_unsigned(i, WIDTH)*to_unsigned(j, WIDTH))) report "OP_MULT_U result&result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_MULT_U branch incorrect" severity failure;

                op <= OP_AND;
                wait for 10 ns;
                assert(result = std_logic_vector(to_unsigned(i, WIDTH) and to_unsigned(j, WIDTH))) report "OP_AND result incorrect" severity failure;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_AND result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_AND branch incorrect" severity failure;

                op <= OP_OR;
                wait for 10 ns;
                assert(result = std_logic_vector(to_unsigned(i, WIDTH) or to_unsigned(j, WIDTH))) report "OP_OR result incorrect" severity failure;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_OR result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_OR branch incorrect" severity failure;

                op <= OP_XOR;
                wait for 10 ns;
                assert(result = std_logic_vector(to_unsigned(i, WIDTH) xor to_unsigned(j, WIDTH))) report "OP_XOR result incorrect" severity failure;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_XOR result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_XOR branch incorrect" severity failure;

                -- end arithmetic operations
                -- start shift operations

                for k in 0 to 2**5-1 loop -- k = shift
                    
                    shift <= std_logic_vector(to_unsigned(k,5));
                    wait for 10 ns;

                    op <= OP_SHR_L;
                    wait for 10 ns;
                    assert(result = std_logic_vector(SHIFT_RIGHT(to_unsigned(i, WIDTH), k))) report "OP_SHR_L result incorrect" severity failure;
                    assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SHR_L result_hi incorrect" severity failure;
                    assert(branch = '0') report "OP_SHR_L branch incorrect" severity failure;

                    op <= OP_SHL_L;
                    wait for 10 ns;
                    assert(result = std_logic_vector(SHIFT_LEFT(to_unsigned(i, WIDTH), k))) report "OP_SHL_L result incorrect" severity failure;
                    assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SHL_L result_hi incorrect" severity failure;
                    assert(branch = '0') report "OP_SHL_L branch incorrect" severity failure;

                    op <= OP_SHR_A;
                    wait for 10 ns;
                    assert(result = std_logic_vector(SHIFT_RIGHT(to_signed(i, WIDTH), k))) report "OP_SHR_A result incorrect" severity failure;
                    assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SHR_A result_hi incorrect" severity failure;
                    assert(branch = '0') report "OP_SHR_A branch incorrect" severity failure;

                end loop; 
                
                -- end shift operations
                -- start set ons

                op <= OP_SLT_S;
                wait for 10 ns;
                if (to_signed(i, WIDTH) < to_signed(j, WIDTH)) then
                    assert(result = std_logic_vector(to_unsigned(1,WIDTH))) report "OP_SLT_S result incorrect" severity failure;
                else
                    assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SLT_S result incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SLT_S result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_SLT_S branch incorrect" severity failure;

                op <= OP_SLT_U;
                wait for 10 ns;
                if (to_unsigned(i, WIDTH) < to_unsigned(j, WIDTH)) then
                    assert(result = std_logic_vector(to_unsigned(1,WIDTH))) report "OP_SLT_U result incorrect" severity failure;
                else
                    assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SLT_U result incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_SLT_U result_hi incorrect" severity failure;
                assert(branch = '0') report "OP_SLT_U branch incorrect" severity failure;

                -- end set ons
                -- start branches

                op <= OP_BEQ;
                wait for 10 ns;
                if (to_signed(i, WIDTH) = to_signed(j, WIDTH)) then
                    assert(branch = '1') report "OP_BEQ branch incorrect" severity failure;
                else
                    assert(branch = '0') report "OP_BEQ branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BEQ result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BEQ result incorrect" severity failure;

                op <= OP_BNE;
                wait for 10 ns;
                if (to_signed(i, WIDTH) = to_signed(j, WIDTH)) then
                    assert(branch = '0') report "OP_BNE branch incorrect" severity failure;
                else
                    assert(branch = '1') report "OP_BNE branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BNE result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BNE result incorrect" severity failure;

                op <= OP_BLTE;
                wait for 10 ns;
                if (to_signed(i, WIDTH) <= to_signed(0, WIDTH)) then
                    assert(branch = '1') report "OP_BLTE branch incorrect" severity failure;
                else
                    assert(branch = '0') report "OP_BLTE branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BLTE result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BLTE result incorrect" severity failure;

                op <= OP_BGT;
                wait for 10 ns;
                if (to_signed(i, WIDTH) > to_signed(0, WIDTH)) then
                    assert(branch = '1') report "OP_BGT branch incorrect" severity failure;
                else
                    assert(branch = '0') report "OP_BGT branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BGT result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BGT result incorrect" severity failure;

                op <= OP_BLT;
                wait for 10 ns;
                if (to_signed(i, WIDTH) < to_signed(0, WIDTH)) then
                    assert(branch = '1') report "OP_BLT branch incorrect" severity failure;
                else
                    assert(branch = '0') report "OP_BLT branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BLT result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BLT result incorrect" severity failure;

                op <= OP_BGTE;
                wait for 10 ns;
                if (to_signed(i, WIDTH) >= to_signed(0, WIDTH)) then
                    assert(branch = '1') report "OP_BGTE branch incorrect" severity failure;
                else
                    assert(branch = '0') report "OP_BGTE branch incorrect" severity failure;
                end if;
                assert(result_hi = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BGTE result_hi incorrect" severity failure;
                assert(result = std_logic_vector(to_unsigned(0,WIDTH))) report "OP_BGTE result incorrect" severity failure;

                --end branches

            end loop;   -- input 2
        end loop;   -- input 1

        done <= '1';
        report "All tests passed!";
        wait;
    end process;

end EXHAUSTIVE;