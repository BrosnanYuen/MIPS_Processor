library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.cpu_consts.all;

entity alu is
    Port (
		rst : in std_logic;
		alu_mode : in std_logic_vector(2 downto 0);
		in0 : in std_logic_vector(15 downto 0);
		in1 : in std_logic_vector(15 downto 0);
		z_flag : out std_logic;
		n_flag : out std_logic;
		result : out std_logic_vector(15 downto 0);
		multiply_result : out std_logic_vector(15 downto 0)
	);
end alu;

architecture Behavioral of alu is

signal temp_multi : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

begin
	process(rst,alu_mode,in0,in1,temp_multi)
	begin

			if (rst = '1') then --Reset
				z_flag <= '0';
				n_flag <= '0';
				result <= "0000000000000000";

				multiply_result <= "0000000000000000";
			else


				case alu_mode is
					when ALU_NOP => --NOP
						z_flag <= '0';
						n_flag <= '0';
						result <= "0000000000000000";

						multiply_result <= "0000000000000000";
					when ALU_ADD => --ADDER
						result <=  std_logic_vector(signed(in0(15 downto 0)) + signed(in1(15 downto 0)));
						z_flag <= '0';
						n_flag <= '0';

						multiply_result <= "0000000000000000";
					when ALU_SUB => --SUBTRACTOR
						result <=  std_logic_vector(signed(in0(15 downto 0)) - signed(in1(15 downto 0)));
						z_flag <= '0';
						n_flag <= '0';

						multiply_result <= "0000000000000000";
					when ALU_MULTI => --Multiplier
						z_flag <= '0';
						n_flag <= '0';

						result <= temp_multi(15 downto 0);
						--result <= std_logic_vector(unsigned(in0(7 downto 0)) * unsigned(in1(7 downto 0)));
						multiply_result <=  temp_multi(31 downto 16);
					when ALU_NAND => --NAND
						result <=  in0 nand in1;
						z_flag <= '0';
						n_flag <= '0';

						multiply_result <= "0000000000000000";
					when ALU_SHIFT_LEFT => --Shift left
						result <=  std_logic_vector(shift_left(unsigned(in0), to_integer(unsigned(in1))));
						z_flag <= '0';
						n_flag <= '0';

						multiply_result <= "0000000000000000";
					when ALU_SHIFT_RIGHT => --Shift right
						result <=  std_logic_vector(shift_right(unsigned(in0), to_integer(unsigned(in1))));
						z_flag <= '0';
						n_flag <= '0';

						multiply_result <= "0000000000000000";
					when ALU_TEST => --TEST

						result <= "0000000000000000";
						if (in0 = "0000000000000000") then
							z_flag <= '1';
						else
							z_flag <= '0';
						end if;

						if (signed(in0) < 0 ) then
							n_flag <= '1';
						else
							n_flag <= '0';
						end if;

						multiply_result <= "0000000000000000";
					when others =>

				end case;


			end if;

	end process;

temp_multi <=  std_logic_vector(unsigned(in0) * unsigned(in1));

end Behavioral;
