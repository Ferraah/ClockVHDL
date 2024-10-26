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

    -- Test process
    test_process : process
    begin
        -- Reset the clock
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Enter SETTING_MODE by holding `b1` for 20 clock cycles
        b1 <= '1';
        wait for 400 ns; -- Hold `b1` for 20 cycles to toggle setting mode
        b1 <= '0';

        wait for 20 ns; -- Allow `SETTING_MODE` to stabilize

        -- Set minutes to 59
        -- Set minutes (units) to 9
        for i in 1 to 9 loop
            b3 <= '1';  
            wait for 20 ns;
            b3 <= '0';
            wait for 20 ns;
        end loop;

        -- Switch to minutes decimals and set it to 5
        b2 <= '1';
        wait for 20 ns;
        b2 <= '0';
        
        for i in 1 to 5 loop
            b3 <= '1';
            wait for 20 ns;
            b3 <= '0';
            wait for 20 ns;
        end loop;

        -- Switch to hours units and set it to 3
        b2 <= '1';
        wait for 20 ns;
        b2 <= '0';

        for i in 1 to 3 loop
            b3 <= '1';
            wait for 20 ns;
            b3 <= '0';
            wait for 20 ns;
        end loop;

        -- Switch to hours decimals and set it to 2 (to make it 23)
        b2 <= '1';
        wait for 20 ns;
        b2 <= '0';

        for i in 1 to 2 loop
            b3 <= '1';
            wait for 20 ns;
            b3 <= '0';
            wait for 20 ns;
        end loop; -- Now we are at 23:59


        -- Setting example 14:59
        
        -- Switch to hours units
        for i in 1 to 3 loop
            b2 <= '1';
            wait for 20 ns; 
            b2 <= '0';
            wait for 20 ns;
        end loop;
        
        b3 <= '1';
        wait for 20 ns;
        b3 <= '0'; -- 04:59

        -- Switch to hour decimals
        b2 <= '1';
        wait for 20 ns; 
        b2 <= '0';
        
        b3 <= '1';
        wait for 20 ns;
        b3 <= '0'; -- 14:59
       
       -- Setting example 20:59
       
        -- Incrementing the decimal automatically zero the units
        wait for 20 ns;

        b3 <= '1';
        wait for 20 ns;
        b3 <= '0'; -- 20:59

        
        
        wait for 40 ns;
        -- Exit setting mode by holding `b1` for 20 clock cycles again
        
        b1 <= '1';
        wait for 400 ns; -- Hold `b1` to toggle setting mode off
        b1 <= '0';

        
        -- End simulation
        wait for 200 ns;
        assert false report "End of simulation" severity note;
        wait;
    end process test_process;

end testbench;
