-- control unit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.constants_pkg.all;

entity Control_Unit is
    generic (RAM_ADR_WIDTH : INTEGER := 6);
    port (
        clk, rst, ce: in std_logic;
        ------------------------------------------------------------------------------
        -- control signals
        -- UT
        -- in
        carry : in std_logic;
        boot : in std_logic;
        -- out
        load_R1 : out std_logic;
        load_accu : out std_logic;
        load_carry :out std_logic;
        clear_carry : out std_logic;
        sel_UAL : out std_logic;
        --UM
        w_mem : out std_logic;
        enable_mem : out std_logic;
        ------------------------------------------------------------------------------
        -- data signals
        -- memory address
        adr : out std_logic_vector(INSTR_DATA_MEM_LENGTH - 1 downto 0);
        -- instruction mem
        data_in : in std_logic_vector(INSTR_LENGTH - 1 downto 0)
    );
end Control_Unit;

architecture behav of Control_Unit is

    -- components :

    -- FSM control :

    component control is
        port (
            clk, ce, rst, boot: std_logic;
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
    end component;
    

    -- registre d'instruciton : data_size = INSTR_LENGTH
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

    component pc is
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
    end component;

    component mux is
        generic (
            input_size : integer := 64
        );
        port (
            e0, e1 : in std_logic_vector(input_size - 1  downto 0);
            s : in std_logic;
            q : out std_logic_vector(input_size - 1 downto 0)
        );
    end component;


    signal s_enable_pc : std_logic;
    signal s_load_pc : std_logic;
    signal s_clear_pc : std_logic;
    signal s_load_ri : std_logic;
    signal s_sel_addr : std_logic;

    -- instruction signals

    signal s_instr : std_logic_vector(INSTR_LENGTH - 1 downto 0);
    signal s_instr_addr : std_logic_vector(INSTR_DATA_MEM_LENGTH - 1 downto 0);
    signal s_instr_op : std_logic_vector(OPCODE_LENGTH - 1 downto 0);

    --

    signal s_mux_0 : std_logic_vector(INSTR_DATA_MEM_LENGTH - 1 downto 0);
    -- constants
    constant ZERO : std_logic := '0';

begin

    s_instr_addr <= s_instr(5 downto 0);
    s_instr_op <= s_instr(7 downto 6);

    -- pc

    inst_pc : pc
    port map(
        clk => clk,
        rst => rst,
        ce => ce,
        clear => s_clear_pc,
        load => s_load_pc,
        enable => s_enable_pc,
        pc_in => s_instr_addr,
        pc_out => s_mux_0
    );

    inst_ri : registre
    generic map(
        data_size => INSTR_LENGTH
    )
    port map(
        clk => clk,
        rst => rst,
        ce => ce,
        load => s_load_ri,
        clear => ZERO,
        data_in => data_in,
        data_out => s_instr
    );

    inst_control : control
    port map(
        clk => clk,
        rst => rst,
        ce => ce,
        boot => boot,
        opcode => s_instr_op,
        carry => carry,
        enable_pc => s_enable_pc, 
        load_pc => s_load_pc,
        clear_pc => s_clear_pc,
        load_ri => s_load_ri,
        sel_addr => s_sel_addr,
        load_r1 => load_R1,
        load_accu => load_accu,
        load_carry => load_carry,
        select_ual => sel_UAL,
        rw => w_mem,
        enable_mem => enable_mem
    );

    inst_mux : mux
    generic map(
        input_size => INSTR_DATA_MEM_LENGTH
    )
    port map(
        e0 => s_mux_0,
        e1 => s_instr_addr,
        s => s_sel_addr,
        q => adr -- mem addr
    );

end behav ; -- behav