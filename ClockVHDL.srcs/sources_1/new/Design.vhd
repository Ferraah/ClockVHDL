LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
ENTITY clock IS
	PORT (
		clk, rst : IN std_logic;
		b1, b2, b3, b4 : IN std_logic;
		d1, d2, d3, d4 : OUT std_logic_vector(6 DOWNTO 0)
	);
END clock;
ARCHITECTURE hardware OF clock IS
	SIGNAL count_sec : INTEGER RANGE 0 TO 60; -- seconds counter (0 to 59)
	SIGNAL count_clock : INTEGER RANGE 0 TO 9; -- clock cycles counter (0 to 9)
	SIGNAL m_u : INTEGER RANGE 0 TO 9; -- minutes units (0 to 9)
	SIGNAL m_d : INTEGER RANGE 0 TO 5; -- minutes tens (0 to 5)
	SIGNAL h_u : INTEGER RANGE 0 TO 9; -- hours units (0 to 9)
	SIGNAL h_d : INTEGER RANGE 0 TO 2; -- hours tens (0 to 2)
	SIGNAL SETTING_MODE : BOOLEAN := false;
	SIGNAL SETTING_ALARM_MODE : BOOLEAN := false;

	SIGNAL CURRENT_DIGIT : INTEGER RANGE 0 TO 3; -- digit selection for setting mode
	SIGNAL b2_pressed : BOOLEAN := false;
	SIGNAL b3_pressed : BOOLEAN := false;
	SIGNAL alarm_active : BOOLEAN := false;
	SIGNAL alarm_h_u : INTEGER RANGE 0 TO 9;
	SIGNAL alarm_h_d : INTEGER RANGE 0 TO 2;
	SIGNAL alarm_m_u : INTEGER RANGE 0 TO 9;
	SIGNAL alarm_m_d : INTEGER RANGE 0 TO 5;
	SIGNAL alarm_led : std_logic := '0';
BEGIN
	-- Main clock process
	p_clock : PROCESS (clk, rst)
		VARIABLE hold_b1_time : INTEGER := 0;
		VARIABLE hold_b4_time : INTEGER := 0;
	BEGIN
		-- RESET
		IF rst = '1' THEN
			count_sec <= 0;
			count_clock <= 0;
			m_u <= 0;
			m_d <= 0;
			h_u <= 0;
			h_d <= 0;
			SETTING_MODE <= false;
			SETTING_ALARM_MODE <= false;
			CURRENT_DIGIT <= 0;
			d1 <= "0000001";
			d2 <= "0000001";
			d3 <= "0000001";
			d4 <= "0000001";
			b2_pressed <= false;
			b3_pressed <= false;
			alarm_active <= false;
			alarm_h_u <= 0;
			alarm_h_d <= 0;
			alarm_m_u <= 0;
			alarm_m_d <= 0;
			alarm_led <= '0';
		ELSIF rising_edge(clk) THEN
        
			-- Alarm check
			IF alarm_active AND SETTING_ALARM_MODE = false AND SETTING_MODE = false AND h_u = alarm_h_u AND h_d = alarm_h_d AND m_u = alarm_m_u AND m_d = alarm_m_d THEN
				alarm_led <= '1';
			END IF;
            
            -- Set the alarm off
            IF b2 = '1' AND alarm_led <= '1' and b2_pressed = false THEN
                alarm_led <= '0';
                alarm_active <= false;
            END IF;
            
			-- If the button has been held for some time
			-- and now they are not, release the lock
			IF b2_pressed AND b2 = '0' THEN
				b2_pressed <= false;
			END IF;
			IF b3_pressed AND b3 = '0' THEN
				b3_pressed <= false;
			END IF;
 
			-- Check for button 1 press to toggle SETTING_MODE
			IF b1 = '1' THEN
				hold_b1_time := hold_b1_time + 1;
				IF hold_b1_time >= 20 THEN -- simulating a 2 seconds hold
					SETTING_MODE <= NOT SETTING_MODE;
					CURRENT_DIGIT <= 0;
					-- if I am in the setting alarm mode, I exit it.
					IF SETTING_ALARM_MODE = true
					 THEN
					 SETTING_ALARM_MODE <= false;
					 END IF;
                 END IF;
             ELSE hold_b1_time := 0;
			 END IF;
             
			 -- Check for button 4 press to toggle SETTING_MODE
			 IF b4 = '1' THEN
				hold_b4_time := hold_b4_time + 1;
				IF hold_b4_time >= 20 THEN -- simulating a 2 seconds hold
					SETTING_ALARM_MODE <= NOT SETTING_ALARM_MODE;
					CURRENT_DIGIT <= 0;
					-- if I am in the setting mode, I exit it.
					IF SETTING_MODE = true
						THEN
						SETTING_MODE <= false;
						END IF;
                END IF;
				ELSE hold_b4_time := 0;
			END IF;

			-- count seconds and increment digits accordingly
			IF count_clock = 9 THEN
				count_sec <= count_sec + 1;
				count_clock <= 0;
				-- After 59 seconds, update minutes
				IF count_sec = 59 THEN
					count_sec <= 0;
                    -- Increment minutes units
                    IF m_u = 9 THEN
                        m_u <= 0;
                        IF m_d = 5 THEN
                            m_d <= 0;
                            -- Increment hours units with wrap-around
                            IF h_d = 0 AND h_u = 9 THEN
                                h_d <= 1;
                                h_u <= 0;
                            ELSIF h_d = 1 AND h_u = 9 THEN
                                h_d <= 2;
                                h_u <= 0;
                            ELSIF h_d = 2 AND h_u = 3 THEN
                                h_d <= 0;
                                h_u <= 0;
                            ELSE
                                h_u <= h_u + 1;
                            END IF;
                        ELSE
                            m_d <= m_d + 1;
                        END IF;
                    ELSE
                        m_u <= m_u + 1;
                    END IF;
                END IF;
			ELSE count_clock <= count_clock + 1;
            END IF;
					
            -- Setting mode: adjust the current digit selected by `CURRENT_DIGIT`
            IF SETTING_MODE THEN
                -- Blinking functionality: toggle every 5 clock cycles
                IF SETTING_MODE AND count_clock = 0 THEN
                    d1 <= (OTHERS => '1'); -- Blank d1 to simulate blinking
                    d2 <= (OTHERS => '1'); -- Blank d2
                    d3 <= (OTHERS => '1'); -- Blank d3
                    d4 <= (OTHERS => '1'); -- Blank d4
                END IF;
                IF b2 = '1' AND b2_pressed = false THEN
                    b2_pressed <= true;
                    CURRENT_DIGIT <= (CURRENT_DIGIT + 1) MOD 3;
                END IF;
                IF b3 = '1' AND b3_pressed = false THEN
                    b3_pressed <= true;
                    CASE CURRENT_DIGIT IS
                        WHEN 0 => -- Incrementare ore
                            IF h_d = 2 AND h_u = 3 THEN
                                h_d <= 0; -- Prevenire >23
                                h_u <= 0;
                            ELSIF h_u = 9 THEN
                                h_u <= 0;
                                h_d <= h_d + 1;
                            ELSE
                                h_u <= h_u + 1;
                            END IF;
                        WHEN 1 => -- Incrementare minuti
                            IF m_u = 9 AND m_d = 5 THEN
                                m_u <= 0;
                                m_d <= 0;
                            ELSIF m_u = 9 THEN
                                m_u <= 0;
                                m_d <= m_d + 1;
                            ELSE
                                m_u <= m_u + 1;
                            END IF;
                        WHEN 2 => -- Resettare secondi e decimi
                            count_sec <= 0;
                            count_clock <= 0;
                        WHEN OTHERS => 
                            NULL;
                    END CASE;
                END IF;
            END IF;


            IF SETTING_ALARM_MODE THEN
            	alarm_active <= true;
                -- Use b2 to select between alarm hour and minute
                IF b2 = '1' AND b2_pressed = false THEN
                    b2_pressed <= true;
                    CURRENT_DIGIT <= (CURRENT_DIGIT + 1) MOD 2; -- 0 for hour, 1 for minute
                END IF;
                -- Use b3 to increment the selected alarm time
                IF b3 = '1' AND b3_pressed = false THEN
                    b3_pressed <= true;
                    CASE CURRENT_DIGIT IS
                        WHEN 0 => -- Increment alarm hour
                            IF alarm_h_d = 2 AND alarm_h_u = 3 THEN
                                alarm_h_d <= 0; -- Prevent >23
                                alarm_h_u <= 0;
                            ELSIF alarm_h_u = 9 THEN
                                alarm_h_u <= 0;
                                alarm_h_d <= alarm_h_d + 1;
                            ELSE
                                alarm_h_u <= alarm_h_u + 1;
                            END IF;
                        WHEN 1 => -- Increment alarm minute
                            IF alarm_m_u = 9 AND alarm_m_d = 5 THEN
                                alarm_m_u <= 0;
                                alarm_m_d <= 0;
                            ELSIF alarm_m_u = 9 THEN
                                alarm_m_u <= 0;
                                alarm_m_d <= alarm_m_d + 1;
                            ELSE
                                alarm_m_u <= alarm_m_u + 1;
                            END IF;
                        WHEN OTHERS => 
                            NULL;
                    END CASE;
                END IF;
                -- Use b1 to deactivate the alarm and exit setting mode
                IF b1 = '1' THEN
                    alarm_active <= false;
                    alarm_h_u <= 0;
                    alarm_h_d <= 0;
                    alarm_m_u <= 0;
                    alarm_m_d <= 0;
                    SETTING_ALARM_MODE <= false;
                END IF;
            END IF;
        END IF;
	END PROCESS;

	-- 7-Segment Display process with conditional blinking
    pout : PROCESS (h_u, h_d, m_u, m_d, alarm_h_u, alarm_h_d, alarm_m_u, alarm_m_d, count_clock, SETTING_MODE, SETTING_ALARM_MODE, CURRENT_DIGIT)
    BEGIN
        IF SETTING_ALARM_MODE THEN
            -- Visualizza l'ora dell'allarme
            CASE alarm_m_u IS
                WHEN 0 => d1 <= "0000001"; -- 0
                WHEN 1 => d1 <= "1001111"; -- 1
                WHEN 2 => d1 <= "0010010"; -- 2
                WHEN 3 => d1 <= "0000110"; -- 3
                WHEN 4 => d1 <= "1001100"; -- 4
                WHEN 5 => d1 <= "0100100"; -- 5
                WHEN 6 => d1 <= "0100000"; -- 6
                WHEN 7 => d1 <= "0001111"; -- 7
                WHEN 8 => d1 <= "0000000"; -- 8
                WHEN 9 => d1 <= "0000100"; -- 9
                WHEN OTHERS => d1 <= "1111111"; -- blank
            END CASE;
            CASE alarm_m_d IS
                WHEN 0 => d2 <= "0000001"; -- 0
                WHEN 1 => d2 <= "1001111"; -- 1
                WHEN 2 => d2 <= "0010010"; -- 2
                WHEN 3 => d2 <= "0000110"; -- 3
                WHEN 4 => d2 <= "1001100"; -- 4
                WHEN 5 => d2 <= "0100100"; -- 5
                WHEN OTHERS => d2 <= "1111111"; -- blank
            END CASE;
            CASE alarm_h_u IS
                WHEN 0 => d3 <= "0000001"; -- 0
                WHEN 1 => d3 <= "1001111"; -- 1
                WHEN 2 => d3 <= "0010010"; -- 2
                WHEN 3 => d3 <= "0000110"; -- 3
                WHEN 4 => d3 <= "1001100"; -- 4
                WHEN 5 => d3 <= "0100100"; -- 5
                WHEN 6 => d3 <= "0100000"; -- 6
                WHEN 7 => d3 <= "0001111"; -- 7
                WHEN 8 => d3 <= "0000000"; -- 8
                WHEN 9 => d3 <= "0000100"; -- 9
                WHEN OTHERS => d3 <= "1111111"; -- blank
            END CASE;
            CASE alarm_h_d IS
                WHEN 0 => d4 <= "0000001"; -- 0
                WHEN 1 => d4 <= "1001111"; -- 1
                WHEN 2 => d4 <= "0010010"; -- 2
                WHEN OTHERS => d4 <= "1111111"; -- blank
            END CASE;
        ELSE
            -- Visualizza l'ora corrente
            IF NOT SETTING_MODE OR (SETTING_MODE AND count_clock < 5) THEN
                CASE m_u IS
                    WHEN 0 => d1 <= "0000001"; -- 0
                    WHEN 1 => d1 <= "1001111"; -- 1
                    WHEN 2 => d1 <= "0010010"; -- 2
                    WHEN 3 => d1 <= "0000110"; -- 3
                    WHEN 4 => d1 <= "1001100"; -- 4
                    WHEN 5 => d1 <= "0100100"; -- 5
                    WHEN 6 => d1 <= "0100000"; -- 6
                    WHEN 7 => d1 <= "0001111"; -- 7
                    WHEN 8 => d1 <= "0000000"; -- 8
                    WHEN 9 => d1 <= "0000100"; -- 9
                    WHEN OTHERS => d1 <= "1111111"; -- blank
                END CASE;
                CASE m_d IS
                    WHEN 0 => d2 <= "0000001"; -- 0
                    WHEN 1 => d2 <= "1001111"; -- 1
                    WHEN 2 => d2 <= "0010010"; -- 2
                    WHEN 3 => d2 <= "0000110"; -- 3
                    WHEN 4 => d2 <= "1001100"; -- 4
                    WHEN 5 => d2 <= "0100100"; -- 5
                    WHEN OTHERS => d2 <= "1111111"; -- blank
                END CASE;
                CASE h_u IS
                    WHEN 0 => d3 <= "0000001"; -- 0
                    WHEN 1 => d3 <= "1001111"; -- 1
                    WHEN 2 => d3 <= "0010010"; -- 2
                    WHEN 3 => d3 <= "0000110"; -- 3
                    WHEN 4 => d3 <= "1001100"; -- 4
                    WHEN 5 => d3 <= "0100100"; -- 5
                    WHEN 6 => d3 <= "0100000"; -- 6
                    WHEN 7 => d3 <= "0001111"; -- 7
                    WHEN 8 => d3 <= "0000000"; -- 8
                    WHEN 9 => d3 <= "0000100"; -- 9
                    WHEN OTHERS => d3 <= "1111111"; -- blank
                END CASE;
                CASE h_d IS
                    WHEN 0 => d4 <= "0000001"; -- 0
                    WHEN 1 => d4 <= "1001111"; -- 1
                    WHEN 2 => d4 <= "0010010"; -- 2
                    WHEN OTHERS => d4 <= "1111111"; -- blank
                END CASE;
            ELSE
                -- Blank selected digit if blinking is active
                IF CURRENT_DIGIT = 0 THEN d1 <= "1111111";
                ELSIF CURRENT_DIGIT = 1 THEN d2 <= "1111111";
                ELSIF CURRENT_DIGIT = 2 THEN d3 <= "1111111";
                ELSIF CURRENT_DIGIT = 3 THEN d4 <= "1111111";
                END IF;
            END IF;
        END IF;
    END PROCESS;
END hardware;
