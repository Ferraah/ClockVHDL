library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Display is
    port (
        clk            : in std_logic;
        rst            : in std_logic;
        m_u            : in INTEGER RANGE 0 TO 9; -- minutes units (0 to 9)
        m_d            : in INTEGER RANGE 0 TO 5; -- minutes tens (0 to 5)
        h_u            : in INTEGER RANGE 0 TO 9; -- hours units (0 to 9)
        h_d            : in INTEGER RANGE 0 TO 2; -- hours tens (0 to 2)
        segments       : out std_logic_vector(6 downto 0);
        anode : out STD_LOGIC_VECTOR (3 downto 0)
    );
end Display;

architecture Behavioral of Display is

    component ClockDividerBlink
        Port (
            clk_in  : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            clk_out : out STD_LOGIC
        );
    end component;

    signal clk_blink          : std_logic := '0'; -- Slow clock for blinking
    signal digit_selector_reg  : integer range 0 to 3 := 0;
    signal current_value       : integer range 0 to 9 := 0;

begin

    -- Process to handle digit selection
    process (clk, rst)
    begin
        if rst = '1' then
            digit_selector_reg <= 0;
        elsif rising_edge(clk) then
            digit_selector_reg <= (digit_selector_reg + 1) mod 4; 
        end if;
    end process;


    -- Process to assign current digit value based on selector
    process (digit_selector_reg, m_u, m_d, h_u, h_d)
    begin
       case digit_selector_reg is
           when 0 =>
               current_value <= m_u;
           when 1 =>
               current_value <= m_d;
           when 2 =>
               current_value <= h_u;
           when 3 =>
               current_value <= h_d;
           when others =>
               current_value <= 0;
       end case; 
    end process;

    -- Process to map current value to 7-segment display encoding
    process (current_value)
    begin  
        case current_value is
            WHEN 0 => segments <= "0000001"; -- 0
            WHEN 1 => segments <= "1001111"; -- 1
            WHEN 2 => segments <= "0010010"; -- 2
            WHEN 3 => segments <= "0000110"; -- 3
            WHEN 4 => segments <= "1001100"; -- 4
            WHEN 5 => segments <= "0100100"; -- 5
            WHEN 6 => segments <= "0100000"; -- 6
            WHEN 7 => segments <= "0001111"; -- 7
            WHEN 8 => segments <= "0000000"; -- 8
            WHEN 9 => segments <= "0000100"; -- 9
            WHEN others => segments <= "1111111"; -- blank
        end case;
    end process;

    process (digit_selector_reg)
    begin
        case digit_selector_reg is
            when 0 =>
                anode <= "0111";
            when 1 =>
                anode <= "1011";
            when 2 =>
                anode <= "1101";
            when 3 =>
                anode <= "1110";
            when others =>
                anode <= "1111";
        end case;
    end process;
end Behavioral;
