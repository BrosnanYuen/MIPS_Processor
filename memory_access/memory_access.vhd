LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.cpu_consts.all;


entity memory_access is
	Generic (
		DATA_WIDTH	: integer := 16;
		addr_WIDTH	: integer := 16
	);
	Port (
		clk 			: in  STD_LOGIC;
		rst 			: in  STD_LOGIC;
		current_state 		: in  stage_state_type ;
		instruction 			: in std_logic_vector (15 downto 0) ;
		z									: in  STD_LOGIC;
		n									: in  STD_LOGIC;
		rd_data0_execute 	: in std_logic_vector(15 downto 0);
		rd_data1_execute 	: in std_logic_vector(15 downto 0);
		alu_output_0			: in std_logic_vector(15 downto 0);
		in_data : in std_logic_vector(7 downto 0);

		multiply_result : in std_logic_vector(15 downto 0);

		instruction_out 	: out std_logic_vector (15 downto 0) ;
		z_out							: out  STD_LOGIC;
		n_out							: out  STD_LOGIC;
		rd_data0_memory_access 	: out std_logic_vector(15 downto 0);
		rd_data1_memory_access 	: out std_logic_vector(15 downto 0);
		alu_output_0_memory_access  : out std_logic_vector(15 downto 0);

		out_data : out std_logic_vector(15 downto 0);
		multiply_result_memory_access : out std_logic_vector(15 downto 0);
		mem_out : out std_logic_vector(15 downto 0)
	);
end memory_access;

architecture Behavioral of memory_access is
	--RAM storage
	type Memory_Array is array (((2 ** (addr_WIDTH-7)) - 1) downto 0) of STD_LOGIC_VECTOR ((DATA_WIDTH - 1) downto 0); --2^11 addresses
	signal Memory : Memory_Array;

--Hazard detection
--Store write destinations
type dest_array is array (integer range 0 to 2) of std_logic_vector(2 downto 0);

signal mem_destinations : dest_array;

signal mem_writes : std_logic_vector(2 downto 0) := "000";

--Harzard FIFO write buffer
type value_array is array (integer range 0 to 2) of std_logic_vector(15 downto 0);

signal mem_values : value_array;


begin

process(clk,rst,current_state,instruction,Memory,z,n,rd_data0_execute,rd_data1_execute,alu_output_0,in_data,multiply_result,Memory,mem_values,mem_destinations,mem_writes)
begin




	if (rising_edge(clk)) then
			if (rst = '1') then --RESET
					for i in Memory'Range loop
						Memory(i) <= (others => '0');
					end loop;

					for i in mem_destinations'Range loop
						mem_destinations(i) <= (others => '0');
					end loop;

					for i in mem_values'Range loop
						mem_values(i) <= (others => '0');
					end loop;

					out_data <= (others => '0');

					instruction_out <= (others => '0');
					z_out <= '0';
					n_out	<= '0';
					rd_data0_memory_access <= (others => '0');
					rd_data1_memory_access <= (others => '0');
					alu_output_0_memory_access <= (others => '0');
					mem_out <= (others => '0');
					multiply_result_memory_access <= (others => '0');
			else

				case current_state is

					when RESET_STATE =>
							out_data <= (others => '0');
							mem_out <= (others => '0');

							for i in Memory'Range loop
								Memory(i) <= (others => '0');
							end loop;

							for i in mem_destinations'Range loop
								mem_destinations(i) <= (others => '0');
							end loop;

							for i in mem_values'Range loop
								mem_values(i) <= (others => '0');
							end loop;

							instruction_out <= (others => '0');
							z_out <= '0';
							n_out	<= '0';
							rd_data0_memory_access <= (others => '0');
							rd_data1_memory_access <= (others => '0');
							alu_output_0_memory_access <= (others => '0');
							multiply_result_memory_access <= (others => '0');

					when STALL_STATE =>
							mem_out <= (others => '0');

							instruction_out <= (others => '0');
							z_out <= '0';
							n_out	<= '0';
							rd_data0_memory_access <= (others => '0');
							rd_data1_memory_access <= (others => '0');
							alu_output_0_memory_access <= (others => '0');
							multiply_result_memory_access <= (others => '0');


					when RUN_STATE =>
						--Hazard detection
						mem_destinations(2) <= mem_destinations(1);
						mem_writes(2) <= mem_writes(1);
						mem_values(2) <= mem_values(1);

						mem_destinations(1) <= mem_destinations(0);
						mem_writes(1) <= mem_writes(0);
						mem_values(1) <= mem_values(0);

						if ((unsigned(instruction(15 downto 9)) < 7) and (0 < unsigned(instruction(15 downto 9)))) then
							mem_destinations(0) <= instruction(8 downto 6);
							mem_writes(0) <= '1';
							mem_values(0) <= alu_output_0;
						elsif (instruction(15 downto 9) = LOAD_INSTR) then
							mem_destinations(0) <= instruction(8 downto 6);
							mem_writes(0) <= '1';
						else
							mem_writes(0) <= '0';
						end if;


						instruction_out <= instruction;
						z_out <= z;
						n_out	<= n;
						rd_data1_memory_access <= rd_data1_execute;
						multiply_result_memory_access <=  multiply_result;

								--INSTRUCTIONS
								case instruction(15 downto 9) is

										when OUT_INSTR => --OUT
											rd_data0_memory_access <= rd_data0_execute;
											out_data <= rd_data0_execute;
											alu_output_0_memory_access <= alu_output_0;

										when IN_INSTR => --IN
											rd_data0_memory_access(15 downto 8) <= (others => '0');
											rd_data0_memory_access(7 downto 0) <= in_data;

											alu_output_0_memory_access(15 downto 8) <= (others => '0');
											alu_output_0_memory_access(7 downto 0) <= in_data;

										when LOAD_INSTR => --LOAD
											rd_data0_memory_access <= rd_data0_execute;

											if (mem_writes(0) = '1') and (mem_destinations(0) = instruction(5 downto 3)) then
												--Register file forwarding
												mem_values(0) <= Memory(to_integer(unsigned(mem_values(0)(8 downto 0))));
												alu_output_0_memory_access <= Memory(to_integer(unsigned(mem_values(0)(8 downto 0))));
												mem_out <= Memory(to_integer(unsigned(mem_values(0)(8 downto 0))));
											elsif (mem_writes(1) = '1') and (mem_destinations(1) = instruction(5 downto 3)) then
												--Register file forwarding
												mem_values(0) <= Memory(to_integer(unsigned(mem_values(1)(8 downto 0))));
												alu_output_0_memory_access <= Memory(to_integer(unsigned(mem_values(1)(8 downto 0))));
												mem_out <= Memory(to_integer(unsigned(mem_values(1)(8 downto 0))));
											elsif (mem_writes(2) = '1') and (mem_destinations(2) = instruction(5 downto 3)) then
												--Register file forwarding
												mem_values(0) <= Memory(to_integer(unsigned(mem_values(2)(8 downto 0))));
												alu_output_0_memory_access <= Memory(to_integer(unsigned(mem_values(2)(8 downto 0))));
												mem_out <= Memory(to_integer(unsigned(mem_values(2)(8 downto 0))));
											else
												--No forwaring
												mem_values(0) <= Memory(to_integer(unsigned(rd_data1_execute(8 downto 0))));
												alu_output_0_memory_access <= Memory(to_integer(unsigned(rd_data1_execute(8 downto 0))));
												mem_out <= Memory(to_integer(unsigned(rd_data1_execute(8 downto 0))));
											end if;



										when STORE_INSTR => --STORE
											rd_data0_memory_access <= rd_data0_execute;
											alu_output_0_memory_access <= alu_output_0;

											if (mem_writes(0) = '1') and (mem_destinations(0) = instruction(5 downto 3)) then
												--Register file forwarding
												Memory(to_integer(unsigned(mem_values(0)(8 downto 0)))) <= rd_data0_execute;
											elsif (mem_writes(1) = '1') and (mem_destinations(1) = instruction(5 downto 3)) then
												--Register file forwarding
												Memory(to_integer(unsigned(mem_values(1)(8 downto 0)))) <= rd_data0_execute;
											elsif (mem_writes(2) = '1') and (mem_destinations(2) = instruction(5 downto 3)) then
												--Register file forwarding
												Memory(to_integer(unsigned(mem_values(2)(8 downto 0)))) <= rd_data0_execute;
											else
												--No forwaring
												Memory(to_integer(unsigned(rd_data1_execute(8 downto 0)))) <= rd_data0_execute;
											end if;

										when LOADIMM_INSTR => --LOADIMM
											rd_data0_memory_access <= rd_data0_execute;
											alu_output_0_memory_access <= rd_data0_execute;

										when MOV_INSTR => --MOV
											rd_data0_memory_access <= rd_data0_execute;
											alu_output_0_memory_access <= rd_data0_execute;

										when others =>
											rd_data0_memory_access <= rd_data0_execute;
											alu_output_0_memory_access <= alu_output_0;
									end case;


									when others =>

				end case;



			end if;
	end if;
end process;

end Behavioral;
