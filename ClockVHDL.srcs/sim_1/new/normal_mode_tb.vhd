library IEEE;
use IEEE.std_logic_1164.all;

entity normal_mode_tb is
end normal_mode_tb;

architecture testbench of normal_mode_tb is
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

    -- Clock cycles to perform the indicated time on the clock
    pure function time_to_clock_cycles(hours : integer; minutes: integer) return integer is
    begin
       return (hours * 3600 + minutes * 60) * 10; 
    end function;

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
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process clk_process;

    -- Test process with button pressed lock functionality
    test_process : process
    begin
        -- Reset the clock
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for 1000 ns;

        wait for time_to_clock_cycles(25, 0)*clk_period;
    end process test_process;

end testbench;
