LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY clock IS
	PORT (
		clk, rst : IN std_logic;
		b1, b2, b3, b4 : IN std_logic; -- Buttons
		d1, d2, d3, d4 : OUT std_logic_vector(6 DOWNTO 0); -- 7-segment display outputs
		check_m_u, check_m_d, check_h_u, check_h_d : OUT INTEGER RANGE 0 TO 9 -- Check time values 	
	);
END clock;

ARCHITECTURE hardware OF clock IS
    
    -- CDB clock
	SIGNAL count_sec : INTEGER RANGE 0 TO 60; -- seconds counter (0 to 59)
	SIGNAL count_clock : INTEGER RANGE 0 TO 9; -- clock cycles counter (0 to 9)

	-- !! Uncomment in production
	SIGNAL m_u : INTEGER RANGE 0 TO 9; -- minutes units (0 to 9)
	SIGNAL m_d : INTEGER RANGE 0 TO 5; -- minutes tens (0 to 5)
	SIGNAL h_u : INTEGER RANGE 0 TO 9; -- hours units (0 to 9)
	SIGNAL h_d : INTEGER RANGE 0 TO 2; -- hours tens (0 to 2)
    
    -- Alarm
	SIGNAL alarm_m_u : INTEGER RANGE 0 TO 9; -- alarm minutes units (0 to 9)
	SIGNAL alarm_m_d : INTEGER RANGE 0 TO 5; -- alarm minutes tens (0 to 5)
	SIGNAL alarm_h_u : INTEGER RANGE 0 TO 9; -- alarm hours units (0 to 9)
	SIGNAL alarm_h_d : INTEGER RANGE 0 TO 2; -- alarm hours tens (0 to 2)
	SIGNAL alarm_led, alarm_active : std_logic := '0';
    
    -- Button debouncing
	SIGNAL b1_last, b2_last, b3_last, b4_last : std_logic := '0'; 
	SIGNAL b1_stable, b2_stable, b3_stable, b4_stable : std_logic := '0';
    
	-- State definitions
	CONSTANT STANDBY : INTEGER := 0;
	CONSTANT SETTING_TIME : INTEGER := 1;
	CONSTANT SETTING_ALARM : INTEGER := 2;
	CONSTANT ALARM_TRIGGERED : INTEGER := 3;
	SIGNAL current_state, next_state : INTEGER RANGE 0 TO 3 := STANDBY;
BEGIN

	-- To debug
	PROCESS(m_u, m_d, h_u, h_d)
	BEGIN
		check_m_u <= m_u;
		check_m_d <= m_d;
		check_h_u <= h_u;
		check_h_d <= h_d;
	END PROCESS;

	-- Main process
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			count_sec <= 0;
			count_clock <= 0;
			m_u <= 0;
			m_d <= 0;
			h_u <= 0;
			h_d <= 0;
			alarm_active <= '0';
			alarm_h_u <= 0;
			alarm_h_d <= 0;
			alarm_m_u <= 0;
			alarm_m_d <= 0;
			alarm_led <= '0';
			current_state <= STANDBY;
		ELSIF rising_edge(clk) THEN
			
            -- State transitions
			current_state <= next_state;
            
			-- Count seconds and increment digits accordingly
			IF count_clock = 9 THEN
				count_sec <= count_sec + 1;
				count_clock <= 0;
				IF count_sec = 59 THEN
					count_sec <= 0;
					IF m_u = 9 THEN
						m_u <= 0;
						IF m_d = 5 THEN
							m_d <= 0;
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
			ELSE
				count_clock <= count_clock + 1;
			END IF;
            
			-- Process states
			CASE current_state IS
            
				WHEN STANDBY =>
					-- change state conditions
					IF b1_stable = '1' THEN
						next_state <= SETTING_TIME;
					ELSIF b4_stable = '1' THEN
						next_state <= SETTING_ALARM;
					ELSE
						next_state <= STANDBY;
					END IF;
					-- alarm trigger
					IF alarm_active = '1' AND h_u = alarm_h_u AND h_d = alarm_h_d AND m_u = alarm_m_u AND m_d = alarm_m_d THEN
						alarm_led <= '1';
						next_state <= ALARM_TRIGGERED;
					END IF;
                    
				WHEN SETTING_TIME =>
					-- increment time
					IF b2 = '1' AND b2_last = '0' THEN
						IF h_d = 2 AND h_u = 3 THEN
							h_d <= 0;
							h_u <= 0;
						ELSIF h_u = 9 THEN
							h_u <= 0;
							h_d <= h_d + 1;
						ELSE
							h_u <= h_u + 1;
						END IF;
					END IF;
					IF b3 = '1' AND b3_last = '0' THEN
						IF m_u = 9 AND m_d = 5 THEN
							m_u <= 0;
							m_d <= 0;
						ELSIF m_u = 9 THEN
							m_u <= 0;
							m_d <= m_d + 1;
						ELSE
							m_u <= m_u + 1;
						END IF;
					END IF;
					-- change state conditions
					IF b4_stable = '1' THEN
						next_state <= STANDBY;
					ELSE
						next_state <= SETTING_TIME;
					END IF;
                    
				WHEN SETTING_ALARM =>
                	-- increment alarm time
					IF b2 = '1' AND b2_last = '0' THEN
						IF alarm_h_d = 2 AND alarm_h_u = 3 THEN
							alarm_h_d <= 0;
							alarm_h_u <= 0;
						ELSIF alarm_h_u = 9 THEN
							alarm_h_u <= 0;
							alarm_h_d <= alarm_h_d + 1;
						ELSE
							alarm_h_u <= alarm_h_u + 1;
						END IF;
					END IF;
                    IF b3 = '1' AND b3_last = '0' THEN
						IF alarm_m_u = 9 AND alarm_m_d = 5 THEN
							alarm_m_u <= 0;
							alarm_m_d <= 0;
						ELSIF alarm_m_u = 9 THEN
							alarm_m_u <= 0;
							alarm_m_d <= alarm_m_d + 1;
						ELSE
							alarm_m_u <= alarm_m_u + 1;
						END IF;
					END IF;
					-- change state conditions
					IF b1_stable = '1' THEN -- exit the alarm setting saving the changes
						alarm_active <= '1';
						next_state <= STANDBY;
					ELSIF b2_stable = '1' THEN -- exit the alarm without setting saving the changes
						alarm_active <= '0';
						next_state <= STANDBY;
					ELSE
						next_state <= SETTING_ALARM;
					END IF;
                    
				WHEN ALARM_TRIGGERED =>
                	-- alarm goes on
					alarm_led <= '1';
					-- change state conditions
					IF b2_stable = '1' THEN
						next_state <= STANDBY;
						alarm_led <= '0';
						alarm_active <= '0';
					ELSE
						next_state <= ALARM_TRIGGERED;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
    
    
	-- Debouncing for buttons
	DEBOUNCE_PROCESS : PROCESS (clk, rst)
		VARIABLE hold_b1_time : INTEGER := 0;
		VARIABLE hold_b2_time : INTEGER := 0;
		VARIABLE hold_b3_time : INTEGER := 0;
		VARIABLE hold_b4_time : INTEGER := 0;
	BEGIN
		IF rst = '1' THEN
			b1_stable <= '0';
			b2_stable <= '0';
			b3_stable <= '0';
			b4_stable <= '0';
			b1_last <= '0';
			b2_last <= '0';
			b3_last <= '0';
			b4_last <= '0';
		ELSIF rising_edge(clk) THEN
        
			b1_last <= b1;
			b2_last <= b2;
			b3_last <= b3;
			b4_last <= b4;
            
            -- button b1
			IF b1 = '1' THEN
            	-- check if button is stable (pressed more than 2s)
				hold_b1_time := hold_b1_time + 1;
				IF hold_b1_time >= 19 THEN
					b1_stable <= '1';
				ELSE
					b1_stable <= '0';
				END IF;
			ELSE
				hold_b1_time := 0;
				b1_stable <= '0';
			END IF;
            
            -- button b2
            IF b2 = '1' THEN
				hold_b2_time := hold_b2_time + 1;
				IF hold_b2_time >= 19 THEN
					b2_stable <= '1';
				ELSE
					b2_stable <= '0';
				END IF;
			ELSE
				hold_b2_time := 0;
				b2_stable <= '0';
			END IF;
            
            -- Button b3
			IF b3 = '1' THEN
				hold_b3_time := hold_b3_time + 1;
				IF hold_b3_time >= 19 THEN
					b3_stable <= '1';
				ELSE
					b3_stable <= '0';
				END IF;
   
			ELSE
				hold_b3_time := 0;
				b3_stable <= '0';
			END IF;
            
            
            -- Button b4
			IF b4 = '1' THEN
				hold_b4_time := hold_b4_time + 1;
				IF hold_b4_time >= 19 THEN
					b4_stable <= '1';
				ELSE
					b4_stable <= '0';
				END IF;
                
			ELSE
				hold_b4_time := 0;
				b4_stable <= '0';
			END IF;
            
            
		END IF;
	END PROCESS DEBOUNCE_PROCESS;
    
    
	-- Logic for output signals
	PROCESS (clk, h_u, h_d, m_u, m_d, alarm_h_u, alarm_h_d, alarm_m_u, alarm_m_d, count_clock)
		BEGIN
			CASE current_state IS
            
				WHEN STANDBY | ALARM_TRIGGERED =>
					-- Minutes units display
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
                    -- Minutes tens display
                    CASE m_d IS
                        WHEN 0 => d2 <= "0000001"; -- 0
                        WHEN 1 => d2 <= "1001111"; -- 1
                        WHEN 2 => d2 <= "0010010"; -- 2
                        WHEN 3 => d2 <= "0000110"; -- 3
                        WHEN 4 => d2 <= "1001100"; -- 4
                        WHEN 5 => d2 <= "0100100"; -- 5
                        WHEN OTHERS => d2 <= "1111111"; -- blank
                    END CASE;
                    -- Hours units display
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
                    -- Hours tens display
                    CASE h_d IS
                        WHEN 0 => d4 <= "0000001"; -- 0
                        WHEN 1 => d4 <= "1001111"; -- 1
                        WHEN 2 => d4 <= "0010010"; -- 2
                        WHEN OTHERS => d4 <= "1111111"; -- blank
                    END CASE;
                    
				WHEN SETTING_ALARM =>
					-- Display alarm time minutes units
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
                    -- Display alarm time minutes tens
                    CASE alarm_m_d IS
                        WHEN 0 => d2 <= "0000001"; -- 0
                        WHEN 1 => d2 <= "1001111"; -- 1
                        WHEN 2 => d2 <= "0010010"; -- 2
                        WHEN 3 => d2 <= "0000110"; -- 3
                        WHEN 4 => d2 <= "1001100"; -- 4
                        WHEN 5 => d2 <= "0100100"; -- 5
                        WHEN OTHERS => d2 <= "1111111"; -- blank
                    END CASE;
                    -- Display alarm time hours units
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
                    -- Display alarm time hours tens
                    CASE alarm_h_d IS
                        WHEN 0 => d4 <= "0000001"; -- 0
                        WHEN 1 => d4 <= "1001111"; -- 1
                        WHEN 2 => d4 <= "0010010"; -- 2
                        WHEN OTHERS => d4 <= "1111111"; -- blank
                    END CASE;
                    
				WHEN SETTING_TIME =>
                	-- Blinking
					IF count_clock >= 5 THEN
						d1 <= "1111111";
						d2 <= "1111111";
						d3 <= "1111111";
						d4 <= "1111111";
					ELSE
						-- Minutes units display
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
						-- Minutes tens display
						CASE m_d IS
							WHEN 0 => d2 <= "0000001"; -- 0
							WHEN 1 => d2 <= "1001111"; -- 1
							WHEN 2 => d2 <= "0010010"; -- 2
							WHEN 3 => d2 <= "0000110"; -- 3
							WHEN 4 => d2 <= "1001100"; -- 4
							WHEN 5 => d2 <= "0100100"; -- 5
							WHEN OTHERS => d2 <= "1111111"; -- blank
						END CASE;
						-- Hours units display
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
						-- Hours tens display
						CASE h_d IS
							WHEN 0 => d4 <= "0000001"; -- 0
							WHEN 1 => d4 <= "1001111"; -- 1
							WHEN 2 => d4 <= "0010010"; -- 2
							WHEN OTHERS => d4 <= "1111111"; -- blank
						END CASE;
					END IF;
				WHEN OTHERS =>
					-- Default case for other states (if needed)
					d1 <= "1111111";
					d2 <= "1111111";
					d3 <= "1111111";
					d4 <= "1111111";
			END CASE;
		END PROCESS;
END hardware;
