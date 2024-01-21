library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

entity pc is
    port (
        clk : in std_logic;
        rst : in std_logic;
        ce : in std_logic;
        clear : in std_logic;
        load : in std_logic; -- pc_out <= pc_in
        enable : in std_logic; -- pc_out <= pc+ 1
        pc_in : in std_logic_vector(INSTR_DATA_MEM_LENGTH - 1 downto 0);
        pc_out : out std_logic_vector(INSTR_DATA_MEM_LENGTH - 1 downto 0)
    );
end pc;

architecture behav of pc is
signal s_pc : std_logic_vector(INSTR_DATA_MEM_LENGTH - 1 downto 0);
begin

    process(clk, rst, pc_in, enable, load, clear)
    begin
        if rst = '1' then
            s_pc <= (others => '0'); -- reset
        elsif rising_edge(clk) and ce = '1' then
            if clear = '1' then
                s_pc <= (others => '0'); -- reset
            elsif enable = '1' then 
                s_pc <= std_logic_vector(unsigned(s_pc) + 1);
            elsif load = '1' then
                s_pc <= pc_in;
            end if;
        end if;
    end process;

    pc_out <= s_pc;

end behav ; -- behav