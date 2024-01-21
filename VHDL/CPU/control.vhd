library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

entity control is
    port (
        clk, ce, rst, boot : std_logic;
        -- INSTRUCTION
        --instr : in std_logic_vector(INSTR_LENGTH - 1 downto 0);
        opcode : in std_logic_vector(OPCODE_LENGTH - 1 downto 0);
        carry : in std_logic; -- to decide if we branch or not
        
        enable_pc : out std_logic; -- pc+=1
        load_pc : out std_logic;
        clear_pc : out std_logic; -- pc=0
        load_ri : out std_logic;
        sel_addr : out std_logic;
        -- 1 : mem_addr = instr(5 downto 0)
        -- 0 : mem_addr = pc
        load_r1 : out std_logic;
        load_accu : out std_logic;
        load_carry :out std_logic;
        clear_carry : out std_logic; -- carry=0
        select_ual : out std_logic;
        -- 0 : Op = NOR
        -- 1 : Op = AND
        rw : out std_logic;
        -- 0 : Mem_Mode = Read
        -- 1 : Mem_Mode = Write
        enable_mem : out std_logic
    );
end control;

architecture behav of control is

    type state is (
        init,
        fetch_inst,
        fetch_inst_dly,
        decode,
        fetch_op,
        fetch_op_dly,
        exe_nor_add,
        exe_jcc,
        store,
        store_dly
    );

    signal current_state : state := fetch_inst;
    signal next_state : state := fetch_inst;

begin

    process_next_state : process(current_state, opcode)
    begin
        case current_state is
            when init =>
                next_state <= fetch_inst;
            when fetch_inst =>
                next_state <= fetch_inst_dly;
            when fetch_inst_dly =>
                next_state <= decode;

            when decode =>
                if opcode = "10" then
                    next_state <= store;
                 elsif opcode(1) = '0' then
                    next_state <= fetch_op;
                 else
                    next_state <= exe_jcc;
                 end if;
                                        
            when fetch_op =>
                next_state <= fetch_op_dly;
                
            when fetch_op_dly =>
                next_state <= exe_nor_add;
            when exe_nor_add =>
                next_state <= fetch_inst;
            when store_dly =>
                next_state <= fetch_inst;
            when exe_jcc =>
                next_state <= fetch_inst;
            when others =>
                null;
        end case;
    end process;

    process_current_state : process(current_state, opcode,carry)
    begin
        case current_state is
            when init =>
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '1';
                load_ri      <= '0';
                sel_addr     <= '0';
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '1';
                select_ual   <= '0';
                rw           <= '0';
                enable_mem   <= '0';
                
            when fetch_inst =>
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '0'; -- addr = pc
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '0'; -- READ
                enable_mem   <= '1'; -- memory activate

            when fetch_inst_dly =>
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '1';
                sel_addr     <= '0';
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '0';
                enable_mem   <= '1';

            when decode =>
                -- ri actu. => decode
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '1'; -- addr = AAAAAA but memory inactiv
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '0';
                enable_mem   <= '0';

            when fetch_op =>
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '1'; -- addr = AAAAAA
                load_r1      <= '1'; -- load R1
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '0'; -- READ
                enable_mem   <= '1';

            when fetch_op_dly =>
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '1';
                load_r1      <= '1';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '0';
                enable_mem   <= '1';     
                
            when exe_nor_add => -- NOR/AND instr.
                enable_pc    <= '1'; -- pc <= pc + 1
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '1';
                load_r1      <= '0';
                load_accu    <= '1';
                load_carry   <= opcode(0); -- si ADD
                clear_carry  <= '0';
                select_ual   <= opcode(0); -- ADD or NOR
                rw           <= '0';
                enable_mem   <= '0';

            when exe_jcc => -- JCC instr.
                enable_pc    <= carry; -- carry = 0 => pc <= AAAAAA
                load_pc      <= not(carry); -- carry = 1 => pc <= pc + 1
                clear_pc     <= '0';
                load_ri      <= '1'; -- RI <= AAAAAA
                sel_addr     <= '1'; -- useless ? ask teacher ??
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= carry; -- carry = 1 => carry <= 0
                select_ual   <= '0';
                rw           <= '0';
                enable_mem   <= '0';

            when store => -- STA instr.
                --MEM(AAAAAA) = ACCU
                enable_pc    <= '0';
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '1'; -- addr = AAAAAA
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '1'; -- WRITE
                enable_mem   <= '1';
                
            when store_dly =>
                enable_pc    <= '1'; -- pc <= pc + 1
                load_pc      <= '0';
                clear_pc     <= '0';
                load_ri      <= '0';
                sel_addr     <= '1'; -- addr = AAAAAA
                load_r1      <= '0';
                load_accu    <= '0';
                load_carry   <= '0';
                clear_carry  <= '0';
                select_ual   <= '0';
                rw           <= '1'; --WRITE
                enable_mem   <= '0'; -- ask teacher ?? why not 1


            when others =>
                null;
        end case;
    end process;

    process_synch : process(clk, rst)
    begin
        if (rising_edge(clk) and ce = '1') then
            if (rst='1' or boot = '1') then
                current_state <= init;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

end behav ; -- behav