library IEEE;
use IEEE.std_logic_1164.all;

entity setting_tb is
end setting_tb;

architecture testbench of setting_tb is
    -- Clock signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    -- Button signals
    signal b1 : std_logic := '0'; -- Toggle SETTING_MODE
    signal b2 : std_logic := '0'; -- Switch between digits
    signal b3 : std_logic := '0'; -- Increment selected digit
    signal b4 : std_logic := '0'; -- (Unused in this test)

    signal m_u, m_d, h_u, h_d : integer range 0 to 9;
    
    -- Output 7-segment display signals
    signal d1, d2, d3, d4 : std_logic_vector(6 downto 0);

    constant clk_period : time := 20 ns; -- 20 ns per clock cycle

    -- Clock instance
    component clock
        port (
            clk, rst : in std_logic;
            b1, b2, b3, b4 : in std_logic;
            d1, d2, d3, d4 : out std_logic_vector(6 downto 0);
		    check_m_u, check_m_d, check_h_u, check_h_d : inout integer range 0 to 9
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
            d4 => d4,
            check_m_u => m_u,
            check_m_d => m_d,
            check_h_u => h_u,
            check_h_d => h_d 
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
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

        -- Increment hours 24 times
        for i in 0 to 23 loop

            assert h_u = (i mod 10) report "Incorrect hours units" severity error;
            assert h_d = (i/10) report "Incorrect hours tens" severity error;

            b2 <= '1';
            wait for clk_period;
            b2 <= '0'; 
            wait for clk_period; 
        end loop;
        

        -- Increment minutes 60 times
        for i in 0 to 59 loop

            assert m_u = (i mod 10) report "Incorrect minutes units" severity error;
            assert m_d = ((i/10) mod 6) report "Incorrect minutes tens" severity error;

            b3 <= '1';
            wait for clk_period;
            b3 <= '0'; -- Release b3 to simulate button lock
            wait for clk_period; -- Delay to ensure only one increment per press
        end loop;


        -- Exit setting mode by holding `b4` for 20 clock cycles again
        b4 <= '1';
        wait for clk_period*20; 
        b4 <= '0';

        -- End simulation
        wait for 200 ns;
        assert false report "End of simulation" severity note;
        wait;
    end process test_process;

end testbench;
