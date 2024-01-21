-- Memory unit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

entity RAM_SP_64_8 is
    GENERIC (
            NbBits : INTEGER := 16; -- DATA_LENGTH
            Nbadr : INTEGER := 6 -- INSTR_DATA_MEM_LENGTH
    ); 
    port (
        clk, rst, ce: in std_logic;
        enable : in std_logic;
        r_w : in std_logic;
        add : in std_logic_vector(Nbadr - 1 downto 0);
        data_in : in std_logic_vector(NbBits - 1 downto 0);
        data_out : out std_logic_vector(NbBits - 1 downto 0)
    );
end RAM_SP_64_8;

architecture behav of RAM_SP_64_8 is

    
    type mem_array is array (0 to 2**INSTR_DATA_MEM_LENGTH - 1) of std_logic_vector(DATA_LENGTH - 1 downto 0);
    signal memory : mem_array := (others => (others => '0'));

begin

    process(clk, rst, ce, enable, r_w, add, data_in)
    begin
        -- asynch. reset
        if rst = '1' then 
            memory <= (others => (others => '0'));
        
        elsif rising_edge(clk) and ce = '1' and enable = '1' then
            if r_w = '1' then -- write mode
                memory(to_integer(unsigned(add))) <= data_in;
            else -- r_w = '0' -- read mode
                data_out <= memory(to_integer(unsigned(add)));
            end if;
        end if;
    end process;
end behav;