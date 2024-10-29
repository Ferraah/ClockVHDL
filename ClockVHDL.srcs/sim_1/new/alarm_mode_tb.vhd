LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY tb_clock IS
END tb_clock;

ARCHITECTURE behavior OF tb_clock IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT clock
    PORT(
        clk : IN std_logic;
        rst : IN std_logic;
        b1 : IN std_logic;
        b2 : IN std_logic;
        b3 : IN std_logic;
        b4 : IN std_logic;
        d1 : OUT std_logic_vector(6 DOWNTO 0);
        d2 : OUT std_logic_vector(6 DOWNTO 0);
        d3 : OUT std_logic_vector(6 DOWNTO 0);
        d4 : OUT std_logic_vector(6 DOWNTO 0)
    );
    END COMPONENT;

    -- Inputs
    SIGNAL clk : std_logic := '0';
    SIGNAL rst : std_logic := '0';
    SIGNAL b1 : std_logic := '0';
    SIGNAL b2 : std_logic := '0';
    SIGNAL b3 : std_logic := '0';
    SIGNAL b4 : std_logic := '0';

    -- Outputs
    SIGNAL d1 : std_logic_vector(6 DOWNTO 0);
    SIGNAL d2 : std_logic_vector(6 DOWNTO 0);
    SIGNAL d3 : std_logic_vector(6 DOWNTO 0);
    SIGNAL d4 : std_logic_vector(6 DOWNTO 0);

    -- Clock period definitions
    CONSTANT clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: clock PORT MAP (
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

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the clock
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 6000 ns;

        -- Set the alarm time to 00:01
        b4 <= '1'; -- Enter alarm setting mode
        wait for 200 ns;
        b4 <= '0';
        wait for 20 ns;
        
		for i in 1 to 24 loop
            b3 <= '1';
            wait for 30 ns;
            b3 <= '0';
            wait for 20 ns;
        end loop; 

        --b2 <= '1'; -- Select hour
        --wait for 20 ns;
        --b2 <= '0';
        --wait for 20 ns;

        --b3 <= '1'; -- Increment hour to 01
        --wait for 20 ns;
        --b3 <= '0';
        --wait for 20 ns;

        b2 <= '1'; -- Select minute
        wait for 20 ns;
        b2 <= '0';
        wait for 20 ns;

        b3 <= '1'; -- Increment minute to 01
        wait for 20 ns;
        b3 <= '0';
        wait for 20 ns;
        
        b3 <= '1'; -- Increment minute to 02
        wait for 20 ns;
        b3 <= '0';
        wait for 20 ns;
        

        b4 <= '1'; -- Exit alarm setting mode
        wait for 200 ns;
        b4 <= '0';
        wait for 20 ns;

        -- Simulate time passing to reach 00:01


        wait for 200*2 ns;
        b2 <= '1';
        wait for 20 ns;
        b2 <= '0';
        wait for 200 ns;

        
        rst <= '1';
    end process;

END;
