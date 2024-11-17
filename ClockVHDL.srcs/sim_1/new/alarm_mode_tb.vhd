library IEEE;
use IEEE.std_logic_1164.all;
-- USE IEEE.std_logic_unsigned.ALL;

entity alarm_tb is 
end alarm_tb;

architecture testbench of alarm_tb is 
    -- Clock signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- Button signals
    signal b1 : std_logic := '0'; -- Toggle SETTING_MODE
    signal b2 : std_logic := '0'; -- Switch between digits
    signal b3 : std_logic := '0'; -- Increment selected digit
    signal b4 : std_logic := '0'; -- (Unused in this test)

    signal check_m_u, check_m_d, check_h_u, check_h_d : integer range 0 to 9;
    
    -- Output 7-segment display signals
    signal d1, d2, d3, d4 : std_logic_vector(6 downto 0);

    signal check_alarm_active: std_logic := '0';
    signal alarm_led : std_logic := '0';

    constant clk_period : time := 20 ns; -- 20 ns per clock cycle
    constant clk_buttons : time := 10*20 ns; 
    -- Clock instance
    component clock
        port (
            clk, rst : in std_logic;
            b1, b2, b3, b4 : in std_logic;
            d1, d2, d3, d4 : out std_logic_vector(6 downto 0);
		    check_m_u, check_m_d, check_h_u, check_h_d : inout integer range 0 to 9;
            check_alarm_active: out std_logic;
            alarm_led: out std_logic
        );
    end component;

    -- Clock cycles to perform the indicated time on the clock
    pure function time_to_clock_cycles(hours : integer; minutes: integer) return integer is
    begin
       return (hours * 3600 + minutes * 60) * 10; 
    end function;


begin

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
            check_m_u => check_m_u,
            check_m_d => check_m_d,
            check_h_u => check_h_u,
            check_h_d => check_h_d,
            check_alarm_active => check_alarm_active,
            alarm_led => alarm_led

        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process clk_process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the clock
        rst <= '1';
        wait for clk_buttons;
        rst <= '0';
        wait for 1000 ns;

        -- Enter alarm mode 
        b4 <= '1'; 
        wait for clk_buttons*2; -- Hold `b4` for 2 seconds to enter alarm mode
        b4 <= '0';
        wait for clk_buttons;
      
      	-- set the alarm to 00:02, doing a full cycle of digit
		-- increment minutes
        for i in 1 to 64 loop
            b3 <= '1';
            wait for clk_buttons;
            b3 <= '0'; -- Release b3 to simulate button lock
            wait for clk_buttons; -- Delay to ensure only one increment per press
        end loop;
            

		-- increment hours, doing a full cycle of digit
         for i in 1 to 24 loop
            b2 <= '1';
            wait for clk_buttons;
            b2 <= '0'; -- Release b3 to simulate button lock
            wait for clk_buttons; -- Delay to ensure only one increment per press
        end loop;


		-- exit alarm setting with saving the alarm time
        b1 <= '1';
        wait for clk_buttons*2; -- Hold `b1` for 2 seconds to exit alarm mode
        b1 <= '0';
        wait for clk_buttons;

        assert check_alarm_active = '1' report "Alarm not active" severity error;

        wait for time_to_clock_cycles(0, 1)*clk_period; -- Wait for 1 minute ) 
        
        assert check_m_u = 4 report "Incorrect minutes units" severity error;
        assert check_m_d = 0 report "Incorrect minutes tens" severity error;
        assert check_h_u = 0 report "Incorrect hours units" severity error;
        assert check_h_d = 0 report "Incorrect hours tens" severity error;

        assert alarm_led = '1' report "Alarm not ringing" severity error;

        b2 <= '1'; 
        wait for clk_buttons*2; -- Hold `b2` for 2 seconds to stop the alarm
        b2 <= '0';
            
        assert alarm_led = '0' report "Alarm not stopped" severity error;
        assert check_alarm_active = '0' report "Alarm not deactivated" severity error;
            
        wait for 1000 ns;
        rst <= '1';
        assert false report "Testbench finished" severity note;
        wait;
    end process;

end testbench;
