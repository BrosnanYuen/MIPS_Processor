library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity ROM_VHDL is
    port(
         clk      : in  std_logic;
         addr     : in  std_logic_vector (6 downto 0);
         data     : out std_logic_vector (15 downto 0)
         );
end ROM_VHDL;

architecture Behavioral of ROM_VHDL is
    type ROM_TYPE is array (0 to 28) of std_logic_vector (15 downto 0);

    constant rom_content : ROM_TYPE := (
   	"0000000000000000",
	"0000000000000000",
	"0100001001000000",  -- IN r1
	"0100001010000000",  -- IN r2
	"0100001011000000",  -- IN r3
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000010011010001",  -- SUB r3, r2, r1   r3=0
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000111011000000",  -- TEST r3=0
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000111010000000",  -- TEST r2=2
	"0000000000000000",  -- NOP
	"0000010001011010",  -- SUB r1, r3, r2   r1=-2
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000111001000000",  -- TEST r1=-2
	"0000000000000000",
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000"); -- NOP
begin
p1:    process (clk,addr)
    begin
			if (falling_edge(clk)) then
				data <= rom_content(to_integer(unsigned(addr)));
			end if;
    end process;
end Behavioral;
