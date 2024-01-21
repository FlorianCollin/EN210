LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_hex_file is
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
end read_hex_file;

architecture Behavioral of read_hex_file is

signal data_counter : integer range 0 to line_size-1;
signal buf_data : std_logic_vector(data_size-1 downto 0);
signal char1, char2 : character;

function f_char_2_slv (char : in character)
    return std_logic_vector is
    variable v_TEMP : std_logic_vector(3 downto 0);
  begin
    if (char = '0') then
      v_TEMP := X"0";
    elsif (char = '1') then
      v_TEMP := X"1";
    elsif (char = '2') then
      v_TEMP := X"2";
    elsif (char = '3') then
      v_TEMP := X"3";
    elsif (char = '4') then
      v_TEMP := X"4";
    elsif (char = '5') then
      v_TEMP := X"5";
    elsif (char = '6') then
      v_TEMP := X"6";
    elsif (char = '7') then
      v_TEMP := X"7";
    elsif (char = '8') then
      v_TEMP := X"8";
    elsif (char = '9') then
      v_TEMP := X"9";
    elsif (char = 'A') then
      v_TEMP := X"A";
    elsif (char = 'B') then
      v_TEMP := X"B";
    elsif (char = 'C') then
      v_TEMP := X"C";
    elsif (char = 'D') then
      v_TEMP := X"D";
    elsif (char = 'E') then
      v_TEMP := X"E";
    elsif (char = 'F') then
      v_TEMP := X"F";
    else
      v_TEMP := "XXXX";  
    end if;
    return std_logic_vector(v_TEMP);
  end;
  
  
begin

	-- keep track of the value index in the current parsed line
	data_count : process(rst,clk)
	begin
		if(rst = '1') then
			data_counter <= 0;
		elsif(clk'event and clk = '1') then
			if(enable = '1') then
				if(data_counter = 0) then
					data_counter <= line_size - 1;
				else
					data_counter <= data_counter  - 1;
				end if;
			end if;
		end if;
	end process;

	-- parse file
	process(rst,clk)
		FILE data_file     : TEXT OPEN read_mode IS file_name;
		VARIABLE data_line : line;
		variable tmp : integer;
		variable ms_char, ls_char : character;
	BEGIN
		if(rst = '1') then
			buf_data <= (others => '0');
		elsif(clk'event and clk = '1') then
			if(data_counter = 0 and enable = '1' and rst = '0') then
				IF NOT endfile(data_file) THEN
					readline(data_file, data_line);
					read(data_line, ms_char);
				end if;				
			end if;
			--if(enable = '1') then
			     read(data_line, ls_char);
			     char1 <= ms_char;
			     char2 <= ls_char;
			--end if;
			--buf_data <=  std_logic_vector(to_unsigned(tmp,data_size));
		END IF;        
	END PROCESS;
	
	
    
	
	stream_out <= f_char_2_slv(char1)&f_char_2_slv(char2);
	
	
end Behavioral;
