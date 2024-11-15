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

    -- To debug
    signal m_u, m_d, h_u, h_d : integer range 0 to 9;

    -- Output 7-segment display signals
    signal segments : std_logic_vector(6 downto 0);
    signal anode : std_logic_vector(3 downto 0);

    -- constant clk_period : time := 20 ns; -- 20 ns per clock cycle
    constant clk_period : time := 20 ns; -- 20 ns per clock cycle
    constant clk_buttons : time := 10*20 ns; 

    -- Clock instance
    component Main
        port (
            clk, rst : IN std_logic;
            b1, b2, b3, b4 : IN std_logic; -- Buttons
            segments : OUT std_logic_vector;
            anode : OUT std_logic_vector;
            check_m_u, check_m_d, check_h_u, check_h_d : OUT INTEGER RANGE 0 TO 9; -- Check time values 	
            check_alarm_active : OUT std_logic; -- Check alarm active signal
            alarm_led : OUT std_logic -- Alarm LED
    
        );
    end component;

    -- Clock cycles to perform the indicated time on the clock
    pure function time_to_clock_cycles(hours : integer; minutes: integer) return integer is
    begin
       return (hours * 3600 + minutes * 60) * 10; 
    end function;

begin
    -- Instantiate the clock
    uut: Main
        port map (
            clk => clk,
            rst => rst,
            b1 => b1,
            b2 => b2,
            b3 => b3,
            b4 => b4,
            segments => segments,
            anode => anode,
            check_m_u => m_u,
            check_m_d => m_d,
            check_h_u => h_u,
            check_h_d => h_d
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
        wait for 10*clk_period;

        -- Every minute check for right time
        
        for i in 0 to 60*24 - 1 loop
            -- Check if the minutes and hours are correct
            assert m_u = (i mod 10) report "Incorrect minutes units" severity error;
            assert m_d = ((i/10) mod 6) report "Incorrect minutes tens" severity error;
            assert h_u = ((i/60) mod 10) report "Incorrect hours units" severity error;
            assert h_d = ((i/600) mod 4) report "Incorrect hours tens" severity error;

            wait for time_to_clock_cycles(0, 1)*clk_buttons;
        end loop; 


        wait for clk_buttons;
        rst <= '1';
        assert false report "Testbench finished" severity note;

    end process test_process;

end testbench;
