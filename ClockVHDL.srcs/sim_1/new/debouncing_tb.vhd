----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/16/2024 02:51:42 PM
-- Design Name: 
-- Module Name: debouncing_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncing_tb is
end debouncing_tb;

architecture Behavioral of debouncing_tb is
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

    clk_buttons_process : process
    begin
        rst <= '1';
        wait for clk_buttons;
        rst <= '0';
        wait for 1000 ns;
        b3 <= '1';
        wait for clk_buttons * (20);
        b3 <= '0';
        wait for clk_buttons * 20;
        b1 <= '1';
        wait for clk_buttons * (80);
        b1 <= '0';
        wait for clk_buttons;
        b2 <= '1';
        wait for clk_buttons * 8;
        b2 <= '0';
        wait for clk_buttons;
        b3 <= '1';
        wait for clk_buttons * 8;
        b3 <= '0';
        wait for clk_buttons;
        
    end process;
    
end Behavioral;



