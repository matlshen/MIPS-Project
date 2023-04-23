library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_OP_LIB.all;
use work.MIPS_FUNC_LIB.all;

entity controller is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        -- Controller
        IR31downto26    : in std_logic_vector(5 downto 0);      -- IR[31:26], OpCode
        IR20downto16    : in std_logic_vector(4 downto 0);      -- IR[20:16], Branch identifier
        PCWriteCond     : out std_logic;
        PCWrite         : out std_logic;
        IorD            : out std_logic;
        MemRead         : out std_logic;
        MemWrite        : out std_logic;
        MemToReg        : out std_logic_vector(1 downto 0);
        IRWrite         : out std_logic;
        JumpAndLink     : out std_logic;
        IsSigned        : out std_logic;
        PCSource        : out std_logic_vector(1 downto 0);
        ALUSrcB         : out std_logic_vector(1 downto 0);
        ALUSrcA         : out std_logic_vector(1 downto 0);
        RegWrite        : out std_logic;
        RegDst          : out std_logic;
        -- ALU Controller
        IR5downto0      : in std_logic_vector(5 downto 0);      -- IR[5:0], R-type function
        OPSelect        : out ALU_OP_t;
        ALU_LO_HI       : out std_logic_vector(1 downto 0);
        LO_en           : out std_logic;
        HI_en           : out std_logic);
end controller;

architecture BHV of controller is

    type STATE_TYPE is (INSTRUCTION_FETCH_S, MEM_READ_DELAY_S, LOAD_IR_S, INSTRUCTION_DECODE_S, MEM_ADDR_COMP_S, 
                        MEM_ACCESS_READ_S, MEM_ACCESS_WRITE_S, MEM_WRITE_WAIT_S, LOAD_MEM_DATA_S, MEM_READ_COMPLETE_S, 
                        R_TYPE_EXECUTION_S, I_TYPE_EXECUTION_S, R_TYPE_COMPLETION_S, I_TYPE_COMPLETION_S, 
                        BRANCH_COMPLETION_S, JUMP_COMPLETION_S, WRITE_RETURN_ADDR_S, JUMP_REGISTER_S, HALT_S);
    signal state, next_state    : STATE_TYPE;
    signal OpCode               : unsigned(7 downto 0);
    signal Func                 : unsigned(7 downto 0);
    signal BranchCode           : unsigned(7 downto 0);

begin --BHV

    process(clk, rst)
    begin --process
        if (rst = '1') then
            state <= INSTRUCTION_FETCH_S;
        elsif (rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    process(state, IR31downto26)
    begin --process

        -- Output defaults
        PCWriteCond <= '0';
        PCWrite     <= '0';
        IorD        <= '0';
        MemRead     <= '0';
        MemWrite    <= '0';
        MemToReg    <= "00";
        IRWrite     <= '0';
        JumpAndLink <= '0';
        IsSigned    <= '0';
        PCSource    <= "00";
        OpSelect    <= ALU_ADDU;
        ALUSrcA     <= "00";
        ALUSrcB     <= "00";
        RegWrite    <= '0';
        RegDst      <= '0';
        ALU_LO_HI   <= "00";
        LO_en       <= '0';
        HI_en       <= '0'; 
        next_state  <= state;

        -- Week 2, LW,SW instructions, R-type instructions, I-type instructions
        case state is

            -- Read instruction from memory and increment PC by 4
            when INSTRUCTION_FETCH_S =>
                -- Read instruction from memroy
                IorD        <= '0';         -- Select current PC as memory read address
                MemRead     <= '1';         -- Enable memory read
                -- Load PC with PC+4
                ALUSrcA     <= "00";        -- Select current PC
                ALUSrcB     <= "01";        -- Select '4'
                OpSelect    <= ALU_ADDU;    -- Add unsigned
                PCSource    <= "00";        -- ALU result
                PCWrite     <= '1';         -- Enable PC reg write
                -- Next step is to load IR from output of memory
                next_state <= MEM_READ_DELAY_S;

            -- Wait one cycle for memory data to appear
            when MEM_READ_DELAY_S =>
                IRWrite     <= '1';
                next_state  <= LOAD_IR_S;

            -- Load memory data into instruction register
            when LOAD_IR_S =>
                IRWrite     <= '0';
                next_state  <= INSTRUCTION_DECODE_S;

            -- Determine instruction type
            when INSTRUCTION_DECODE_S =>
                -- Prepare ALU result for jump, set to PC+[jump offset]
                ALUSrcA     <= "00";        -- Select current PC
                ALUSrcB     <= "11";        -- Select sign extended IR[15:0]
                OpSelect    <= ALU_ADDU;

                -- R-type instruction
                if (OpCode = x"00") then
                    next_state <= R_TYPE_EXECUTION_S;
                -- I-type instruction
                elsif (OpCode = x"09" or OpCode = x"10" or OpCode = x"0C" or OpCode = x"0D" or
                        OpCode = x"0E" or OpCode = x"0A" or OpCode = x"0B") then
                    next_state <= I_TYPE_EXECUTION_S;
                -- LW/SW instructions
                elsif (OpCode = x"23" or OpCode = x"2B") then
                    next_state <= MEM_ADDR_COMP_S;
                -- Jump
                elsif (OpCode = x"02") then
                    next_state <= JUMP_COMPLETION_S;
                -- Jump and link
                elsif (OpCode = x"03") then
                    next_state <= WRITE_RETURN_ADDR_S;
                -- Branch instructions
                elsif (OpCode = x"04" or OpCode = x"05" or OpCode = x"06"
                        or OpCode = x"07" or OpCode = x"01") then
                    next_state <= BRANCH_COMPLETION_S;
                elsif (OpCode = x"3F") then
                    next_state <= HALT_S;
                -- Unreachable
                else
                    next_state <= HALT_S;
                end if;

            when R_TYPE_EXECUTION_S =>
                -- Select registers A and B as inputs to ALU
                ALUSrcA <= "01";
                ALUSrcB <= "00";

                -- Default next state (excpet for MFHI, MFLO)
                next_state <= R_TYPE_COMPLETION_S;

                case Func is
                    when FUNC_ADDU =>   -- add unsigned
                        OpSelect <= ALU_ADDU;
                    when FUNC_SUBU =>   -- sub unsigned
                        OpSelect <= ALU_SUBU;
                    when FUNC_MULT =>   -- mult
                        OpSelect <= ALU_MULT;
                        LO_en    <= '1';
                        HI_en    <= '1';
                    when FUNC_MULTU =>  -- mult unsigned
                        OpSelect <= ALU_MULTU;
                        LO_en    <= '1';
                        HI_en    <= '1';
                    when FUNC_AND =>    -- and
                        OPSelect <= ALU_AND;
                    when FUNC_OR =>     -- or
                        OPSelect <= ALU_OR;
                    when FUNC_XOR =>    -- xor
                        OPSelect <= ALU_XOR;
                    when FUNC_SRL =>    -- shift right logical
                        OPSelect <= ALU_SRL;
                    when FUNC_SLL =>     -- shift left logical
                        OpSelect <= ALU_SLL;
                    when FUNC_SRA =>    -- shift right arithmetic
                        OPSelect <= ALU_SRA;
                    when FUNC_SLT =>    -- set on less than
                        OPSelect <= ALU_SLT;
                    when FUNC_SLTU =>   -- set on less than unsigned
                        OPSelect <= ALU_SLTU;
                    when FUNC_MFHI =>   -- move from HI register
                        ALU_LO_HI <= "10";
                        MemToReg <= "00";
                        RegDst <= '1';
                        RegWrite <= '1';
                        next_state <= INSTRUCTION_FETCH_S;
                    when FUNC_MFLO =>   -- move from LO register
                        ALU_LO_HI <= "01";
                        MemToReg <= "00";
                        RegDst <= '1';
                        RegWrite <= '1';
                        next_state <= INSTRUCTION_FETCH_S;
                    when FUNC_JR =>     -- jump register
                        next_state <= JUMP_REGISTER_S;
                    when others =>      -- Hopefully unreachable
                        null;
                end case; --Func

            when I_TYPE_EXECUTION_S =>
                -- Select register A and immediate value from IR
                ALUSrcA <= "01";
                ALUSrcB <= "10";

                case OpCode is
                    when OP_ADDIU =>    -- add immediate unsigned
                        IsSigned <= '1';
                        OpSelect <= ALU_ADDU;
                    when OP_SUBIU =>    -- sub immediate unsigned
                        IsSigned <= '1';
                        OpSelect <= ALU_SUBU;
                    when OP_ANDI =>     -- and immediate
                        IsSigned <= '0';
                        OpSelect <= ALU_AND;
                    when OP_ORI =>      -- or immediate
                        IsSigned <= '0';
                        OpSelect <= ALU_OR;
                    when OP_XORI =>     -- xor immediate
                        IsSigned <= '0';
                        OpSelect <= ALU_XOR;
                    when OP_SLTI =>     -- set on less than immediate signed
                        IsSigned <= '0';
                        OpSelect <= ALU_SLT;
                    when OP_SLTIU =>    -- set on less than immediate unsigned
                        IsSigned <= '1';
                        OpSelect <= ALU_SLTU;
                    when others =>      -- unreachable
                        null;
                end case; --OpCode

                next_state <= I_TYPE_COMPLETION_S;

            when R_TYPE_COMPLETION_S =>
                -- select ALUOut
                ALU_LO_HI   <= "00";                -- Select ALU Out register as ALU MUX output
                RegDst      <= '1';                 -- Select IR[15:11], 'rd' as write destination
                RegWrite    <= '1';                 -- Enable register write
                MemToReg    <= "00";                -- Select ALU MUX output for register write data
                next_state  <= INSTRUCTION_FETCH_S; -- Go back to initial state

            when I_TYPE_COMPLETION_S =>
                -- select ALUOut
                ALU_LO_HI   <= "00";                -- Select ALU Out register as ALU MUX output
                RegDst      <= '0';                 -- Select IR[15:11], 'rt' as write destination
                RegWrite    <= '1';                 -- Enable register write
                MemToReg    <= "00";                -- Select ALU MUX output for register write data
                next_state  <= INSTRUCTION_FETCH_S; -- Go back to initial state

            when MEM_ADDR_COMP_S =>
                ALUSrcA <= "01";     -- Select IR[25:21]
                ALUSrcB <= "10";      -- Select IR[15:0], 0 extended to 32 bits
                IsSigned <= '0';
                OPSelect <= ALU_ADDU;

                if (OpCode = OP_LW) then
                    next_state <= MEM_ACCESS_READ_S;
                elsif (OpCode = OP_SW) then
                    next_state <= MEM_ACCESS_WRITE_S;
                end if;

            when MEM_ACCESS_READ_S =>
                IorD <= '1';    -- Select ALUOut register for memory address
                MemRead <= '1'; -- Enable memory 
                next_state <= LOAD_MEM_DATA_S;

            when LOAD_MEM_DATA_S =>
                -- Wait one cycle for memory to load in memory data register
                IorD <= '1';
                MemRead <= '1';
                next_state <= MEM_READ_COMPLETE_S;

            when MEM_READ_COMPLETE_S =>
                RegDst <= '0';      -- Select IR[20:16] as write address
                MemToReg <= "01";    -- Select memory data register as write data
                RegWrite <= '1';    -- Enable writing to registers
                next_state <= INSTRUCTION_FETCH_S;

            when MEM_ACCESS_WRITE_S =>
                IorD <= '1';        -- Select ALUOut register to write to memory
                MemWrite <= '1';    -- Enable writing to memory
                next_state <= MEM_WRITE_WAIT_S;

            when MEM_WRITE_WAIT_S =>
                -- Read instruction from memroy, necessary since memory read delayed by one cycle after write
                IorD        <= '0';         -- Select current PC as memory read address
                MemRead     <= '1';         -- Enable memory read
                IRWrite     <= '1';         -- Write memory output to IR
                next_state  <= INSTRUCTION_FETCH_S;

            when JUMP_COMPLETION_S =>
                PCWrite     <= '1';         -- Write jump address to PC
                PCSource    <= "10";        -- Select ALU Out register
                next_state  <= INSTRUCTION_FETCH_S;

            when WRITE_RETURN_ADDR_S =>
                JumpAndLink <= '1';         -- Enable write to r31
                MemToReg    <= "10";        -- Select PC as register write data
                RegWrite    <= '1';         -- Enable writing to registers file
                next_state  <= JUMP_COMPLETION_S;

            when JUMP_REGISTER_S =>
                PCSource    <= "11";        -- Select RegA to write to PC
                PCWrite     <= '1';
                next_state  <= INSTRUCTION_FETCH_S;

            when BRANCH_COMPLETION_S =>
                PCWriteCond <= '1';         -- PC write en will depend on branch
                ALUSrcA     <= "01";        -- Select register A
                ALUSrcB     <= "00";        -- Select register B
                PCSource    <= "01";        -- Select ALU Out register

                -- Decode OpCode further to determine branch type
                case OpCode is
                    when OP_BEQ =>
                        OPSelect <= ALU_BEQ;
                    when OP_BNE =>
                        OPSelect <= ALU_BNE;
                    when OP_BLTE =>
                        OPSelect <= ALU_BLTE;
                    when OP_BGTZ =>
                        OPSelect <= ALU_BGTZ;
                    -- Branch if less than 0 or branch if greater than or equal to zero
                    when OP_BLORGEZ =>
                        case BranchCode is
                            when x"00" =>
                                OpSelect <= ALU_BGEZ;
                            when x"01" =>
                                OpSelect <= ALU_BLTZ;
                            when others =>
                                null;
                        end case; -- BranchCode
                    when others =>
                        null;
                end case; -- OpCode

                next_state  <= INSTRUCTION_FETCH_S;

            -- Used in week 2 tests only
            when HALT_S =>
                -- Endless loop
                next_state <= state;
            
            -- Unreachable
            when others =>
                null;
        end case; --state
    end process;

    OpCode      <= resize(unsigned(IR31downto26), 8);    -- Resizing allows comparison with 8-bit hex
    Func        <= resize(unsigned(IR5downto0), 8);      -- Resizing allows comparison with 8-bit hex
    BranchCode  <= resize(unsigned(IR20downto16), 8);      -- Resizing allows comparison with 8-bit hex

end BHV;