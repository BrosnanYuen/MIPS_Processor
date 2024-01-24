LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.cpu_consts.all;


entity fetch is
	Port (
		clk 			: in  STD_LOGIC;
		rst 			: in  STD_LOGIC;
		current_state 		: in  stage_state_type ;
		program_counter     : in  std_logic_vector (15 downto 0);

		--PC_TO_ROM		: out PC_TO_ROM_type
		instruction     : out std_logic_vector (15 downto 0)
	);
end fetch;

architecture Behavioral of fetch is


	type ROM_TYPE is array (0 to 127 ) of std_logic_vector (15 downto 0);

	constant rom_content : ROM_TYPE := (
		0000 => "0100001001000000", -- 		IN				r1
		0001 => "0010010011111111", -- 		LOADIMM.LOWER	0xff
		0002 => "0010010111111111", -- 		LOADIMM.UPPER	0xff
		0003 => "0100000111000000", -- 		OUT				r7
		0004 => "0010010100000000", -- 		LOADIMM.UPPER	0x00
		0005 => "0010010000000111", -- 		LOADIMM.LOWER	0x07
		0006 => "0000010010111001", -- 		SUB				r2 r7 r1
		0007 => "0000111010000000", -- 		TEST			r2
		0008 => "1000001000010001", -- 		BRR.N			ERROR
		0009 => "0000111001000000", -- 		TEST			r1
		0010 => "1000010000001111", -- 		BRR.Z			ERROR
		0011 => "1000001000001110", -- 		BRR.N			ERROR
		0012 => "0010011010001000", -- 		MOV				r2 r1
		0013 => "0010010100000000", -- 		LOADIMM.UPPER	0x00
		0014 => "0010010000000001", -- 		LOADIMM.LOWER	0x01
		0015 => "0000010001001111", -- LOOP.START:	SUB			r1 r1 r7
		0016 => "0000111001000000", -- 		TEST			r1
		0017 => "1000010000000011", -- 		BRR.Z			LOOP.EXIT
		0018 => "0000011010010001", -- 		MUL				r2 r2 r1
		0019 => "1000000111111100", -- 		BRR				LOOP.START
		0020 => "0100000010000000", -- LOOP.EXIT:	OUT			r2
		0021 => "0000000000000000", -- 		NOP
		0022 => "0000000000000000", -- 		NOP
		0023 => "0000000000000000", -- 		NOP
		0024 => "1000000111111100", -- 		BRR	LOOP.EXIT
		0025 => "0010010101010101", -- ERROR:	LOADIMM.UPPER	0x55
		0026 => "0010010001010101", -- 		LOADIMM.LOWER	0x55
		0027 => "0100000111000000", -- 		OUT				r7
		0028 => "0000000000000000", -- 		NOP
		0029 => "0000000000000000", -- 		NOP
		0030 => "0000000000000000", -- 		NOP
		0031 => "0000000000000000", -- 		NOP
		0032 => "0000000000000000", -- 		NOP
		0033 => "1000000111111000", -- 		BRR				ERROR
		0034 => "0001000000000000", -- 		HALT
others => x"0000" ); -- NOP



begin


process(clk,rst,current_state,program_counter)
begin
	--if (rising_edge(clk)) then
	--if (falling_edge(clk)) then
			if (rst = '1') then --RESET
					instruction <= rom_content(to_integer(unsigned(program_counter(7 downto 1))));
			else

				case current_state is

					when RESET_STATE =>
							instruction <= rom_content(to_integer(unsigned(program_counter(7 downto 1))));

					when RUN_STATE =>
							instruction <= rom_content(to_integer(unsigned(program_counter(7 downto 1))));

					when STALL_STATE =>
							instruction <= (others => '0');

					when others =>

				end case;


			end if;
	--end if;


end process;

end Behavioral;
