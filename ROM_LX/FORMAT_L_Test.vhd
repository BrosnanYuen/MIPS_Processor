
--
-- Created on Thu Mar 24 13:46:54 PDT 2016
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ROM_VHDL is
    port(
         addr     : in  std_logic_vector (6 downto 0);
         data     : out std_logic_vector (15 downto 0)
         );
end ROM_VHDL;

architecture BHV of ROM_VHDL is

    type ROM_TYPE is array (0 to 127 ) of std_logic_vector (15 downto 0);

    constant rom_content : ROM_TYPE := (
		000 => "0010010000000011", -- LOADIMM.lower #3; R7 <= #3
		001 => "0010011000111000", -- Mov R7 into R0     R0 = 3
		002 => "0010010000000101", -- LOADIMM.lower #5; R7 <= #5
		003 => "0010011001111000", -- Mov R7 into R1     R1 = 5
		004 => "0000001001001000", -- Add R1 and R0, store into R1; Add R1,R1,R0
		005 => "0000001001001000", -- Add R1 and R0, store into R1; Add R1,R1,R0
		006 => "0010010000000001", -- LOADIMM.lower #3; R7 <= #1
		007 => "0010011011111000", -- Mov R7 into R3
		008 => "0010010000000101", -- LOADIMM.lower #5; R7 <= #5
		009 => "0010011100111000", -- Mov R7 into R4
		010 => "0000010100100011", -- Sub R4 and R3, store into R4; Sub R4,R4,R3
		011 => "0000010100100011", -- Sub R4 and R3, store into R4; Sub R4,R4,R3
	others => x"0000" ); -- NOP
begin

p1:    process (addr)
    begin
				data <= rom_content(to_integer(unsigned(addr)));
    end process;
end BHV;
