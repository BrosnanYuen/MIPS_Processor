library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
use work.cpu_consts.all;

entity tb_decode is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_decode is


	component decode is
		Port (
			clk 							: in  STD_LOGIC;
			rst 							: in  STD_LOGIC;
			current_state 		: in  state_type ;
			instruction 			: in std_logic_vector (15 downto 0) ;
			z									: in  STD_LOGIC;
			n									: in  STD_LOGIC;
			rd_index0					: out std_logic_vector(2 downto 0);
			rd_index1					: out std_logic_vector(2 downto 0);
			pc_increment			: out std_logic
		);
	end component;


signal instruction 			: std_logic_vector (15 downto 0) ;
signal  rst,  clk, z,n : std_logic;
signal current_state : state_type;
signal rd_index0, rd_index1 : std_logic_vector(2 downto 0);
signal pc_increment : std_logic;


begin
	mapping: decode port map(clk, rst,  current_state, instruction, z , n , rd_index0, rd_index1, pc_increment );

	main : process
	begin
		test_runner_setup(runner, runner_cfg);
		report "Start testing decode";

		z <= '0';
		n <= '0';
		instruction(15 downto 9) <= NOP_INSTR;
		instruction(8 downto 0) <= "000000000";
		rst <= '1';
		current_state <= RESET_STATE;

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		rst <= '0';

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		current_state <= FETCH_STATE;

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		current_state <= DECODE_STATE;
		instruction(15 downto 9) <= NOP_INSTR;
		instruction(8 downto 0) <= "000000000";

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;



		current_state <= DECODE_STATE;
		instruction(15 downto 9) <= ADD_INSTR;
		instruction(8 downto 0) <= "001010011";

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;




		current_state <= DECODE_STATE;
		instruction(15 downto 9) <= TEST_INSTR;
		instruction(8 downto 0) <= "000000011";

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;


		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;


		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;


		test_runner_cleanup(runner); -- Simulation ends here
	end process;
end architecture;
