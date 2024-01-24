library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;
use work.cpu_consts.all;

entity tb_fetch is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_fetch is


  component fetch is
  	Port (
  		clk 			: in  STD_LOGIC;
  		rst 			: in  STD_LOGIC;
  		current_state 	: in  state_type ;
  		PC_TO_ROM		: out PC_TO_ROM_type
  	);
  end component;

signal  rst,  clk : std_logic;
signal current_state : state_type;
signal PC_TO_ROM : PC_TO_ROM_type;


begin
	mapping: fetch port map(clk, rst,  current_state, PC_TO_ROM );

	main : process
	begin
		test_runner_setup(runner, runner_cfg);
		report "Start testing fetch";


		rst <= '1';
		current_state <= FETCH_STATE;

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		rst <= '0';

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		check(PC_TO_ROM  = PC_TO_ROM_ENABLED, "Test output 1" );

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		current_state <= DECODE_STATE;


		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		check(PC_TO_ROM  = PC_TO_ROM_DISABLED , "Test output 2" );

		clk <= '0';
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;

		test_runner_cleanup(runner); -- Simulation ends here
	end process;
end architecture;
