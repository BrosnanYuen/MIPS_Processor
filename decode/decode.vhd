LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.cpu_consts.all;


entity decode is
	Port (
		clk 							: in  STD_LOGIC;
		rst 							: in  STD_LOGIC;
		current_state 		: in  stage_state_type ;
		instruction 			: in std_logic_vector (15 downto 0) ;
		z									: in  STD_LOGIC;
		n									: in  STD_LOGIC;

		instruction_3 : in  STD_LOGIC_VECTOR (15 downto 0);
		z_3									: in  STD_LOGIC;
		n_3									: in  STD_LOGIC;
		alu_output_0_memory_access	: in  STD_LOGIC_VECTOR (15 downto 0);
		rd_data0_memory_access	: in  STD_LOGIC_VECTOR (15 downto 0);


		instruction_out 	: out std_logic_vector (15 downto 0) ;
		z_out							: out  STD_LOGIC;
		n_out							: out  STD_LOGIC;

		rf_index_0_mux_state : out rf_index_0_mux_type ;
		rd_index0					: out std_logic_vector(2 downto 0);
		rd_index1					: out std_logic_vector(2 downto 0);

		program_counter		: out STD_LOGIC_VECTOR (15 downto 0)
	);
end decode;

architecture Behavioral of decode is

--Hazard detection
--Store write destinations
type dest_array is array (integer range 0 to 2) of std_logic_vector(2 downto 0);

signal decode_destinations : dest_array;

signal decode_writes : std_logic_vector(2 downto 0) := "000";



--Program counter
signal counter	: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";



begin


process(clk,rst,current_state,instruction,z,n,counter,decode_destinations,decode_writes, instruction_3, n_3, z_3, alu_output_0_memory_access, rd_data0_memory_access)
begin
	if (rising_edge(clk)) then
			if (rst = '1') then --RESET
					for i in decode_destinations'Range loop
						decode_destinations(i) <= (others => '0');
					end loop;

					decode_writes(0) <= '0';
					rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
					rd_index0 <= "000";
					rd_index1 <= "000";

					instruction_out <= (others => '0');
					z_out <= '0';
					n_out	<= '0';
					counter <= (others => '0');
			else

					case current_state is

						when RESET_STATE =>
								for i in decode_destinations'Range loop
									decode_destinations(i) <= (others => '0');
								end loop;

								decode_writes(0) <= '0';
								rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
								rd_index0 <= "000";
								rd_index1 <= "000";

								instruction_out <= (others => '0');
								z_out <= '0';
								n_out	<= '0';


						when STALL_STATE =>
								decode_writes(0) <= '0';
								rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
								rd_index0 <= "000";
								rd_index1 <= "000";

								instruction_out <= (others => '0');
								z_out <= '0';
								n_out	<= '0';

						when WRITE_PC_STATE =>
							decode_writes(0) <= '0';
							rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
							rd_index0 <= "000";
							rd_index1 <= "000";

							instruction_out <= (others => '0');
							z_out <= '0';
							n_out	<= '0';

							--Write to program counter
							case instruction_3(15 downto 9) is

									when BRR_INSTR => --BRR
										counter <= alu_output_0_memory_access;

									when BRR_N_INSTR =>
										if (n_3 = '1') then --N = 1
											counter <= alu_output_0_memory_access;
										end if;

									when BRR_Z_INSTR => --BRR.Z
										if (z_3 = '1') then --Z = 1
											counter <= alu_output_0_memory_access;
										end if;

									when BR_INSTR => --BR
										counter <= alu_output_0_memory_access;

									when BR_N_INSTR => --BR.N
										if (n_3 = '1') then --N = 1
											counter <= alu_output_0_memory_access;
										end if;

									when BR_Z_INSTR => --BR.Z
										if (z_3 = '1') then --Z = 1
											counter <= alu_output_0_memory_access;
										end if;

									when BR_SUB_INSTR => --BR.SUB
										counter <= alu_output_0_memory_access;

									when RETURN_INSTR => --RETURN
										counter <= rd_data0_memory_access;

									when others =>

							end case;



						when RUN_STATE =>
							--Hazard detection
							decode_destinations(2) <= decode_destinations(1);
							decode_writes(2) <= decode_writes(1);

							decode_destinations(1) <= decode_destinations(0);
							decode_writes(1) <= decode_writes(0);

							if (instruction(15 downto 9) = LOADIMM_INSTR) then
								decode_destinations(0) <= R7;
								decode_writes(0) <= '1';
							elsif ((unsigned(instruction(15 downto 9)) < 7) and (0 < unsigned(instruction(15 downto 9))))
							or (instruction(15 downto 9) = MOV_INSTR)
							or (instruction(15 downto 9) = IN_INSTR) then
								decode_destinations(0) <= instruction(8 downto 6);
								decode_writes(0) <= '1';
							else
								decode_writes(0) <= '0';
							end if;



							instruction_out <= instruction;
							z_out <= z;
							n_out	<= n;


							--Increment program counter
							if (instruction(15 downto 12) /= "1000")
							 	or ((instruction(15 downto 9) = BRR_N_INSTR) and (n = '0'))
								or ((instruction(15 downto 9) = BRR_Z_INSTR) and (z = '0'))
								or ((instruction(15 downto 9) = BR_N_INSTR) and (n = '0'))
								or ((instruction(15 downto 9) = BR_Z_INSTR) and (z = '0'))
								or (instruction(15 downto 9) = BR_SUB_INSTR) then
										--Increment
										counter  <= std_logic_vector( unsigned( counter ) + "10" ) ;
							end if;


							--INSTRUCTIONS
							case instruction(15 downto 9) is
									when NOP_INSTR => --NOP


									when TEST_INSTR => --TEST
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										rd_index0 <= instruction(8 downto 6);
										rd_index1 <= "000";

									when OUT_INSTR => --OUT
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										rd_index0 <= instruction(8 downto 6);
										rd_index1 <= "000";

									when IN_INSTR => --IN


									when BRR_INSTR => --BRR


									when BRR_N_INSTR => --BRR.N


									when BRR_Z_INSTR => --BRR.Z


									when BR_INSTR => --BR
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										rd_index0 <= instruction(8 downto 6);

									when BR_N_INSTR => --BR.N
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										if (n = '1') then --N = 1
											rd_index0 <= instruction(8 downto 6);
										end if;

									when BR_Z_INSTR => --BR.Z
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										if (z = '1') then --Z = 1
											rd_index0 <= instruction(8 downto 6);
										end if;

									when BR_SUB_INSTR => --BR.SUB
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										rd_index0 <= instruction(8 downto 6);

									when RETURN_INSTR => --RETURN
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										rd_index0 <= "111";
										rd_index1 <= "000";

									when LOAD_INSTR => --LOAD
										rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
										--rd_index0 <= instruction(5 downto 3); --source
										rd_index1 <= instruction(5 downto 3); --source

									when STORE_INSTR => --STORE
										rd_index1 <= instruction(5 downto 3); --source


										if (decode_writes(1) = '1') and (decode_destinations(1) = instruction(8 downto 6)) then
											--MEM forwarding
											rf_index_0_mux_state <= MEM_ALU_OUTPUT_MEM_TO_INDEX_0;
										elsif (decode_writes(2) = '1') and (decode_destinations(2) = instruction(8 downto 6)) then
											--WR forwarding
											rf_index_0_mux_state <= WRITE_BACK_ALU_OUTPUT_TO_TO_INDEX_0;
										else
											--No forwarding
											rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
											rd_index0 <= instruction(8 downto 6); --source
										end if;



									when LOADIMM_INSTR => --LOADIMM
										rd_index0 <= "111";

										if(instruction(8) = '1') then
											--uppper
											if (decode_writes(0) = '1') and (decode_destinations(0) = R7) then
												--Execute forwarding
												rf_index_0_mux_state <= EX_LOADIMM_UPPER;
											elsif (decode_writes(1) = '1') and (decode_destinations(1) = R7) then
												--MEM forwarding
												rf_index_0_mux_state <= MEM_LOADIMM_UPPER;
											elsif (decode_writes(2) = '1') and (decode_destinations(2) = R7) then
												--WR forwarding
												rf_index_0_mux_state <= WR_LOADIMM_UPPER;
											else
												--No forwarding
												rf_index_0_mux_state <= LOADIMM_UPPER;
											end if;

										else
											--lower
											if (decode_writes(0) = '1') and (decode_destinations(0) = R7) then
												--Execute forwarding
												rf_index_0_mux_state <= EX_LOADIMM_LOWER;
											elsif (decode_writes(1) = '1') and (decode_destinations(1) = R7) then
												--MEM forwarding
												rf_index_0_mux_state <= MEM_LOADIMM_LOWER;
											elsif (decode_writes(2) = '1') and (decode_destinations(2) = R7) then
												--WR forwarding
												rf_index_0_mux_state <= WR_LOADIMM_LOWER;
											else
												--No forwarding
												rf_index_0_mux_state <= LOADIMM_LOWER;
											end if;
										end if;

									when MOV_INSTR => --MOV

										if (decode_writes(0) = '1') and (decode_destinations(0) = instruction(5 downto 3)) then
											--Execute forwarding
											rf_index_0_mux_state <= EX_TO_INDEX_0;
										elsif (decode_writes(1) = '1') and (decode_destinations(1) = instruction(5 downto 3)) then
											--MEM forwarding
											rf_index_0_mux_state <= MEM_TO_INDEX_0;
										elsif (decode_writes(2) = '1') and (decode_destinations(2) = instruction(5 downto 3)) then
											--WR forwarding
											rf_index_0_mux_state <= WR_TO_INDEX_0;
										else
											--No forwarding
											rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
											rd_index0 <= instruction(5 downto 3); --source
										end if;

									when MULTI_MOV_INSTR => --MOV the multi result
										rf_index_0_mux_state <= MULTI_RESULT_TO_INDEX_0;

									when others =>
										--ADD TO MUTLI
										if ((instruction(15 downto 9) = ADD_INSTR) or (instruction(15 downto 9) = SUB_INSTR)) or ((instruction(15 downto 9) = MUL_INSTR) or (instruction(15 downto 9) = NAND_INSTR))	then --ALU
											rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
											rd_index0 <= instruction(5 downto 3);
											rd_index1 <= instruction(2 downto 0);
										end if;

										--SHL AND SHR
										if ((instruction(15 downto 9) = SHL_N_INSTR) or (instruction(15 downto 9) = SHR_Z_INSTR))  then --ALU
											rf_index_0_mux_state <= FOWARD_TO_INDEX_0;
											rd_index0 <= instruction(8 downto 6);
											rd_index1 <= "000";
										end if;


								end case;
					end case;

			end if;
	end if;

end process;

--Display program counter
program_counter <= counter;

end Behavioral;
