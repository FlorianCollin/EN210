library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

-- simple D-FF

entity registre is 
    generic (
        data_size : integer := 8
    );
    port (
        clk, rst, ce: in std_logic;
        data_in : in std_logic_vector(data_size - 1 downto 0);
        load : in std_logic;
        clear : in std_logic;
        data_out : out std_logic_vector(data_size - 1 downto 0)
    );
end registre;

architecture behav of registre is
    begin
    process(clk, rst, data_in, ce, load, clear)
    begin
        if rst = '1' then
            data_out <= (others => '0'); -- no carry
        elsif rising_edge(clk) then
            if ce = '1' then
                if load = '1' then
                    data_out <= data_in;
                elsif clear = '1' then
                    data_out <= (others => '0');
                end if;
            end if;
        end if;           
    end process;
end behav;