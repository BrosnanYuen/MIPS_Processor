library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.cpu_consts.all;

entity cpu is
    Port (
		clk : in std_logic;
		rst : in std_logic;
		in_data : in std_logic_vector(7 downto 0);
		out_data : out std_logic_vector(15 downto 0)
	);
end cpu;


architecture Behavioral of cpu is



--Next state
signal current_hold_state : cu_state_type :=  CU_RESET;


--FETCH component
component fetch is
  Port (
		clk 			: in  STD_LOGIC;
		rst 			: in  STD_LOGIC;
		current_state 		: in  stage_state_type ;
		program_counter     : in  std_logic_vector (15 downto 0);

		--PC_TO_ROM		: out PC_TO_ROM_type
		instruction     : out std_logic_vector (15 downto 0)
  );
end component;




--RF Signals
signal rd_index0, rd_index1,rd_index2  : std_logic_vector(2 downto 0);
signal rd_data0, rd_data1,rd_data2 , rd_data0_mux_output : std_logic_vector(15 downto 0);


--DECODE component
component decode is
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
end component;

--DECODE signals
signal rf_index_0_mux_state :rf_index_0_mux_type := FOWARD_TO_INDEX_0;



--Program counter signals
signal  program_counter : std_logic_vector (15 downto 0) ;


--EXECUTE Component
component execute is
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
end component;

--EXECUTE signals
signal alu_input_0_mux_0_output : std_logic_vector(15 downto 0) := "0000000000000000";

signal alu_input_0_mux_0_state : alu_input_0_mux_0_type := RF_INDEX_0;

signal alu_input_0_mux_1_state : alu_input_0_mux_1_type := EMPTY;


signal alu_input_1_mux_0_output : std_logic_vector(15 downto 0) := "0000000000000000";

signal alu_input_1_mux_0_state : alu_input_1_mux_0_type := RF_INDEX_1;

signal alu_input_1_mux_1_state : alu_input_1_mux_1_type := EMPTY;



--ALU
component alu is
    port (
		rst : in std_logic;
		alu_mode : in std_logic_vector(2 downto 0);
		in0 : in std_logic_vector(15 downto 0);
		in1 : in std_logic_vector(15 downto 0);
		z_flag : out std_logic;
		n_flag : out std_logic;
		result : out std_logic_vector(15 downto 0);
		multiply_result : out std_logic_vector(15 downto 0)
	);
end component;

--ALU signals
signal  alu_rst : std_logic;
signal  alu_input_0, alu_input_1, alu_output_0, multiply_result :std_logic_vector(15 downto 0);
signal  input_alu_mode :std_logic_vector(2 downto 0);


--MEMORY_ACCESS_STATE COMPOENNT
component memory_access is
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
end component;



--MEMORY_ACCESS_STATE signals
signal mem_out : std_logic_vector(15 downto 0) := "0000000000000000";
signal multiply_result_memory_access :std_logic_vector(15 downto 0) := "0000000000000000";






--Write back
component write_back is
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
end component;




--Write back signals
signal multiply_result_write_back :  std_logic_vector (15 downto 0) := "0000000000000000";

--Pipeline
signal instruction_0 :  std_logic_vector (15 downto 0) := "0000000000000000";
signal z_0 : std_logic := '0';
signal n_0 : std_logic := '0';

signal instruction_1 :  std_logic_vector (15 downto 0) := "0000000000000000";
signal z_1 : std_logic := '0';
signal n_1 : std_logic := '0';


signal instruction_2 :  std_logic_vector (15 downto 0) := "0000000000000000";
signal z_2 : std_logic := '0';
signal n_2 : std_logic := '0';


signal instruction_3 :  std_logic_vector (15 downto 0) := "0000000000000000";
signal z_3 : std_logic := '0';
signal n_3 : std_logic := '0';

--RF DATA
signal rd_data0_execute : std_logic_vector(15 downto 0):= "0000000000000000";
signal rd_data1_execute : std_logic_vector(15 downto 0):= "0000000000000000";

signal rd_data0_memory_access : std_logic_vector(15 downto 0):= "0000000000000000";
signal rd_data1_memory_access : std_logic_vector(15 downto 0):= "0000000000000000";


signal rd_data0_write_back : std_logic_vector(15 downto 0):= "0000000000000000";

--ALU
signal alu_output_0_memory_access :std_logic_vector(15 downto 0):= "0000000000000000";

signal alu_output_0_write_back :std_logic_vector(15 downto 0):= "0000000000000000";

--Individual states
signal fetch_state : stage_state_type := RESET_STATE;
signal decode_state : stage_state_type := RESET_STATE;
signal execute_state : stage_state_type := RESET_STATE;
signal memory_access_state : stage_state_type := RESET_STATE;
signal write_state : stage_state_type := RESET_STATE;


begin

	fetch0: fetch  port map(clk, rst , fetch_state, program_counter, instruction_0);

	decode0: decode port map(clk, rst,  decode_state, instruction_0, z_0 , n_0,  instruction_3, z_3, n_3, alu_output_0_memory_access, rd_data0_memory_access, instruction_1, z_1 , n_1  ,rf_index_0_mux_state , rd_index0, rd_index1, program_counter );

	execute0: execute port map(clk, rst,  execute_state, instruction_1, z_1 , n_1, rd_data0_mux_output, rd_data1 , instruction_2, z_2 , n_2 ,rd_data0_execute , rd_data1_execute , rd_index2 , input_alu_mode, alu_input_0_mux_0_state ,  alu_input_0_mux_1_state , alu_input_1_mux_0_state , alu_input_1_mux_1_state   , alu_rst);

	memory_access0: memory_access port map(clk, rst,  memory_access_state, instruction_2, z_2 , n_2, rd_data0_execute , rd_data1_execute,  alu_output_0, in_data, multiply_result, instruction_3, z_3 , n_3 , rd_data0_memory_access , rd_data1_memory_access, alu_output_0_memory_access , out_data, multiply_result_memory_access, mem_out );

	write_back0: write_back port map(clk, rst,  write_state,  instruction_3, z_3 , n_3, rd_data0_memory_access, rd_data1_memory_access, alu_output_0_memory_access, mem_out, rd_index0, rd_index1, rd_index2, program_counter,multiply_result_memory_access,rd_data0_write_back , alu_output_0_write_back  , multiply_result_write_back , rd_data0, rd_data1,rd_data2 );



	alu0: alu port map(alu_rst, input_alu_mode , alu_input_0, alu_input_1 , z_0 , n_0  , alu_output_0 , multiply_result);


	process(clk,rst,in_data,
					current_hold_state,
					rd_index0, rd_index1 ,rd_index2,
					rd_data0 , rd_data1, rd_data2,rd_data0_mux_output,
					rf_index_0_mux_state,
					program_counter,
					alu_input_0_mux_0_output,
					alu_input_0_mux_0_state,
					alu_input_0_mux_1_state,
					alu_input_1_mux_0_output,
					alu_input_1_mux_0_state,
					alu_input_1_mux_1_state,
					alu_rst,
					alu_input_0, alu_input_1, alu_output_0, multiply_result,
					input_alu_mode,
					mem_out,
					multiply_result_memory_access,
					multiply_result_write_back,
					instruction_0,
					z_0,
					n_0,
					instruction_1,
					z_1,
					n_1,
					instruction_2,
					z_2,
					n_2,
					instruction_3,
					z_3,
					n_3,
					rd_data0_execute,
					rd_data1_execute,
					rd_data0_memory_access,
					rd_data1_memory_access,
					rd_data0_write_back,
					alu_output_0_memory_access,
					alu_output_0_write_back,
					fetch_state,
					decode_state,
					execute_state,
					memory_access_state,
					write_state)
	begin
	--SYNC CODE
	if (rising_edge(clk)) then
		if (rst = '1') then --RESET
			current_hold_state <= CU_RESET;

			fetch_state <= RESET_STATE;
			decode_state <= RESET_STATE;
			execute_state <= RESET_STATE;
			memory_access_state <= RESET_STATE;
			write_state <= RESET_STATE;
		else

			case current_hold_state is
				when CU_RESET => --RESET
					current_hold_state <= CU_RUN;

					fetch_state <= RUN_STATE;
					decode_state <= RUN_STATE;
					execute_state <= RUN_STATE;
					memory_access_state <= RUN_STATE;
					write_state <= RUN_STATE;

				when CU_RUN => --RUN_STATE
					if (instruction_0(15 downto 9)  = TEST_INSTR) then --TEST INSTRUCTION
						current_hold_state <= CU_TEST;

						fetch_state <= RESET_STATE;
						decode_state <= STALL_STATE;
						execute_state <= RUN_STATE;
						memory_access_state <= RUN_STATE;
						write_state <= RUN_STATE;
					elsif  (instruction_0(15 downto 12) = "1000") then --BRANCH INSTRUCTION
						current_hold_state <= CU_BRANCH;

						fetch_state <= STALL_STATE;
						decode_state <= RESET_STATE;
						execute_state <= RUN_STATE;
						memory_access_state <= RUN_STATE;
						write_state <= RUN_STATE;
					else --RUN normally
						current_hold_state <= CU_RUN;

						fetch_state <= RUN_STATE;
						decode_state <= RUN_STATE;
						execute_state <= RUN_STATE;
						memory_access_state <= RUN_STATE;
						write_state <= RUN_STATE;
					end if;

				when CU_TEST => --TEST IN ALU
					current_hold_state <= CU_RUN;

					fetch_state <= RUN_STATE;
					decode_state <= RUN_STATE;
					execute_state <= RUN_STATE;
					memory_access_state <= RUN_STATE;
					write_state <= RUN_STATE;

				when CU_BRANCH => --FLUSH BRANCH
					current_hold_state <= CU_BRANCH_1;

					fetch_state <= STALL_STATE;
					decode_state <= RESET_STATE;
					execute_state <= STALL_STATE;
					memory_access_state <= RUN_STATE;
					write_state <= RUN_STATE;

				when CU_BRANCH_1 => --FLUSH BRANCH
					current_hold_state <= CU_BRANCH_2;

					fetch_state <= RESET_STATE;
					decode_state <= WRITE_PC_STATE;
					execute_state <= STALL_STATE;
					memory_access_state <= STALL_STATE;
					write_state <= RUN_STATE;

				when CU_BRANCH_2 => --RESUME
					current_hold_state <= CU_RUN;

					fetch_state <= RUN_STATE;
					decode_state <= RUN_STATE;
					execute_state <= RUN_STATE;
					memory_access_state <= RUN_STATE;
					write_state <= RUN_STATE;

			end case;

		end if;
	end if;


	--RF INDEX 0 MUX
	case rf_index_0_mux_state is
				when FOWARD_TO_INDEX_0 =>
						rd_data0_mux_output <= rd_data0;
				when EX_TO_INDEX_0 =>
						rd_data0_mux_output <= rd_data0_execute;
				when MEM_TO_INDEX_0 =>
						rd_data0_mux_output <= rd_data0_memory_access;
				when WR_TO_INDEX_0 =>
						rd_data0_mux_output <= rd_data0_write_back;

				when LOADIMM_UPPER =>
						rd_data0_mux_output(7 downto 0)  <= rd_data0(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= instruction_1(7 downto 0);
				when LOADIMM_LOWER =>
						rd_data0_mux_output(7 downto 0)  <= instruction_1(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= rd_data0(15 downto 8);
				when EX_LOADIMM_UPPER =>
						rd_data0_mux_output(7 downto 0)  <= rd_data0_execute(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= instruction_1(7 downto 0);
				when EX_LOADIMM_LOWER =>
						rd_data0_mux_output(7 downto 0)  <= instruction_1(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= rd_data0_execute(15 downto 8);
				when MEM_LOADIMM_UPPER =>
						rd_data0_mux_output(7 downto 0)  <= rd_data0_memory_access(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= instruction_1(7 downto 0);
				when MEM_LOADIMM_LOWER =>
						rd_data0_mux_output(7 downto 0)  <= instruction_1(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= rd_data0_memory_access(15 downto 8);
				when WR_LOADIMM_UPPER =>
						rd_data0_mux_output(7 downto 0)  <= rd_data0_write_back(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= instruction_1(7 downto 0);
				when WR_LOADIMM_LOWER =>
						rd_data0_mux_output(7 downto 0)  <= instruction_1(7 downto 0);
						rd_data0_mux_output(15 downto 8) <= rd_data0_write_back(15 downto 8);

				when MEM_ALU_OUTPUT_MEM_TO_INDEX_0 =>
						rd_data0_mux_output <= alu_output_0_memory_access;
				when WRITE_BACK_ALU_OUTPUT_TO_TO_INDEX_0 =>
						rd_data0_mux_output <= alu_output_0_write_back;

				when MULTI_RESULT_TO_INDEX_0 =>
						rd_data0_mux_output <= multiply_result_write_back;

				when others  =>
						rd_data0_mux_output <= (others => '0');
	end case;



	--ALU INPUT 0 MUX 0
	case alu_input_0_mux_0_state is
				when RF_INDEX_0 =>
						alu_input_0_mux_0_output <= rd_data0_execute;
				when MEM_ALU_OUTPUT_TO_ALU_0 =>
						alu_input_0_mux_0_output <= alu_output_0_memory_access;
				when WRITE_BACK_ALU_OUTPUT_TO_ALU_0 =>
						alu_input_0_mux_0_output <= alu_output_0_write_back;
				when RF_ALU_OUTPUT_TO_ALU_0 =>
						alu_input_0_mux_0_output <= rd_data2;
				when PCTOALU =>
						alu_input_0_mux_0_output <= program_counter;
				when others  =>
						alu_input_0_mux_0_output <= (others => '0');
	end case;


	--ALU INPUT 0 MUX 1
	case alu_input_0_mux_1_state is
				when EMPTY =>
						alu_input_0 <= (others => '0');
				when FOWARD_TO_ALU_0 =>
						alu_input_0 <= alu_input_0_mux_0_output;
				when INDEX_0_SHIFT_0 =>
						alu_input_0(0) <= '0';
						alu_input_0(15 downto 1) <= alu_input_0_mux_0_output(15 downto 1) ;
				when others  =>
						alu_input_0 <= (others => '0');
	end case;

	--ALU INPUT 1 MUX 0
	case alu_input_1_mux_0_state is
				when RF_INDEX_1 =>
						alu_input_1_mux_0_output <= rd_data1_execute;
				when MEM_ALU_OUTPUT_TO_ALU_1 =>
						alu_input_1_mux_0_output <= alu_output_0_memory_access;
				when WRITE_BACK_ALU_OUTPUT_TO_ALU_1 =>
						alu_input_1_mux_0_output <= alu_output_0_write_back;
				when RF_ALU_OUTPUT_TO_ALU_1 =>
						alu_input_1_mux_0_output <= rd_data2;
				when INSTRUCTION_TO_ALU =>
						alu_input_1_mux_0_output <= instruction_2;
				when others  =>
						alu_input_1_mux_0_output <= (others => '0');
	end case;

	--ALU INPUT 1 MUX 1
	case alu_input_1_mux_1_state is
				when EMPTY =>
						alu_input_1 <= (others => '0');
				when FOWARD_TO_ALU_1 =>
						alu_input_1 <= alu_input_1_mux_0_output;
				when INDEX_1_SHIFT_0 =>
						alu_input_1(0) <= '0';
						alu_input_1(9 downto 1) <= alu_input_1_mux_0_output(8 downto 0);
						alu_input_1(15 downto 10) <= (others => alu_input_1_mux_0_output(8));
				when INDEX_1_SHIFT_1 =>
						alu_input_1(0) <= '0';
						alu_input_1(6 downto 1) <= alu_input_1_mux_0_output(5 downto 0);
						alu_input_1(15 downto 7) <= (others => alu_input_1_mux_0_output(5));
				when ALU_MASK =>
						alu_input_1 <= (15 downto 4 => '0') &  alu_input_1_mux_0_output(3 downto 0);
				when others  =>
						alu_input_1 <= (others => '0');
	end case;



end process;

end Behavioral;
