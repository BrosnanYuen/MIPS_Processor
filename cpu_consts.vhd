
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

package cpu_consts is

--DECODE SIGNALS
type rf_index_0_mux_type is ( FOWARD_TO_INDEX_0, EX_TO_INDEX_0, MEM_TO_INDEX_0, WR_TO_INDEX_0 ,LOADIMM_UPPER, LOADIMM_LOWER,
 EX_LOADIMM_UPPER, EX_LOADIMM_LOWER ,   MEM_LOADIMM_UPPER, MEM_LOADIMM_LOWER ,  WR_LOADIMM_UPPER, WR_LOADIMM_LOWER,
 MEM_ALU_OUTPUT_MEM_TO_INDEX_0, WRITE_BACK_ALU_OUTPUT_TO_TO_INDEX_0, MULTI_RESULT_TO_INDEX_0);


--EXECUTE signals
type alu_input_0_mux_0_type is ( RF_INDEX_0, MEM_ALU_OUTPUT_TO_ALU_0, WRITE_BACK_ALU_OUTPUT_TO_ALU_0, RF_ALU_OUTPUT_TO_ALU_0, PCTOALU   );

type alu_input_0_mux_1_type is ( EMPTY , FOWARD_TO_ALU_0, INDEX_0_SHIFT_0  );


type alu_input_1_mux_0_type is ( RF_INDEX_1, MEM_ALU_OUTPUT_TO_ALU_1, WRITE_BACK_ALU_OUTPUT_TO_ALU_1, RF_ALU_OUTPUT_TO_ALU_1 , INSTRUCTION_TO_ALU );

type alu_input_1_mux_1_type is ( EMPTY , FOWARD_TO_ALU_1, INDEX_1_SHIFT_0 , INDEX_1_SHIFT_1 , ALU_MASK );

--ALU signals
constant ALU_NOP : std_logic_vector (2 downto 0) := "000";

constant ALU_ADD : std_logic_vector (2 downto 0) := "001";

constant ALU_SUB : std_logic_vector (2 downto 0) := "010";

constant ALU_MULTI : std_logic_vector (2 downto 0) := "011";

constant ALU_NAND : std_logic_vector (2 downto 0) := "100";

constant ALU_SHIFT_LEFT : std_logic_vector (2 downto 0) := "101";

constant ALU_SHIFT_RIGHT : std_logic_vector (2 downto 0) := "110";

constant ALU_TEST : std_logic_vector (2 downto 0) := "111";


--INSTRUCTIONS

constant NOP_INSTR : std_logic_vector (6 downto 0) := "0000000";



constant ADD_INSTR : std_logic_vector (6 downto 0) := "0000001";

constant SUB_INSTR : std_logic_vector (6 downto 0) := "0000010";

constant MUL_INSTR : std_logic_vector (6 downto 0) := "0000011";

constant NAND_INSTR : std_logic_vector (6 downto 0) := "0000100";

constant SHL_N_INSTR : std_logic_vector (6 downto 0) := "0000101";

constant SHR_Z_INSTR : std_logic_vector (6 downto 0) := "0000110";



constant TEST_INSTR : std_logic_vector (6 downto 0) := "0000111";

constant OUT_INSTR : std_logic_vector (6 downto 0) := "0100000";

constant IN_INSTR : std_logic_vector (6 downto 0) := "0100001";

constant BRR_INSTR : std_logic_vector (6 downto 0) := "1000000";

constant BRR_N_INSTR : std_logic_vector (6 downto 0) := "1000001";

constant BRR_Z_INSTR : std_logic_vector (6 downto 0) := "1000010";



constant BR_INSTR : std_logic_vector (6 downto 0) := "1000011";

constant BR_N_INSTR : std_logic_vector (6 downto 0) := "1000100";

constant BR_Z_INSTR : std_logic_vector (6 downto 0) := "1000101";

constant BR_SUB_INSTR : std_logic_vector (6 downto 0) := "1000110";

constant RETURN_INSTR : std_logic_vector (6 downto 0) := "1000111";

constant LOAD_INSTR : std_logic_vector (6 downto 0) := "0010000";

constant STORE_INSTR : std_logic_vector (6 downto 0) := "0010001";

constant LOADIMM_INSTR : std_logic_vector (6 downto 0) := "0010010";

constant MOV_INSTR : std_logic_vector (6 downto 0) := "0010011";



constant MULTI_MOV_INSTR : std_logic_vector (6 downto 0) := "0010100";




--FSM STATES

type stage_state_type is (RESET_STATE, RUN_STATE , STALL_STATE , WRITE_PC_STATE );


type cu_state_type is (CU_RESET, CU_RUN , CU_TEST, CU_BRANCH ,CU_BRANCH_1, CU_BRANCH_2 );



--Registers
constant R7 : std_logic_vector (2 downto 0) := "111";



end cpu_consts;
