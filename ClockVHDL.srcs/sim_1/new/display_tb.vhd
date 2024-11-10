library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Display_tb is
end Display_tb;

architecture Behavioral of Display_tb is
    -- Component declaration for the Display module
    component Display
        port (
            clk : in std_logic;
            rst : in std_logic;
            m_u : in INTEGER RANGE 0 TO 9;
            m_d : in INTEGER RANGE 0 TO 5;
            h_u : in INTEGER RANGE 0 TO 9;
            h_d : in INTEGER RANGE 0 TO 2;
            segments : out std_logic_vector(6 downto 0);
            anode : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals for connecting to the Display module
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal m_u : INTEGER RANGE 0 TO 9 := 0;
    signal m_d : INTEGER RANGE 0 TO 5 := 0;
    signal h_u : INTEGER RANGE 0 TO 9 := 0;
    signal h_d : INTEGER RANGE 0 TO 2 := 0;
    signal segments : std_logic_vector(6 downto 0);
    signal anode : std_logic_vector(3 downto 0);

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the Display component
    uut: Display
        port map (
            clk => clk,
            rst => rst,
            m_u => m_u,
            m_d => m_d,
            h_u => h_u,
            h_d => h_d,
            segments => segments,
            anode => anode
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Reset sequence
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- Test case: 12:34
        h_d <= 1; h_u <= 2;
        m_d <= 3; m_u <= 4;
        wait for 200 ns;  -- Allow time for all digits to be displayed

        -- Test case: 23:59
        h_d <= 2; h_u <= 3;
        m_d <= 5; m_u <= 9;
        wait for 200 ns;

        -- Test case: 00:00
        h_d <= 0; h_u <= 0;
        m_d <= 0; m_u <= 0;
        wait for 200 ns;

        -- Test case: 11:11
        h_d <= 1; h_u <= 1;
        m_d <= 1; m_u <= 1;
        wait for 200 ns;

        -- Finish simulation
        wait;
    end process;
end Behavioral;
