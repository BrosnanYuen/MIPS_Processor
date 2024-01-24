library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library vunit_lib;
context vunit_lib.vunit_context;


entity tb_alu is
  generic (runner_cfg : string);
end entity;

architecture tb of tb_alu is



component alu is
    Port (
		clk : in std_logic;
		rst : in std_logic;
		alu_mode : in std_logic_vector(2 downto 0);
		in0 : in std_logic_vector(15 downto 0);
		in1 : in std_logic_vector(15 downto 0);
		z_flag : out std_logic;
		n_flag : out std_logic;
		result : out std_logic_vector(15 downto 0)
	);
end component;


signal  input_clk , input_rst, out_z ,out_n : std_logic;
signal  input_0, input_1, output_0 :std_logic_vector(15 downto 0);
signal  input_alu_mode :std_logic_vector(2 downto 0);


begin
	mapping: alu port map(input_clk, input_rst, input_alu_mode , input_0,input_1 ,out_z ,out_n  , output_0 );
	main : process
	begin
		test_runner_setup(runner, runner_cfg);
		report "Start testing ALU";


		input_clk <= '0';

		input_rst <= '1';
		input_alu_mode <= "111";
		input_0 <= (others => '0');
		input_1 <= (others => '0');

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test reset output" );
		check(out_z = '0' , "Test reset Z" );
		check(out_n = '0' , "Test reset N" );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "111";
		input_0 <= "0001000011010110";
		input_1 <= "0000000000000111";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test TEST 1" );
		check(out_z = '0' , "Test TEST Z 1" );
		check(out_n = '0' , "Test TEST N 1" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "111";
		input_0 <= "0000000000000001";
		input_1 <= "0000000000000111";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test TEST 2" );
		check(out_z = '0' , "Test TEST Z 2" );
		check(out_n = '0' , "Test TEST N 2" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "111";
		input_0 <= "0000000000000000";
		input_1 <= "0000000000000111";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test TEST 3" );
		check(out_z = '1' , "Test TEST Z 3" );
		check(out_n = '0' , "Test TEST N 3" );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "111";
		input_0 <= "1111111111111111";
		input_1 <= "0000000000000111";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test TEST 4" );
		check(out_z = '0' , "Test TEST Z 4" );
		check(out_n = '1' , "Test TEST N 4" );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "111";
		input_0 <= "1111111111011000";
		input_1 <= "0000000000000111";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test TEST 5" );
		check(out_z = '0' , "Test TEST Z 5" );
		check(out_n = '1' , "Test TEST N 5" );




		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "000";
		input_0 <= (others => '1');
		input_1 <= (others => '1');

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test NOP output" );
		check(out_z = '0' , "Test NOP Z" );
		check(out_n = '0' , "Test NOP N" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "001";
		input_0 <= "0000000011100111";
		input_1 <= "0111100100011000";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0111100111111111" , "Test adder output 1" );
		check(out_z = '0' , "Test adder Z 1" );
		check(out_n = '0' , "Test adder N 1" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "001";
		input_0 <= "1111111100011001";
		input_1 <= "0000000001011000";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "1111111101110001" , "Test adder output 2" );
		check(out_z = '0' , "Test adder Z 2" );
		check(out_n = '0' , "Test adder N 2" );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "001";
		input_0 <= "1101100101000000";
		input_1 <= "1101100010000001";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "1011000111000001" , "Test adder output 3" );
		check(out_z = '0' , "Test adder Z 3" );
		check(out_n = '0' , "Test adder N 3" );




		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "001";
		input_0 <= "0010001001001111";
		input_1 <= "1101110110110001";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000" , "Test adder output 4" );
		check(out_z = '0' , "Test adder Z 4" );
		check(out_n = '0' , "Test adder N 4" );




		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "010";
		input_0 <= "0000000011100111";
		input_1 <= "1111111111010101";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000100010010" , "Test subtractor output 1" );
		check(out_z = '0' , "Test sub Z 1" );
		check(out_n = '0' , "Test sub N 1" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "010";
		input_0 <= "0000001100010110";
		input_1 <= "0000001100100000";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "1111111111110110" , "Test subtractor output 2" );
		check(out_z = '0' , "Test sub Z 2" );
		check(out_n = '0' , "Test sub N 2" );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "010";
		input_0 <= "0000001100010110";
		input_1 <= "0000001100010110";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000000000", "Test subtractor output 3" );
		check(out_z = '0' , "Test sub Z 3" );
		check(out_n = '0' , "Test sub N 3" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "011";
		input_0 <= "0000000001010111";
		input_1 <= "0000000011100000";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0100110000100000", "Test multiply output 1" );
		check(out_z = '0' , "Test multi Z 1" );
		check(out_n = '0' , "Test multi N 1" );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "011";
		input_0 <= "0000000000001100";
		input_1 <= "0000000000101100";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000001000010000", "Test multiply output 2" );
		check(out_z = '0' , "Test multi Z 2" );
		check(out_n = '0' , "Test multi N 2" );


		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "100";
		input_0 <= "1110111110111010";
		input_1 <= "0010000100000010";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "1101111011111101" , "Test nand" );
		check(out_z = '0' , "Test nand Z " );
		check(out_n = '0' , "Test nand N " );



		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "101";
		input_0 <= "0000000001010110";
		input_1 <= "0000000000000101";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000101011000000" , "Test SHL" );
		check(out_z = '0' , "Test SHL Z " );
		check(out_n = '0' , "Test SHL N " );




		input_clk <= '0';

		input_rst <= '0';
		input_alu_mode <= "110";
		input_0 <= "0001000011010110";
		input_1 <= "0000000000000111";

		wait for 5 ns;
		input_clk <= '1';
		wait for 5 ns;

		check(output_0 = "0000000000100001" , "Test SHR" );
		check(out_z = '0' , "Test SHR Z " );
		check(out_n = '0' , "Test SHR N " );








		test_runner_cleanup(runner); -- Simulation ends here
	end process;
end architecture;
