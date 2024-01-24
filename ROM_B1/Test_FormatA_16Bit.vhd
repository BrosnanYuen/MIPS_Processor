library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ROM_VHDL is
    port(
         addr     : in  std_logic_vector (6 downto 0);
         data     : out std_logic_vector (15 downto 0)
         );
end ROM_VHDL;

architecture Behavioral of ROM_VHDL is
	type ROM_TYPE is array (0 to 127 ) of std_logic_vector (15 downto 0);

	constant rom_content : ROM_TYPE := (
		000 => "0100001000000000", -- IN R0 , 02  -- This example tests how data dependencies are handled
		001 => "0100001001000000", -- IN R1 , 03  -- The values to be loaded into the corresponding resgister.
		002 => "0100001010000000", -- IN R2 , 01
		003 => "0100001011000000", -- IN R3 , 05  --  End of initialization
		004 => "0000001001001010", -- ADD R1, R1, R2     R1 = 3+1 = 4
		005 => "0000010010001000", -- SUB R2, R1, R0     R2 = 4 - 2 = 2
		006 => "0000010001011010", -- SUB R1, R3, R2     R1 = 5 - 2 = 3
		others => x"0000" ); -- NOP
begin
p1:    process (addr)
    begin
				data <= rom_content(to_integer(unsigned(addr)));
    end process;
end Behavioral;
