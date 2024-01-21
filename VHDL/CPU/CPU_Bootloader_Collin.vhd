LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
library work;
use work.constants_pkg.all;

ENTITY CPU_Bootloader_Collin IS
    GENERIC (
        RAM_ADR_WIDTH : INTEGER := 6;
        RAM_SIZE : INTEGER := 64);
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ce : IN STD_LOGIC;
        scan_memory : IN STD_LOGIC;
        rx : IN STD_LOGIC;
        tx : OUT STD_LOGIC);
END CPU_Bootloader_Collin;

ARCHITECTURE Behavioral OF CPU_Bootloader_Collin IS

    COMPONENT boot_loader IS
        GENERIC (
            RAM_ADR_WIDTH : INTEGER := 6;
            RAM_SIZE : INTEGER := 64);
        PORT (
            rst : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            ce : IN STD_LOGIC;
            rx : IN STD_LOGIC;
            tx : OUT STD_LOGIC;
            boot : OUT STD_LOGIC;
            scan_memory : IN STD_LOGIC;
            ram_out : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ram_rw : OUT STD_LOGIC;
            ram_enable : OUT STD_LOGIC;
            ram_adr : OUT STD_LOGIC_VECTOR(RAM_ADR_WIDTH - 1 DOWNTO 0);
            ram_in : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
    END COMPONENT;

    component Control_Unit is
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
    end component;

    component Processing_unit is
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
    end component;

    component RAM_SP_64_8 is
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
    end component;

    SIGNAL UT_data_out : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL sig_adr : STD_LOGIC_VECTOR (RAM_ADR_WIDTH - 1 DOWNTO 0);
    SIGNAL carry : STD_LOGIC;
    SIGNAL clear_carry : STD_LOGIC;
    SIGNAL enable_mem : STD_LOGIC;
    SIGNAL load_R1 : STD_LOGIC;
    SIGNAL load_accu : STD_LOGIC;
    SIGNAL load_carry : STD_LOGIC;
    SIGNAL sel_UAL_UT : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL sel_UAL_UC : STD_LOGIC;
    SIGNAL w_mem : STD_LOGIC;

    SIGNAL ram_data_in, ram_data_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL ram_enable : STD_LOGIC;

    SIGNAL sig_rw : STD_LOGIC;
    SIGNAL sig_ram_enable : STD_LOGIC;
    SIGNAL sig_ram_adr : STD_LOGIC_VECTOR(RAM_ADR_WIDTH - 1 DOWNTO 0);
    SIGNAL sig_ram_in : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL boot : STD_LOGIC;
    SIGNAL boot_ram_adr : STD_LOGIC_VECTOR(RAM_ADR_WIDTH - 1 DOWNTO 0);
    SIGNAL boot_ram_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL boot_ram_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL boot_ram_rw : STD_LOGIC;
    SIGNAL boot_ram_enable : STD_LOGIC;

BEGIN
    UC : Control_unit
    GENERIC MAP(RAM_ADR_WIDTH => RAM_ADR_WIDTH)
    PORT MAP(
        clk => clk,
        ce => ce,
        rst => rst,
        carry => carry,
        boot => boot,
        data_in => ram_data_out,
        adr => sig_adr,
        clear_carry => clear_carry,
        enable_mem => enable_mem,
        load_R1 => load_R1,
        load_accu => load_accu,
        load_carry => load_carry,
        sel_UAL => sel_UAL_UC,
        w_mem => w_mem);

    sel_UAL_UT <= "00" & sel_UAL_UC;

    UT : Processing_unit PORT MAP(
        data_in => ram_data_out,
        clk => clk,
        ce => ce,
        rst => rst,
        load_R1 => load_R1,
        load_accu => load_accu,
        load_carry => load_carry,
        init_carry => clear_carry,
        sel_UAL => sel_UAL_UT,
        data_out => UT_data_out,
        carry => carry);

    BL : boot_loader GENERIC MAP(
        RAM_ADR_WIDTH => RAM_ADR_WIDTH,
        RAM_SIZE => RAM_SIZE)
    PORT MAP(
        rst => rst,
        clk => clk,
        ce => ce,
        rx => rx,
        tx => tx,
        boot => boot,
        scan_memory => scan_memory,
        ram_out => ram_data_out,
        ram_rw => boot_ram_rw,
        ram_enable => boot_ram_enable,
        ram_adr => boot_ram_adr,
        ram_in => boot_ram_in);

    -- boot controled MUX for RAM signal 
    sig_rw <= boot_ram_rw WHEN boot = '1' ELSE
        w_mem;
    sig_ram_enable <= boot_ram_enable WHEN boot = '1' ELSE
        enable_mem;
    sig_ram_adr <= boot_ram_adr WHEN boot = '1' ELSE
        sig_adr;
    sig_ram_in <= boot_ram_in WHEN boot = '1' ELSE
        UT_data_out;

    UM : RAM_SP_64_8
    GENERIC MAP(
        NbBits => 16,
        Nbadr => RAM_ADR_WIDTH)
    PORT MAP(
        rst => rst,
        add => sig_ram_adr,
        data_in => sig_ram_in,
        r_w => sig_rw,
        enable => sig_ram_enable,
        clk => clk,
        ce => ce,
        data_out => ram_data_out);

END Behavioral;