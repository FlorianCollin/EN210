library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

entity mux is
    generic (
        input_size : integer := 64
    );
    port (
        e0, e1 : in std_logic_vector(input_size - 1  downto 0);
        s : in std_logic;
        q : out std_logic_vector(input_size - 1 downto 0)
    );
end mux;

architecture behav of mux is
    signal s_q : std_logic_vector(input_size - 1 downto 0) := (others => '0');

begin

    process(e0, e1, s)
    begin
        if s = '1' then
            s_q <= e1;
        else
            s_q <= e0;   
        end if;
    end process;

    q <= s_q;
end behav ; -- behav