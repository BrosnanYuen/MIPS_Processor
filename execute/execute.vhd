LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.cpu_consts.all;


entity execute is
	Port (
		clk 			: in  STD_LOGIC;
		rst 			: in  STD_LOGIC;
		current_state 		: in  stage_state_type ;
		instruction 			: in std_logic_vector (15 downto 0) ;
		z									: in  STD_LOGIC;
		n									: in  STD_LOGIC;
		rd_data0					: in  std_logic_vector (15 downto 0) ;
		rd_data1					: in  std_logic_vector (15 downto 0) ;


		instruction_out 	: out std_logic_vector (15 downto 0) ;
		z_out							: out  STD_LOGIC;
		n_out							: out  STD_LOGIC;
		rd_data0_execute 	: out std_logic_vector(15 downto 0);
		rd_data1_execute 	: out std_logic_vector(15 downto 0);
		rd_index2					: out std_logic_vector(2 downto 0);

		input_alu_mode 		: out std_logic_vector(2 downto 0);
		alu_input_0_mux_0_state : out alu_input_0_mux_0_type;
		alu_input_0_mux_1_state : out alu_input_0_mux_1_type;

		alu_input_1_mux_0_state : out alu_input_1_mux_0_type;
		alu_input_1_mux_1_state : out alu_input_1_mux_1_type;
		alu_rst						: out STD_LOGIC
	);
end execute;

architecture Behavioral of execute is

--Hazard detection
--Store write destinations
type dest_array is array (integer range 0 to 2) of std_logic_vector(2 downto 0);

signal execute_destinations : dest_array;

signal execute_writes : std_logic_vector(2 downto 0) := "000";


begin


process(clk,rst,current_state,instruction,z,n,rd_data0,rd_data1,execute_destinations,execute_writes)
begin
	if (rising_edge(clk)) then
			if (rst = '1') then --RESET
					for i in execute_destinations'Range loop
						execute_destinations(i) <= (others => '0');
					end loop;

					execute_writes(0) <= '0';
					alu_rst <= '1';
					input_alu_mode <= "000";
					alu_input_0_mux_1_state <= EMPTY;
					alu_input_1_mux_1_state <= EMPTY;

					instruction_out <= (others => '0');
					z_out <= '0';
					n_out	<= '0';
					rd_data0_execute <= (others => '0');
					rd_data1_execute <= (others => '0');
					rd_index2 <= (others => '0');
			else

				case current_state is

					when RESET_STATE =>
							for i in execute_destinations'Range loop
								execute_destinations(i) <= (others => '0');
							end loop;

							execute_writes(0) <= '0';
							alu_rst <= '1';
							input_alu_mode <= "000";
							alu_input_0_mux_1_state <= EMPTY;
							alu_input_1_mux_1_state <= EMPTY;

							instruction_out <= (others => '0');
							z_out <= '0';
							n_out	<= '0';
							rd_data0_execute <= (others => '0');
							rd_data1_execute <= (others => '0');
							rd_index2 <= (others => '0');

					when STALL_STATE =>
							execute_writes(0) <= '0';
							alu_rst <= '1';
							input_alu_mode <= "000";
							alu_input_0_mux_1_state <= EMPTY;
							alu_input_1_mux_1_state <= EMPTY;

							instruction_out <= (others => '0');
							z_out <= '0';
							n_out	<= '0';
							rd_data0_execute <= (others => '0');
							rd_data1_execute <= (others => '0');
							rd_index2 <= (others => '0');

					when RUN_STATE =>

						--Hazard detection
						execute_destinations(2) <= execute_destinations(1);
						execute_writes(2) <= execute_writes(1);

						execute_destinations(1) <= execute_destinations(0);
						execute_writes(1) <= execute_writes(0);
						--Set new hazard
						if ((unsigned(instruction(15 downto 9)) < 7) and (0 < unsigned(instruction(15 downto 9)))) or (instruction(15 downto 9) = IN_INSTR) or (instruction(15 downto 9) = MOV_INSTR)
						or (instruction(15 downto 9) = LOAD_INSTR) then
							execute_destinations(0) <= instruction(8 downto 6);
							execute_writes(0) <= '1';
						elsif (instruction(15 downto 9) = LOADIMM_INSTR) then
							execute_destinations(0) <= R7;
							execute_writes(0) <= '1';
						else
							execute_writes(0) <= '0';
						end if;



						instruction_out <= instruction;
						z_out <= z;
						n_out	<= n;
						rd_data0_execute <= rd_data0;
						rd_data1_execute <= rd_data1;

								--INSTRUCTIONS
								case instruction(15 downto 9) is
										when NOP_INSTR => --NOP
											alu_rst <= '1';

										when TEST_INSTR => --TEST

											if (execute_writes(0) = '1') and (execute_destinations(0) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from memory
												alu_input_0_mux_0_state <= MEM_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												alu_input_1_mux_1_state <= EMPTY;
											elsif (execute_writes(1) = '1') and (execute_destinations(1) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from write back
												alu_input_0_mux_0_state <= WRITE_BACK_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												alu_input_1_mux_1_state <= EMPTY;
											elsif (execute_writes(2) = '1') and (execute_destinations(2) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from rf
												rd_index2 <= instruction(8 downto 6);
												alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												alu_input_1_mux_1_state <= EMPTY;
											else
												--No forwaring
												alu_input_0_mux_0_state <= RF_INDEX_0;
												alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												alu_input_1_mux_1_state <= EMPTY;
											end if;

											alu_rst <= '0';
											input_alu_mode <= instruction(11 downto 9);

										when OUT_INSTR => --OUT


										when IN_INSTR => --IN


										when BRR_INSTR => --BRR
											alu_rst <= '0';
											alu_input_0_mux_0_state <= PCTOALU;
											alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
											alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
											alu_input_1_mux_1_state <= INDEX_1_SHIFT_0;

											input_alu_mode <= "001";

										when BRR_N_INSTR => --BRR.N

											if (n = '1') then --N = 1
												input_alu_mode <= "001";
												alu_rst <= '0';
												alu_input_0_mux_0_state <= PCTOALU;
												alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_0;
											else -- N = 0

											end if;


										when BRR_Z_INSTR => --BRR.Z
											if (z = '1') then --Z = 1
												input_alu_mode <= "001";
												alu_rst <= '0';
												alu_input_0_mux_0_state <= PCTOALU;
												alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_0;
											else -- Z = 0

											end if;

										when BR_INSTR => --BR
											alu_rst <= '0';
											input_alu_mode <= "001";

											if (execute_writes(0) = '1') and (execute_destinations(0) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from memory
												alu_input_0_mux_0_state <= MEM_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											elsif (execute_writes(1) = '1') and (execute_destinations(1) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from write back
												alu_input_0_mux_0_state <= WRITE_BACK_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											elsif (execute_writes(2) = '1') and (execute_destinations(2) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from rf
												rd_index2 <= instruction(8 downto 6);
												alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											else
												--No forwaring
												alu_input_0_mux_0_state <= RF_INDEX_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											end if;

										when BR_N_INSTR => --BR.N
											if (n = '1') then --N = 1
												input_alu_mode <= "001";
												alu_rst <= '0';
												if (execute_writes(2) = '1') and (execute_destinations(2) = instruction(8 downto 6)) then
													--RD INDEX 0 Forwarding from rf
													rd_index2 <= instruction(8 downto 6);
													alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
												else
													--No forwaring
													alu_input_0_mux_0_state <= RF_INDEX_0;
													alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
												end if;
											else -- N = 0

											end if;

										when BR_Z_INSTR=> --BR.Z
											if (z = '1') then --Z = 1
												input_alu_mode <= "001";
												alu_rst <= '0';
												if (execute_writes(2) = '1') and (execute_destinations(2) = instruction(8 downto 6)) then
													--RD INDEX 0 Forwarding from rf
													rd_index2 <= instruction(8 downto 6);
													alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
												else
													--No forwaring
													alu_input_0_mux_0_state <= RF_INDEX_0;
													alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
												end if;
											else -- Z = 0

											end if;

										when BR_SUB_INSTR => --BR.SUB
											input_alu_mode <= "001";
											alu_rst <= '0';

											if (execute_writes(0) = '1') and (execute_destinations(0) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from memory
												alu_input_0_mux_0_state <= MEM_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											elsif (execute_writes(1) = '1') and (execute_destinations(1) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from write back
												alu_input_0_mux_0_state <= WRITE_BACK_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											elsif (execute_writes(2) = '1') and (execute_destinations(2) = instruction(8 downto 6)) then
												--RD INDEX 0 Forwarding from rf
												rd_index2 <= instruction(8 downto 6);
												alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											else
												--No forwaring
												alu_input_0_mux_0_state <= RF_INDEX_0;
												alu_input_0_mux_1_state <= INDEX_0_SHIFT_0;
												alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
												alu_input_1_mux_1_state <= INDEX_1_SHIFT_1;
											end if;


										when RETURN_INSTR => --RETURN


										when LOAD_INSTR => --LOAD


										when STORE_INSTR => --STORE


										when LOADIMM_INSTR => --LOADIMM


										when MOV_INSTR => --MOV


										when others =>

											--ADD TO MUTLI
											if ((instruction(15 downto 9) = ADD_INSTR) or (instruction(15 downto 9) = SUB_INSTR)) or ((instruction(15 downto 9) = MUL_INSTR) or (instruction(15 downto 9) = NAND_INSTR))	then --ALU
												alu_rst <= '0';
												input_alu_mode <= instruction(11 downto 9);

												--INDEX 0
												--Forward from memory access stage
												if (execute_writes(0) = '1') and (execute_destinations(0) = instruction(5 downto 3)) then
													--RD INDEX 0 Forwarding
													alu_input_0_mux_0_state <= MEM_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												elsif (execute_writes(1) = '1') and (execute_destinations(1) = instruction(5 downto 3)) then
												--Forward from write back
												--RD INDEX 0 Forwarding
													alu_input_0_mux_0_state <= WRITE_BACK_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												elsif (execute_writes(2) = '1') and (execute_destinations(2) = instruction(5 downto 3)) then
													--Forward from rf
													--RD INDEX 0 Forwarding
													rd_index2 <= instruction(5 downto 3);
													alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												else
													--No forwaring
													alu_input_0_mux_0_state <= RF_INDEX_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
												end if;

												--INDEX 1
												if (execute_writes(0) = '1') and (execute_destinations(0) = instruction(2 downto 0))  then
													--RD INDEX 1 Forwarding
													alu_input_1_mux_0_state <= MEM_ALU_OUTPUT_TO_ALU_1;
													alu_input_1_mux_1_state <= FOWARD_TO_ALU_1;
												elsif (execute_writes(1) = '1') and (execute_destinations(1) = instruction(2 downto 0)) then
												--Forward from write back
												--RD INDEX 1 Forwarding
													alu_input_1_mux_0_state <= WRITE_BACK_ALU_OUTPUT_TO_ALU_1;
													alu_input_1_mux_1_state <= FOWARD_TO_ALU_1;
												elsif (execute_writes(2) = '1') and (execute_destinations(2) = instruction(2 downto 0)) then
													--Forward from rf
													--RD INDEX 1 Forwarding
													rd_index2 <= instruction(2 downto 0);
													alu_input_1_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_1;
													alu_input_1_mux_1_state <= FOWARD_TO_ALU_1;
												else
													--No forwaring
													alu_input_1_mux_0_state <= RF_INDEX_1;
													alu_input_1_mux_1_state <= FOWARD_TO_ALU_1;
												end if;


											end if;

											--SHL AND SHR
											if ((instruction(15 downto 9) = SHL_N_INSTR) or (instruction(15 downto 9) = SHR_Z_INSTR))  then --ALU
												alu_rst <= '0';
												input_alu_mode <= instruction(11 downto 9);

												if (execute_writes(0) = '1') and (execute_destinations(0) = instruction(8 downto 6)) then
													--RD INDEX 0 Forwarding from memory
													alu_input_0_mux_0_state <= MEM_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= ALU_MASK;
												elsif (execute_writes(1) = '1') and (execute_destinations(1) = instruction(8 downto 6)) then
													--RD INDEX 0 Forwarding from write back
													alu_input_0_mux_0_state <= WRITE_BACK_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= ALU_MASK;
												elsif (execute_writes(2) = '1') and (execute_destinations(2) = instruction(8 downto 6)) then
													--RD INDEX 0 Forwarding from rf
													rd_index2 <= instruction(8 downto 6);
													alu_input_0_mux_0_state <= RF_ALU_OUTPUT_TO_ALU_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= ALU_MASK;
												else
													--No forwaring
													alu_input_0_mux_0_state <= RF_INDEX_0;
													alu_input_0_mux_1_state <= FOWARD_TO_ALU_0;
													alu_input_1_mux_0_state <= INSTRUCTION_TO_ALU;
													alu_input_1_mux_1_state <= ALU_MASK;
												end if;

											end if;



									end case;

									when others =>

				end case;



			end if;
	end if;
end process;

end Behavioral;
