LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.cpu_consts.all;


entity write_back is
	Port (
		clk 							: in  STD_LOGIC;
		rst 							: in  STD_LOGIC;
		current_state 		: in  stage_state_type ;
		instruction 			: in std_logic_vector (15 downto 0) ;
		z									: in  STD_LOGIC;
		n									: in  STD_LOGIC;
		rd_data0_memory_access 	: in std_logic_vector(15 downto 0);
		rd_data1_memory_access 	: in std_logic_vector(15 downto 0);
		alu_output_0_memory_access  : in std_logic_vector(15 downto 0);
		mem_out 				 : in std_logic_vector(15 downto 0);

		--read signals
		rd_index0 : in std_logic_vector(2 downto 0);
		rd_index1 : in std_logic_vector(2 downto 0);
		rd_index2 : in std_logic_vector(2 downto 0);

		--Program counter
		program_counter		: in STD_LOGIC_VECTOR (15 downto 0);

		multiply_result_memory_access : in std_logic_vector(15 downto 0);

		rd_data0_write_back 	: out std_logic_vector(15 downto 0);
		alu_output_0_write_back  : out std_logic_vector(15 downto 0);

		multiply_result_write_back : out std_logic_vector(15 downto 0);

		rd_data0 : out std_logic_vector(15 downto 0);
		rd_data1 : out std_logic_vector(15 downto 0);
		rd_data2 : out std_logic_vector(15 downto 0)
	);
end write_back;

architecture Behavioral of write_back is

type reg_array is array (integer range 0 to 7) of std_logic_vector(15 downto 0);
--Register file
signal reg_file : reg_array;


--Multiply register
signal multiply_reg : std_logic_vector(15 downto 0):= "0000000000000000";

--type dest_array is array (integer range 0 to 2) of std_logic_vector(2 downto 0);

--signal rf_destinations : dest_array;

--signal rf_writes : std_logic_vector(2 downto 0) := "000";

begin

process(clk,rst,current_state,instruction,z,n,rd_data0_memory_access,rd_data1_memory_access,alu_output_0_memory_access,mem_out,rd_index0,rd_index1,rd_index2,program_counter,reg_file,multiply_result_memory_access,multiply_reg)
begin

	multiply_result_write_back <= multiply_reg;
	if (rising_edge(clk)) then
			if (rst = '1') then --RESET
					--rf_writes(0) <= '0';

					rd_data0_write_back <= (others => '0');
					alu_output_0_write_back <= (others => '0');

					for i in 0 to 7 loop
						reg_file(i)<= (others => '0');
					end loop;
			else

					case current_state is

						when RESET_STATE =>
								--rf_writes(0) <= '0';

								rd_data0_write_back <= (others => '0');
								alu_output_0_write_back <= (others => '0');

								for i in 0 to 7 loop
									reg_file(i)<= (others => '0');
								end loop;

						when STALL_STATE =>
								--rf_writes(0) <= '0';

								rd_data0_write_back <= (others => '0');
								alu_output_0_write_back <= (others => '0');

						when RUN_STATE =>
							--Hazard detection
							--rf_destinations(2) <= rf_destinations(1);
							--rf_writes(2) <= rf_writes(1);

							--rf_destinations(1) <= rf_destinations(0);
							--rf_writes(1) <= rf_writes(0);

							--if (instruction(15 downto 9) = LOADIMM_INSTR) then
								--rf_destinations(0) <= R7;
								--rf_writes(0) <= '1';
							--elsif (instruction(15 downto 9) = MOV_INSTR) then
								--rf_destinations(0) <= instruction(8 downto 6);
								--rf_writes(0) <= '1';
							--else
								--rf_writes(0) <= '0';
							--end if;



							rd_data0_write_back <= rd_data0_memory_access;

							--INSTRUCTIONS
							case instruction(15 downto 9) is
									when NOP_INSTR => --NOP
										alu_output_0_write_back <= alu_output_0_memory_access;

									when TEST_INSTR => --TEST
										alu_output_0_write_back <= alu_output_0_memory_access;
									when OUT_INSTR => --OUT
										alu_output_0_write_back <= alu_output_0_memory_access;

									when IN_INSTR => --IN
										reg_file(to_integer(unsigned(instruction(8 downto 6)))) <= rd_data0_memory_access;
										alu_output_0_write_back <= alu_output_0_memory_access;

									when BRR_INSTR => --BRR
										alu_output_0_write_back <= alu_output_0_memory_access;


									when BRR_N_INSTR => --BRR.N
										alu_output_0_write_back <= alu_output_0_memory_access;

									when BRR_Z_INSTR => --BRR.Z
										alu_output_0_write_back <= alu_output_0_memory_access;

									when BR_INSTR => --BR
										alu_output_0_write_back <= alu_output_0_memory_access;

									when BR_N_INSTR => --BR.N
										alu_output_0_write_back <= alu_output_0_memory_access;

									when BR_Z_INSTR=> --BR.Z
										alu_output_0_write_back <= alu_output_0_memory_access;

									when BR_SUB_INSTR => --BR.SUB
										alu_output_0_write_back <= alu_output_0_memory_access;

										-- R7 <= PC
										reg_file(to_integer(unsigned(R7))) <= program_counter;


									when RETURN_INSTR => --RETURN
										alu_output_0_write_back <= alu_output_0_memory_access;

									when LOAD_INSTR => --LOAD
										alu_output_0_write_back <= alu_output_0_memory_access;
										reg_file(to_integer(unsigned(instruction(8 downto 6)))) <= mem_out;

									when STORE_INSTR => --STORE
										alu_output_0_write_back <= alu_output_0_memory_access;

									when LOADIMM_INSTR => --LOADIMM
										alu_output_0_write_back <= rd_data0_memory_access;
										reg_file(to_integer(unsigned(R7))) <= rd_data0_memory_access;

									when MOV_INSTR => --MOV
										alu_output_0_write_back <= rd_data0_memory_access;

										reg_file(to_integer(unsigned(instruction(8 downto 6)))) <= rd_data0_memory_access;

									when MULTI_MOV_INSTR => --MOV the multi result
										alu_output_0_write_back <= rd_data0_memory_access;

										reg_file(to_integer(unsigned(instruction(8 downto 6)))) <= rd_data0_memory_access;

									when others =>
										alu_output_0_write_back <= alu_output_0_memory_access;
										--ADD TO MUTLI
										if ((instruction(15 downto 9) = ADD_INSTR) or (instruction(15 downto 9) = SUB_INSTR)) or ((instruction(15 downto 9) = MUL_INSTR) or (instruction(15 downto 9) = NAND_INSTR))	then --ALU
											reg_file(to_integer(unsigned(instruction(8 downto 6)))) <= alu_output_0_memory_access;
										end if;

										--MUTLI
										if (instruction(15 downto 9) = MUL_INSTR) then
											multiply_reg <= multiply_result_memory_access;
										end if;

										--SHL AND SHR
										if ((instruction(15 downto 9) = SHL_N_INSTR) or (instruction(15 downto 9) = SHR_Z_INSTR))  then --ALU
											reg_file(to_integer(unsigned(instruction(8 downto 6)))) <= alu_output_0_memory_access;
										end if;


								end case;

								when others =>

					end case;

			end if;
	end if;




end process;

--ASYNC register access
rd_data0 <=
reg_file(0) when(rd_index0="000") else
reg_file(1) when(rd_index0="001") else
reg_file(2) when(rd_index0="010") else
reg_file(3) when(rd_index0="011") else
reg_file(4) when(rd_index0="100") else
reg_file(5) when(rd_index0="101") else
reg_file(6) when(rd_index0="110") else reg_file(7);
rd_data1 <=
reg_file(0) when(rd_index1="000") else
reg_file(1) when(rd_index1="001") else
reg_file(2) when(rd_index1="010") else
reg_file(3) when(rd_index1="011") else
reg_file(4) when(rd_index1="100") else
reg_file(5) when(rd_index1="101") else
reg_file(6) when(rd_index1="110") else reg_file(7);
rd_data2 <=
reg_file(0) when(rd_index2="000") else
reg_file(1) when(rd_index2="001") else
reg_file(2) when(rd_index2="010") else
reg_file(3) when(rd_index2="011") else
reg_file(4) when(rd_index2="100") else
reg_file(5) when(rd_index2="101") else
reg_file(6) when(rd_index2="110") else reg_file(7);

end Behavioral;
