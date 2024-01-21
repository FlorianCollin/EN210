library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

entity Processing_unit is
    port (
        clk, rst, ce : in std_logic;
        -- UM
        data_in : in std_logic_vector(DATA_LENGTH - 1 downto 0); -- R1
        data_out : out std_logic_vector(DATA_LENGTH - 1 downto 0);

        -- UC
        -- in
        load_R1 : in std_logic;
        load_accu : in std_logic;
        load_carry : in std_logic;
        init_carry : in std_logic;
        sel_UAL : in std_logic_vector(2 downto 0); -- aluop

        -- out
        carry : out std_logic
    );
end Processing_unit;

architecture behav of Processing_unit is

-- component

component alu is
    port (
        e1, e2 : in std_logic_vector(DATA_LENGTH - 1 downto 0);
        alu_control_selector : in std_logic; -- un bit (instr(6) ou opcode(0)) suffit NOR ou ADD 
        alu_result : out std_logic_vector(DATA_LENGTH - 1 downto 0);
        carry : out std_logic -- actualiser si ADD
    );
end component;

component registre is 
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
end component;

component registre_carry is 
    port (
        clk, rst, ce: in std_logic;
        data_in : in std_logic;
        load : in std_logic;
        clear : in std_logic;
        data_out : out std_logic
    );
end component;

    -- constants
    constant ZERO : std_logic := '0';
    -- signals
    signal s_alu_output, s_accu_out, s_r1_out, s_alu_out: std_logic_vector(DATA_LENGTH - 1 downto 0); 
    signal s_carry : std_logic;
    signal s_data_in : std_logic_vector(DATA_LENGTH - 1 downto 0);
    signal s_sel_UAL : std_logic;
begin
    s_data_in <= data_in;
    data_out <= s_accu_out;
    s_sel_UAL <= sel_UAL(0);
    
    inst_registre_carry : registre_carry
    port map (
        clk => clk,
        rst => rst,
        ce => ce,
        data_in => s_carry,
        load => load_carry,
        clear => init_carry,
        data_out => carry
    );

    inst_accu_registre : registre
    generic map (
        data_size => DATA_LENGTH
    )
    port map (
        ce => ce,
        clk => clk,
        rst => rst,
        data_in => s_alu_out,
        load => load_accu,
        clear => ZERO, -- tjr à zero
        data_out => s_accu_out -- UM data_in
    );

    inst_r1_registre : registre
    generic map (
        data_size => DATA_LENGTH
    )
    port map (
        ce => ce,
        clk => clk,
        rst => rst,
        data_in => s_data_in,
        load => load_R1,
        clear => ZERO, -- tjr zero
        data_out => s_r1_out
    );

    inst_alu : alu
    port map (
        e1 => s_r1_out,
        e2 => s_accu_out,
        alu_control_selector => s_sel_UAL,
        alu_result => s_alu_out,
        carry => s_carry
    );

end behav ; -- behav