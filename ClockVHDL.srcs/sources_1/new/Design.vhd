LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
ENTITY clock IS
	PORT (
		clk, rst       : IN std_logic;
		b1, b2, b3, b4 : IN std_logic;
		d1, d2, d3, d4 : OUT std_logic_vector(6 DOWNTO 0)
	);
END clock;
ARCHITECTURE hardware OF clock IS
	SIGNAL count_sec     : INTEGER RANGE 0 TO 59; -- seconds counter (0 to 59)
	SIGNAL count_clock   : INTEGER RANGE 0 TO 9; -- clock cycles counter (0 to 9)
	SIGNAL m_u           : INTEGER RANGE 0 TO 9; -- minutes units (0 to 9)
	SIGNAL m_d           : INTEGER RANGE 0 TO 5; -- minutes tens (0 to 5)
	SIGNAL h_u           : INTEGER RANGE 0 TO 9; -- hours units (0 to 9)
	SIGNAL h_d           : INTEGER RANGE 0 TO 2; -- hours tens (0 to 2)
	SIGNAL SETTING_MODE  : BOOLEAN := false;
	SIGNAL CURRENT_DIGIT : INTEGER RANGE 0 TO 3; -- digit selection for setting mode
	SIGNAL b2_pressed    : BOOLEAN := false;
	SIGNAL b3_pressed    : BOOLEAN := false;
BEGIN
	-- Main clock process
	p_clock               : PROCESS (clk, rst)
		VARIABLE hold_b1_time : INTEGER := 0;
	BEGIN
		-- RESET
		IF rst = '1' THEN
			count_sec   <= 0;
			count_clock <= 0;
			m_u         <= 0;
			m_d         <= 0;
			h_u         <= 0;
			h_d         <= 0;
			hold_b1_time := 0;
			SETTING_MODE  <= false;
			CURRENT_DIGIT <= 0;
		ELSIF rising_edge(clk) THEN
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
					SETTING_MODE  <= NOT SETTING_MODE;
					CURRENT_DIGIT <= 0;
				END IF;
			ELSE
				hold_b1_time := 0;
			END IF;
            
			-- count seconds and increment digits accordingly
			IF count_clock = 9 THEN
				count_sec   <= count_sec + 1;
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
			ELSE
				count_clock <= count_clock + 1;
			END IF;
            
			-- Setting mode: adjust the current digit selected by `CURRENT_DIGIT`
			IF SETTING_MODE THEN
				IF b2 = '1' AND b2_pressed = false THEN
					b2_pressed    <= true;
					CURRENT_DIGIT <= (CURRENT_DIGIT + 1) MOD 4;
				END IF;
				IF b3 = '1' AND b3_pressed = false THEN
					b3_pressed <= true;
					CASE CURRENT_DIGIT IS
						WHEN 0 => -- Setting minutes units
							IF m_u = 9 THEN
								m_u <= 0;
							ELSE
								m_u <= m_u + 1;
							END IF;
						WHEN 1 => -- Setting minutes decimals
							IF m_d = 5 THEN
								m_d <= 0;
							ELSE
								m_d <= m_d + 1;
							END IF;
						WHEN 2 => -- Setting hours units
							IF h_d = 2 AND h_u = 3 THEN
								h_d <= 0; -- Prevent >23
								h_u <= h_u + 1;
							ELSIF h_u = 9 THEN
								h_u <= 0;
							ELSE
								h_u <= h_u + 1;
							END IF;
						WHEN 3 => -- Setting hours decimals
							IF h_d = 2 THEN
								h_d <= 0;
							ELSIF h_d = 1 THEN
								IF h_u > 3 THEN
									h_u <= 0;
								END IF; -- Prevent >23
								h_d <= 2;
							ELSE
								h_d <= 1;
							END IF;
						WHEN OTHERS =>
							NULL;
					END CASE;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	-- 7-Segment Display process
	pout : PROCESS (h_u, h_d, m_u, m_d)
	BEGIN
		-- Display minutes (units) on 7-segment
		CASE m_u IS
			WHEN 0 => d1      <= "0000001"; -- 0
			WHEN 1 => d1      <= "1001111"; -- 1
			WHEN 2 => d1      <= "0010010"; -- 2
			WHEN 3 => d1      <= "0000110"; -- 3
			WHEN 4 => d1      <= "1001100"; -- 4
			WHEN 5 => d1      <= "0100100"; -- 5
			WHEN 6 => d1      <= "0100000"; -- 6
			WHEN 7 => d1      <= "0001111"; -- 7
			WHEN 8 => d1      <= "0000000"; -- 8
			WHEN 9 => d1      <= "0000100"; -- 9
			WHEN OTHERS => d1 <= "1111111"; -- blank
		END CASE;
		-- Display minutes (tens) on 7-segment
		CASE m_d IS
			WHEN 0 => d2      <= "0000001"; -- 0
			WHEN 1 => d2      <= "1001111"; -- 1
			WHEN 2 => d2      <= "0010010"; -- 2
			WHEN 3 => d2      <= "0000110"; -- 3
			WHEN 4 => d2      <= "1001100"; -- 4
			WHEN 5 => d2      <= "0100100"; -- 5
			WHEN OTHERS => d2 <= "1111111"; -- blank
		END CASE;
		-- Display hours (units) on 7-segment
		CASE h_u IS
			WHEN 0 => d3      <= "0000001"; -- 0
			WHEN 1 => d3      <= "1001111"; -- 1
			WHEN 2 => d3      <= "0010010"; -- 2
			WHEN 3 => d3      <= "0000110"; -- 3
			WHEN 4 => d3      <= "1001100"; -- 4
			WHEN 5 => d3      <= "0100100"; -- 5
			WHEN 6 => d3      <= "0100000"; -- 6
			WHEN 7 => d3      <= "0001111"; -- 7
			WHEN 8 => d3      <= "0000000"; -- 8
			WHEN 9 => d3      <= "0000100"; -- 9
			WHEN OTHERS => d3 <= "1111111"; -- blank
		END CASE;
		-- Display hours (tens) on 7-segment
		CASE h_d IS
			WHEN 0 => d4      <= "0000001"; -- 0
			WHEN 1 => d4      <= "1001111"; -- 1
			WHEN 2 => d4      <= "0010010"; -- 2
			WHEN OTHERS => d4 <= "1111111"; -- blank
		END CASE;
	END PROCESS;
END hardware;
