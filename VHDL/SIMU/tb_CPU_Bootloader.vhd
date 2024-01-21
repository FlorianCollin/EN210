library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.constants_pkg.all;


entity tb_CPU_Bootloader is
end tb_CPU_Bootloader;

architecture Behavioral of tb_CPU_Bootloader is

component CPU_Bootloader_Collin is
    generic(RAM_ADR_WIDTH : integer := 6;
            RAM_SIZE      : integer := 64);
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           ce : in STD_LOGIC;
           scan_memory : in std_logic;
           rx : in STD_LOGIC;
           tx : out STD_LOGIC);
end component;

component read_int_file is
generic (
		file_name:       string  := "default.txt";
		line_size:			integer := 32;
		symb_max_val : integer := 3;
		data_size : integer := 2
	 );
port(	clk : in  STD_LOGIC;
		rst : in std_logic;
		enable : in  STD_LOGIC;
		stream_out : out STD_LOGIC_vector(data_size-1 downto 0));
end component;

component byte_2_word is
    Port ( rst : in  std_logic;
           clk : in  std_logic;
		   ce : in  std_logic;
           byte_dv : in  std_logic;
           byte : in  std_logic_vector (7 downto 0);
           word_dv : out  std_logic;
           word : out  std_logic_vector (15 downto 0));
end component;

component word_2_byte is
    Port ( rst : in  std_logic;
           clk : in  std_logic;
		   ce : in  std_logic;
           word_dv : in  std_logic;
           word : in  std_logic_vector (15 downto 0);
           byte_dv : out  std_logic;
           byte : out  std_logic_vector (7 downto 0));
end component;


component read_hex_file is
generic (
		file_name:       string  := "default.txt";
		line_size:			integer := 32;
		symb_max_val : integer := 3;
		data_size : integer := 2
	 );
port(	clk : in  STD_LOGIC;
		rst : in std_logic;
		enable : in  STD_LOGIC;
		stream_out : out STD_LOGIC_vector(data_size-1 downto 0));
end component;


component UART_fifoed_send is
    Generic ( fifo_size             : integer := 4096;
              fifo_almost           : integer := 4090;
              drop_oldest_when_full : boolean := False;
              asynch_fifo_full      : boolean := True;
              baudrate              : integer := 921600;   -- [bps]
              clock_frequency       : integer := 100000000 -- [Hz]
    );
    Port (
        clk_100MHz : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        dat_en     : in  STD_LOGIC;
        dat        : in  STD_LOGIC_VECTOR (7 downto 0);
        TX         : out STD_LOGIC;
        fifo_empty : out STD_LOGIC;
        fifo_afull : out STD_LOGIC;
        fifo_full  : out STD_LOGIC
    );
end component;

component UART_recv is
   Port ( clk    : in  STD_LOGIC;
          reset  : in  STD_LOGIC;
          rx     : in  STD_LOGIC;
          dat    : out STD_LOGIC_VECTOR (7 downto 0);
          dat_en : out STD_LOGIC);
end component;

component write_int_file is
	 generic (
		log_file:       string  := "results.log";
		frame_size:			integer := 203;
		symb_max_val : integer := 255;
		data_size : integer := 8
	 );
	 port(
		CLK              : in std_logic;
		RST              : in std_logic;
		data_valid       : in std_logic;
		data             : in std_logic_vector(data_size-1 downto 0)
	 );
end component;
  
signal clk : STD_LOGIC := '0';
signal rst : STD_LOGIC;
signal ce : STD_LOGIC;
signal scan_memory : std_logic;
signal rx : STD_LOGIC;
signal tx : STD_LOGIC;

signal ce_dly : std_logic;
signal tx_data_valid : std_logic;
signal tx_byte : std_logic_vector(7 downto 0);
signal tx_byte_hex : std_logic_vector(7 downto 0);

signal tx_data_16b: std_logic_vector(15 downto 0);

signal prog_out : std_logic_vector(7 downto 0);
signal prog_out_dv : std_logic;

signal byte_count : unsigned(5 downto 0);
signal cycle_count : unsigned(14 downto 0);
signal enable_push, enable_push_dly : std_logic;
signal enable_push_tx_byte : std_logic;

signal prog_out_dv_dly : std_logic;
signal rx_word_valid  : std_logic;
signal rx_word  : std_logic_vector(15 downto 0);
signal prog_out_reg, prog_out_reg2 : std_logic_vector(7 downto 0); 
signal rx_byte_count : unsigned(1 downto 0);

begin

------------------------------------------------
-- control CPU signal generation
------------------------------------------------

clk <= not(clk) after 5 ns;
rst <= '1', '0' after 113 ns;
scan_memory <= '0', '1' after 30 ms;
ce <= '1';

process(rst, clk)
begin
    if (rst = '1') then
        byte_count <= (others => '0');
        enable_push <= '0';
        cycle_count <= (others => '0');
    elsif ( rising_edge(clk)) then

        --- FOR SIM 2 SINON 18000 !!!!!!!!!!!!!!!!!!!!!!!!!

        -- enable_push = 1 tout les 18000*Th pendant une période d'horloge
        if(cycle_count = to_unsigned(18000,15)) then -- cyclec_count_max = 18000
            cycle_count <= (others => '0');
            enable_push <= '1';
            byte_count <= byte_count + to_unsigned(1,6);
        else
            cycle_count <= cycle_count + to_unsigned(1,15);
            enable_push <= '0';
            byte_count <= byte_count;                        
        end if;
    end if;
end process;

------------------------------------------------
-- program file reader
------------------------------------------------

process(rst, clk)
begin
    if (rst = '1') then
        enable_push_dly <= '0';
    elsif ( rising_edge(clk)) then
        enable_push_dly <= enable_push;
    end if;
end process;


inst_read_file : read_int_file
generic map(file_name => "D:\Code\VHDL\EN210\mini-cpu\test.txt",
            -- ASK TEACHER WHY ?
            line_size => 1,
            symb_max_val => 65535,
            data_size => 16) -- 16 bits instrucitons
port map(	clk => clk,
            rst => rst,
            enable => enable_push,
            stream_out => tx_data_16b);

--inst_read_hex_file : read_hex_file
--generic map(file_name => "program_hex.txt",
--            line_size => 1,
--            symb_max_val => 255,
--            data_size => 8)
--port map(	clk => clk,
--            rst => rst,
--            enable => enable_push,
--            stream_out => tx_byte_hex);

------------------------------------------------
-- convert 16-bits words into bytes
------------------------------------------------

w2b:  word_2_byte 
    Port map( rst => rst,
           clk => clk,
		   ce => ce,
           word_dv => enable_push_dly,
           word => tx_data_16b,
           byte_dv => enable_push_tx_byte,
           byte => tx_byte);

--------------------------------------------------
---- UART TX
--------------------------------------------------
            
inst_uart_send : UART_fifoed_send 
generic map(fifo_size             => 4,
            fifo_almost           => 2,
            drop_oldest_when_full => false,
            asynch_fifo_full      => true,
            baudrate              => 115200,
            clock_frequency       => 100000000)
port map(
            clk_100MHz => clk,
            reset      => rst,
            dat_en     => enable_push_tx_byte,
            dat        => tx_byte,
            TX         => rx,
            fifo_empty => open,
            fifo_afull => open,
            fifo_full  => open);

--------------------------------------------------
---- Unit Under Test : CPU
--------------------------------------------------
            
inst_CPU : CPU_Bootloader_Collin 
    generic map(RAM_ADR_WIDTH =>6,
                RAM_SIZE => 64) 
    Port map(   clk => clk,
                rst => rst,
                ce  => ce,
                scan_memory => scan_memory,
                rx  => rx,
                tx  => tx);

--------------------------------------------------
---- UART RX
--------------------------------------------------
                            
inst_uart_rx : UART_recv
   Port map( clk => clk,
          reset => rst,
          rx => tx,
          dat => prog_out,
          dat_en => prog_out_dv);


--------------------------------------------------
---- Convert to 16 bits words
--------------------------------------------------

b2w : byte_2_word 
    Port map ( rst => rst,
           clk => clk,
		   ce => ce,
           byte_dv => prog_out_dv,
           byte => prog_out,
           word_dv => rx_word_valid,
           word => rx_word);


--------------------------------------------------
---- memory file writer
--------------------------------------------------

inst_write_file : write_int_file 
	 generic map(
		log_file => "ram_out.txt",
		frame_size => 1,
		symb_max_val => 65535, 
		data_size => 16
	 )
	 port map(
		CLK => clk,
		RST => rst,
		data_valid => rx_word_valid,
		data => rx_word
	 );

end Behavioral;
