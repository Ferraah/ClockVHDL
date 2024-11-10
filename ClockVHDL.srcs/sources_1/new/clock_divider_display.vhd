library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ClockDividerDisplay is
    Generic (
        --DIVISOR : integer := 10000 -- Division factor
        DIVISOR : integer := 100 -- Division factor
    );
    Port (
        clk_in  : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        clk_out : out STD_LOGIC
    );
end ClockDividerDisplay;

architecture Behavioral of ClockDividerDisplay is
    signal cnt    : integer range 0 to DIVISOR-1 := 0;
    signal toggle : STD_LOGIC := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            if reset = '1' then
                cnt <= 0;
                toggle <= '0';
                clk_out <= '0';
            else
                if cnt = (DIVISOR / 2 - 1) then
                    toggle <= not toggle;
                    clk_out <= toggle;
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
