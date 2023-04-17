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
        PCWriteCond     : out std_logic;
        PCWrite         : out std_logic;
        IorD            : out std_logic;
        MemRead         : out std_logic;
        MemWrite        : out std_logic;
        MemToReg        : out std_logic;
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

    type STATE_TYPE is (INSTRUCTION_FETCH_S, LOAD_IR_S, INSTRUCTION_DECODE_S, MEM_ADDR_COMP_S, 
                        MEM_ACCESS_READ_S, MEM_ACCESS_WRITE_S, LOAD_MEM_DATA_S, MEM_READ_COMPLETION_S, 
                        R_TYPE_EXECUTION_S, I_TYPE_EXECUTION_S, R_TYPE_COMPLETION_S, I_TYPE_COMPLETION_S, 
                        BRANCH_COMPLETION_S, JUMP_COMPLETION_S, HALT_S);
    signal state, next_state    : STATE_TYPE;
    signal OpCode               : unsigned(7 downto 0);
    signal Func                 : unsigned(7 downto 0);

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
        MemToReg    <= '0';
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
                IRWrite     <= '1';         -- Write memory output to IR
                -- Load PC with PC+4
                ALUSrcA     <= "00";         -- Select current PC
                ALUSrcB     <= "01";        -- Select '4'
                OpSelect    <= ALU_ADDU;    -- Add unsigned
                PCSource    <= "00";        -- ALU result
                PCWrite     <= '1';         -- Enable PC reg write
                -- Next step is to load IR from output of memory
                next_state <= LOAD_IR_S;

            -- Wait one cycle for memory output to appear in IR
            when LOAD_IR_S =>
                IRWrite     <= '0';
                next_state  <= INSTRUCTION_DECODE_S;

            -- Determine instruction type
            when INSTRUCTION_DECODE_S =>
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
                elsif (OpCode = x"3F") then
                    next_state <= HALT_S;
                -- Unreachable
                else
                    null;
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
                        MemToReg <= '0';
                        RegDst <= '1';
                        RegWrite <= '1';
                        next_state <= INSTRUCTION_FETCH_S;
                    when FUNC_MFLO =>   -- move from LO register
                        ALU_LO_HI <= "01";
                        MemToReg <= '0';
                        RegDst <= '1';
                        RegWrite <= '1';
                        next_state <= INSTRUCTION_FETCH_S;
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
                MemToReg    <= '0';                 -- Select ALU MUX output for register write data
                next_state  <= INSTRUCTION_FETCH_S; -- Go back to initial state

            when I_TYPE_COMPLETION_S =>
                -- select ALUOut
                ALU_LO_HI   <= "00";                -- Select ALU Out register as ALU MUX output
                RegDst      <= '0';                 -- Select IR[15:11], 'rt' as write destination
                RegWrite    <= '1';                 -- Enable register write
                MemToReg    <= '0';                 -- Select ALU MUX output for register write data
                next_state  <= INSTRUCTION_FETCH_S; -- Go back to initial state

            when MEM_ADDR_COMP_S =>
                ALUSrcA <= "10";     -- Select IR[25:21]
                ALUSrcB <= "10";    -- Select IR[15:0], 0 extended to 32 bits
                IsSigned <= '0';
                OPSelect <= ALU_ADDU;

                if (OpCode = OP_LW) then
                    next_state <= MEM_ACCESS_READ_S;
                elsif (OpCode = OP_SW) then
                    next_state <= MEM_ACCESS_WRITE_S;
                end if;

            when MEM_ACCESS_READ_S =>
                IorD <= '1';    -- Select ALUOut register for memory address
                MemRead <= '1'; -- Enable memory read
                next_state <= LOAD_MEM_DATA_S;

            when LOAD_MEM_DATA_S =>
                -- Wait one cycle for memory to load in memory data register
                IorD <= '1';
                MemRead <= '1';
                next_state <= MEM_READ_COMPLETION_S;

            when MEM_READ_COMPLETION_S =>
                RegDst <= '0';      -- Select IR[20:16] as write address
                MemToReg <= '1';    -- Select memory data register as write data
                RegWrite <= '1';    -- Enable writing to registers
                next_state <= INSTRUCTION_FETCH_S;

            when MEM_ACCESS_WRITE_S =>
                IorD <= '1';        -- Select ALUOut register to write to memory
                MemWrite <= '1';    -- Enable writing to memory
                next_state <= INSTRUCTION_FETCH_S;

            when HALT_S =>
                -- Endless loop
                next_state <= state;
            
            -- Unreachable
            when others =>
                null;
        end case; --state
    end process;

    OpCode <= resize(unsigned(IR31downto26), 8);    -- Resizing allows comparison with 8-bit hex
    Func   <= resize(unsigned(IR5downto0), 8);      -- Resizing allows comparison with 8-bit hex

end BHV;