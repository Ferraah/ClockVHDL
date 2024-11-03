library IEEE;
use IEEE.std_logic_1164.all;

entity clock_tb is
end clock_tb;

architecture testbench of clock_tb is
    -- Clock signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    -- Button signals
    signal b1 : std_logic := '0'; -- Toggle SETTING_MODE
    signal b2 : std_logic := '0'; -- Switch between digits
    signal b3 : std_logic := '0'; -- Increment selected digit
    signal b4 : std_logic := '0'; -- (Unused in this test)

    -- Output 7-segment display signals
    signal d1, d2, d3, d4 : std_logic_vector(6 downto 0);

    constant clk_period : time := 20 ns; -- 20 ns per clock cycle

    -- Clock instance
    component clock
        port (
            clk, rst : in std_logic;
            b1, b2, b3, b4 : in std_logic;
            d1, d2, d3, d4 : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    -- Instantiate the clock
    uut: clock
        port map (
            clk => clk,
            rst => rst,
            b1 => b1,
            b2 => b2,
            b3 => b3,
            b4 => b4,
            d1 => d1,
            d2 => d2,
            d3 => d3,
            d4 => d4
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
    end process clk_process;

    -- Test process with button pressed lock functionality
    test_process : process
    begin
        -- Reset the clock
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for 1000 ns;
        
        -- Enter SETTING_MODE by pressing `b1` for more than 2s
        b1 <= '1';
        wait for clk_period*20; -- Hold `b1` for 20 cycles to toggle setting mode
        b1 <= '0';
        wait for clk_period; -- Allow `SETTING_MODE` to stabilize

        for i in 1 to 24 loop
            b2 <= '1';
            wait for clk_period;
            b2 <= '0'; -- Release b3 to simulate button lock
            wait for clk_period; -- Delay to ensure only one increment per press
        end loop;
        
        for i in 1 to 60 loop
            b3 <= '1';
            wait for clk_period;
            b3 <= '0'; -- Release b3 to simulate button lock
            wait for clk_period; -- Delay to ensure only one increment per press
        end loop;

--        -- test debouncing
--        b2 <= '1';
--        wait for 200 ns;
--        b2 <= '0';
--        wait for 200 ns;

    
        -- Exit setting mode by holding `b4` for 20 clock cycles again
        b4 <= '1';
        wait for clk_period*20; -- Hold `b1` to toggle setting mode off
        b4 <= '0';

        -- Additional checks can be added here to verify final output values for `d1`, `d2`, `d3`, and `d4`

        -- End simulation
        wait for 200 ns;
        assert false report "End of simulation" severity note;
        wait;
    end process test_process;

end testbench;
