-- ALU / UAL

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;


entity alu is
    port (
        e1, e2 : in std_logic_vector(DATA_LENGTH - 1 downto 0);
        alu_control_selector : in std_logic; -- un bit (instr(6) ou opcode(0)) suffit NOR ou ADD 
        alu_result : out std_logic_vector(DATA_LENGTH - 1 downto 0);
        carry : out std_logic -- actualiser si ADD
    );
end alu;

architecture behav of alu is

    signal tmp: unsigned (DATA_LENGTH downto 0);
    signal s_alu_result : std_logic_vector(DATA_LENGTH - 1 downto 0) := (others => '0');

begin

    process(e1, e2, alu_control_selector)
    begin
        case alu_control_selector is
            -- nor
            when '0' =>
                s_alu_result <= e1 nor e2;

            -- add
            when '1' =>
                s_alu_result <= std_logic_vector(unsigned(e1) + unsigned(e2));
        
            when others =>
                null;

        end case;

    end process;

    tmp <= ('0' & unsigned(e1)) + ('0' & unsigned(e2));
    carry <= tmp(8);
    alu_result <= s_alu_result;
            
end behav ; -- behav