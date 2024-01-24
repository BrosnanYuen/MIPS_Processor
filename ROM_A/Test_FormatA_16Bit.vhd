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
	"0000001011010001",  -- ADD r3, r2, r1
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000101011000010",  -- SHL r3, 2
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000011010001011",  -- MUL r2, r1, r3
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0100000010000000",  -- OUT r2
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000",  -- NOP
	"0000000000000000" -- NOP
	); -- NOP
begin
p1:    process (addr)
    begin
				data <= rom_content(to_integer(unsigned(addr)));
    end process;
end Behavioral;
