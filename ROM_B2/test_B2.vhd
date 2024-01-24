library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;


entity test_B2 is
  generic (runner_cfg : string);
end entity;

architecture tb of test_B2 is



component cpu is
    Port (
		clk : in std_logic;
		rst : in std_logic;
		in_data : in std_logic_vector(7 downto 0);

		out_data : out std_logic_vector(7 downto 0)
	);
end component;



signal  input_clk , input_rst : std_logic;
signal  input, output :std_logic_vector(7 downto 0);

begin
	cpu0: cpu port map(input_clk, input_rst,input,output  );

	main : process
	begin
		test_runner_setup(runner, runner_cfg);
		report "Start testing CPU";

		 input_rst <= '1';
		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		input_rst <= '0';

		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		input <= "00011100";

		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;


		input <= "00000011";


		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;


		input <= "00000001";

		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;


		input <= "00000101";


		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;


		input <= "00010010";


		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;



		input <= "00000001";


		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;



		input <= "00000101";


		input_clk <= '0';
		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;


		input <= "00000000";



		for i in 0 to 200 loop
			input_clk <= '0';
			wait for 5 ns;
			input_clk <= '1';
			wait for 5 ns;

		end loop;



		test_runner_cleanup(runner); -- Simulation ends here
	end process;
end architecture;
