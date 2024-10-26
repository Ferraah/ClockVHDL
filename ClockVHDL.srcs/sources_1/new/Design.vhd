library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity clock is
    port (
        clk, rst : in std_logic;
        b1, b2, b3, b4 : in std_logic;
        d1, d2, d3, d4 : out std_logic_vector(6 downto 0)
    );
end clock;

architecture hardware of clock is
    signal count_sec : integer range 0 to 59; -- seconds counter (0 to 59)
    signal count_clock : integer range 0 to 9; -- clock cycles counter (0 to 9)
    signal m_u : integer range 0 to 9; -- minutes units (0 to 9)
    signal m_d : integer range 0 to 5; -- minutes tens (0 to 5)
    signal h_u : integer range 0 to 9; -- hours units (0 to 9)
    signal h_d : integer range 0 to 2; -- hours tens (0 to 2)

    
    signal SETTING_MODE : boolean := false;
    signal CURRENT_DIGIT : integer range 0 to 3; -- digit selection for setting mode

    signal b2_pressed: boolean := false; 
    signal b3_pressed: boolean := false; 

begin


    -- Main clock process
    p_clock : process (clk, rst)
        variable hold_b1_time : integer := 0;
    begin
        -- RESET
        if rst = '1' then
            count_sec <= 0;
            count_clock <= 0;
            m_u <= 0;
            m_d <= 0;
            h_u <= 0;
            h_d <= 0;
            hold_b1_time := 0;
            SETTING_MODE <= false;
            CURRENT_DIGIT <= 0;

        elsif rising_edge(clk) then
        
            -- If the button has been held for some time 
            -- and now they are not, release the lock
            if b2_pressed and b2='0' then b2_pressed <= false; end if;
            if b3_pressed and b3='0' then b3_pressed <= false; end if;

            
            -- Check for button 1 press to toggle SETTING_MODE
            if b1 = '1' then
                hold_b1_time := hold_b1_time + 1;
                if hold_b1_time >= 20 then -- simulating a 2 seconds hold
                    SETTING_MODE <= not SETTING_MODE;
                    CURRENT_DIGIT <= 0;
                end if;
            else
                hold_b1_time := 0;
            end if;

            -- Normal mode: count seconds and increment digits accordingly
            if not SETTING_MODE then
                -- Update counters: each 10 clock cycles equals 1 second
                if count_clock = 9 then
                    count_sec <= count_sec + 1;
                    count_clock <= 0;

                    -- After 59 seconds, update minutes
                    if count_sec = 59 then
                        count_sec <= 0;

                        -- Increment minutes units
                        if m_u = 9 then
                            m_u <= 0;
                            if m_d = 5 then
                                m_d <= 0;
                                -- Increment hours units with wrap-around
                                if h_d = 0 and h_u = 9 then
                                    h_d <= 1;
                                    h_u <= 0;
                                elsif h_d = 1 and h_u = 9 then
                                    h_d <= 2;
                                    h_u <= 0;
                                elsif h_d = 2 and h_u = 3 then
                                    h_d <= 0;
                                    h_u <= 0;
                                else
                                    h_u <= h_u + 1;
                                end if;
                            else
                                m_d <= m_d + 1;
                            end if;
                        else
                            m_u <= m_u + 1;
                        end if;
                    end if;
                else
                    count_clock <= count_clock + 1;
                end if;

            -- Setting mode: adjust the current digit selected by `CURRENT_DIGIT`
            else
                if b2 = '1' and b2_pressed = false then
                    b2_pressed <= true;
                    CURRENT_DIGIT <= (CURRENT_DIGIT + 1) mod 4;
                end if;

                if b3 = '1' and b3_pressed = false then
                    
                    b3_pressed <= true;
                    -- Reset seconds to 0 when modifying any digits
                    count_sec <= 0;
                    count_clock <= 0;
                    
                    case CURRENT_DIGIT is
                        when 0 => -- Setting minutes units
                        
                            if m_u = 9 then m_u <= 0; else m_u <= m_u + 1; end if;
                        
                        when 1 => -- Setting minutes decimals
                            if m_d = 5 then m_d <= 0; else m_d <= m_d + 1; end if;
                            
                        when 2 => -- Setting hours units
                            if h_d = 2 and h_u = 3 then
                                h_d <= 0; -- Prevent >23
                                h_u <= h_u +1; 
                            elsif h_u = 9 then
                                h_u <= 0;           
                            else
                                h_u <= h_u + 1;
                            end if;
                            
                        when 3 => -- Setting hours decimals
                            if h_d = 2 then
                                h_d <= 0;
                            elsif h_d = 1 then
                                if h_u > 3 then h_u <= 0; end if; -- Prevent >23
                                h_d <= 2;
                            else
                                h_d <= 1; 
                            end if;
                        when others =>
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- 7-Segment Display process
    pout : process (h_u, h_d, m_u, m_d)
    begin
        -- Display minutes (units) on 7-segment
        case m_u is
            when 0 => d1 <= "0000001"; -- 0
            when 1 => d1 <= "1001111"; -- 1
            when 2 => d1 <= "0010010"; -- 2
            when 3 => d1 <= "0000110"; -- 3
            when 4 => d1 <= "1001100"; -- 4
            when 5 => d1 <= "0100100"; -- 5
            when 6 => d1 <= "0100000"; -- 6
            when 7 => d1 <= "0001111"; -- 7
            when 8 => d1 <= "0000000"; -- 8
            when 9 => d1 <= "0000100"; -- 9
            when others => d1 <= "1111111"; -- blank
        end case;

        -- Display minutes (tens) on 7-segment
        case m_d is
            when 0 => d2 <= "0000001"; -- 0
            when 1 => d2 <= "1001111"; -- 1
            when 2 => d2 <= "0010010"; -- 2
            when 3 => d2 <= "0000110"; -- 3
            when 4 => d2 <= "1001100"; -- 4
            when 5 => d2 <= "0100100"; -- 5
            when others => d2 <= "1111111"; -- blank
        end case;

        -- Display hours (units) on 7-segment
        case h_u is
            when 0 => d3 <= "0000001"; -- 0
            when 1 => d3 <= "1001111"; -- 1
            when 2 => d3 <= "0010010"; -- 2
            when 3 => d3 <= "0000110"; -- 3
            when 4 => d3 <= "1001100"; -- 4
            when 5 => d3 <= "0100100"; -- 5
            when 6 => d3 <= "0100000"; -- 6
            when 7 => d3 <= "0001111"; -- 7
            when 8 => d3 <= "0000000"; -- 8
            when 9 => d3 <= "0000100"; -- 9
            when others => d3 <= "1111111"; -- blank
        end case;

        -- Display hours (tens) on 7-segment
        case h_d is
            when 0 => d4 <= "0000001"; -- 0
            when 1 => d4 <= "1001111"; -- 1
            when 2 => d4 <= "0010010"; -- 2
            when others => d4 <= "1111111"; -- blank
        end case;
    end process;
end hardware;
