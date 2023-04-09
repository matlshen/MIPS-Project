library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;

entity alu is
  generic (
    WIDTH     : integer := 32);
  port (
    input1    : in std_logic_vector(WIDTH-1 downto 0);
    input2    : in std_logic_vector(WIDTH-1 downto 0);
    shift     : in std_logic_vector(4 downto 0);
    op        : in ALU_OP_t;
    result    : out std_logic_vector(WIDTH-1 downto 0);
    result_hi : out std_logic_vector(WIDTH-1 downto 0);
    branch    : out std_logic);
end alu;

architecture bhv of alu is  
begin --bhv

  process(input1, input2, shift, op)
    variable temp_mult : std_logic_vector(WIDTH*2-1 downto 0);
  begin --process

    result <= (others => '0');
    result_hi <= (others => '0');
    branch <= '0';

    case op is
      when ALU_ADDU =>  -- add unsigned
        result <= std_logic_vector(unsigned(input1) + unsigned(input2));

      when ALU_SUBU =>  -- sub unsigned
        result <= std_logic_vector(unsigned(input1) - unsigned(input2));

      when ALU_MULT =>  -- mult signed
        temp_mult := std_logic_vector(signed(input1) * signed(input2));
        result    <= temp_mult(WIDTH-1 downto 0);
        result_hi <= temp_mult(WIDTH*2-1 downto WIDTH);
        
      when ALU_MULTU => -- mult unsigned
        temp_mult := std_logic_vector(unsigned(input1) * unsigned(input2));
        result    <= temp_mult(WIDTH-1 downto 0);
        result_hi <= temp_mult(WIDTH*2-1 downto WIDTH);
        
      when ALU_AND =>   -- AND
        result <= input1 and input2;

      when ALU_OR =>    -- OR
        result <= input1 or input2;

      when ALU_XOR =>   -- XOR
        result <= input1 xor input2;

      when ALU_SRL =>   -- shift right logical
        result <= std_logic_vector(shift_right(unsigned(input1), to_integer(unsigned(shift))));

      when ALU_SLL =>   -- shift left logical
        result <= std_logic_vector(shift_left(unsigned(input1), to_integer(unsigned(shift))));

      when ALU_SRA =>   -- shift right arithmetic
        result <= std_logic_vector(shift_right(signed(input1), to_integer(unsigned(shift))));

      when ALU_SLT =>   -- set on less than signed
        if (signed(input1) < signed(input2)) then
          result <= std_logic_vector(to_unsigned(1, width));
        else
          result <= (others => '0');
        end if;

      when ALU_SLTU =>  -- set on less than unsigned
        if (unsigned(input1) < unsigned(input2)) then
          result <= std_logic_vector(to_unsigned(1, width));
        else
          result <= (others => '0');
        end if;

      when ALU_BEQ =>   -- branch if equal
        if (signed(input1) = signed(input2)) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BNE =>   -- branch if not equal
        if (signed(input1) /= signed(input2)) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BLEZ =>  -- branch if less than or equal to 0
        if (signed(input1) <= 0) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BGEZ =>  -- branch if greater than or equal to 0
        if (signed(input1) >= 0) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BLTZ =>  -- branch if less than 0
        if (signed(input1) < 0) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BGTZ =>  -- branch if greater than 0
        if (signed(input1) > 0) then
          branch <= '1';
        else
          branch <= '0';
        end if;
      
      when ALU_BLTE =>  -- branch if less than or equal
        if (signed(input1) <= signed(input2)) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BGTE =>  -- branch if greater than or equal
        if (signed(input1) >= signed(input2)) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BLT =>   -- branch if less than
        if (signed(input1) < signed(input2)) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when ALU_BGT =>   -- branch if greater than
        if (signed(input1) > signed(input2)) then
          branch <= '1';
        else
          branch <= '0';
        end if;

      when others =>
        null;
    end case; -- op

  end process;

end bhv;