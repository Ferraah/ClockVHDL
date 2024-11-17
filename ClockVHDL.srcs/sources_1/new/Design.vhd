LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY Main IS
	PORT (
		clk, rst : IN std_logic;
		b1, b2, b3, b4 : IN std_logic; -- Buttons
		segments : OUT std_logic_vector(6 DOWNTO 0); -- 7-segment display
		anode : OUT std_logic_vector(3 DOWNTO 0); -- Anode display
		check_m_u, check_m_d, check_h_u, check_h_d : OUT INTEGER RANGE 0 TO 9; -- Check time values 	
		check_alarm_active : OUT std_logic; -- Check alarm active signal
		alarm_led : OUT std_logic; -- Alarm LED
		led_setting_time : OUT std_logic; -- Alarm LED
		led_setting_alarm : OUT std_logic -- Alarm LED
	);
END Main;

ARCHITECTURE hardware OF Main IS
    
    component ClockDividerSeconds
        Port (
            clk_in  : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            clk_out : out STD_LOGIC
        );
    end component;

	component ClockDividerDisplay
	Port (
		clk_in  : in  STD_LOGIC;
		reset   : in  STD_LOGIC;
		clk_out : out STD_LOGIC
	);
	end component;
	
	component Display
	PORT (
		clk : in std_logic;
		rst : in std_logic;
		m_u : in INTEGER RANGE 0 TO 9; -- minutes units (0 to 9)
		m_d : in INTEGER RANGE 0 TO 5; -- minutes tens (0 to 5)
		h_u : in INTEGER RANGE 0 TO 9; -- hours units (0 to 9)
		h_d : in INTEGER RANGE 0 TO 2; -- hours tens (0 to 2)
		alarm_m_u : in INTEGER RANGE 0 TO 9; -- alarm minutes units (0 to 9)
		alarm_m_d : in INTEGER RANGE 0 TO 5; -- alarm minutes tens (0 to 5)
		alarm_h_u : in INTEGER RANGE 0 TO 9; -- alarm hours units (0 to 9)
		alarm_h_d : in INTEGER RANGE 0 TO 2; -- alarm hours tens (0 to 2)
		current_state : in INTEGER RANGE 0 TO 3;
		segments : out std_logic_vector(6 downto 0);
		anode : out std_logic_vector(3 downto 0)
	);
	end component;

    -- Signal to connect to the clock divider output
    signal clk_10Hz : STD_LOGIC;
    signal clk_10KHz : STD_LOGIC;

    
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
	SIGNAL alarm_active : std_logic := '0';
    
    -- Button debouncing
	SIGNAL b2_last, b3_last : std_logic := '0'; 
	SIGNAL b1_stable, b3_stable, b4_stable : std_logic := '0';
    
	SIGNAL hold_b1_time, hold_b2_time, hold_b3_time, hold_b4_time : INTEGER RANGE 0 TO 19 := 0;
	
	-- Alarm LED
	-- State definitions
	CONSTANT STANDBY : INTEGER := 0;
	CONSTANT SETTING_TIME : INTEGER := 1;
	CONSTANT SETTING_ALARM : INTEGER := 2;
	CONSTANT ALARM_TRIGGERED : INTEGER := 3;
	SIGNAL current_state, next_state : INTEGER RANGE 0 TO 3 := STANDBY;
	
BEGIN

    -- Instantiate the clock divider
    ClockDividerSeconds_inst : ClockDividerSeconds
        port map (
            clk_in  => clk,     -- Connect input clock
            reset   => rst,      -- Connect reset signal
            clk_out => clk_10Hz -- Connect output clock
        );

	-- Instantiate the clock divider
	ClockDividerDisplay_inst : ClockDividerDisplay
	port map (
		clk_in  => clk,     -- Connect input clock
		reset   => rst,      -- Connect reset signal
		clk_out => clk_10KHz -- Connect output clock
	);
    
	Display_inst : Display
	PORT MAP (
		clk => clk_10KHz,
		rst => rst,
		m_u => m_u,
		m_d => m_d,
		h_u => h_u,
		h_d => h_d,
		alarm_m_u => alarm_m_u,
		alarm_m_d => alarm_m_d,
		alarm_h_u => alarm_h_u,
		alarm_h_d => alarm_h_d,
		current_state => current_state,
		segments => segments,
		anode => anode
	);

	-- To debug
	PROCESS(m_u, m_d, h_u, h_d, alarm_active)
	BEGIN
		check_m_u <= m_u;
		check_m_d <= m_d;
		check_h_u <= h_u;
		check_h_d <= h_d;
		check_alarm_active <= alarm_active;
	END PROCESS;
	
	-- Main process
	PROCESS (clk_10hz, rst)
	BEGIN
		IF rst = '1' THEN
			count_sec <= 0;
			count_clock <= 0;
			m_u <= 0;
			m_d <= 0;
			h_u <= 0;
			h_d <= 0;
			alarm_active <= '0';
			alarm_led <= '0';
			led_setting_time <= '0';
			led_setting_alarm <= '0';
			alarm_h_u <= 0;
			alarm_h_d <= 0;
			alarm_m_u <= 0;
			alarm_m_d <= 0;
			current_state <= STANDBY;
		ELSIF rising_edge(clk_10hz) THEN
			
            -- State transitions
			--current_state <= next_state;
            
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
					led_setting_time <= '0';
					led_setting_alarm <= '0';
					-- change state conditions
					IF b1_stable = '1' THEN
						current_state <= SETTING_TIME;
					ELSIF b3_stable = '1' THEN
						current_state <= SETTING_ALARM;
					ELSE
						current_state <= STANDBY;
					END IF;
					-- alarm trigger
					IF alarm_active = '1' AND h_u = alarm_h_u AND h_d = alarm_h_d AND m_u = alarm_m_u AND m_d = alarm_m_d THEN
						alarm_led <= '1';
						current_state <= ALARM_TRIGGERED;
					END IF;
                    
				WHEN SETTING_TIME =>
					led_setting_time <= '1';
					led_setting_alarm <= '0';
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
						current_state <= STANDBY;
					ELSE
						current_state <= SETTING_TIME;
					END IF;
                    
				WHEN SETTING_ALARM =>
                	-- increment alarm time
					led_setting_time <= '0';
					led_setting_alarm <= '1';
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
					IF b4_stable = '1' THEN -- exit the alarm setting saving the changes
						alarm_active <= '1';
						current_state <= STANDBY;
					ELSIF b1_stable = '1' THEN -- exit the alarm without setting saving the changes
						alarm_active <= '0';
						current_state <= STANDBY;
					ELSE
						current_state <= SETTING_ALARM;
					END IF;
                    
				WHEN ALARM_TRIGGERED =>
                	-- alarm goes on
					led_setting_time <= '0';
					led_setting_alarm <= '0';
					alarm_led <= '1';
					-- change state conditions
					IF b4_stable = '1' THEN
						current_state <= STANDBY;
						alarm_led <= '0';
						alarm_active <= '0';
					ELSE
						current_state <= ALARM_TRIGGERED;
					END IF;
			END CASE;
		END IF;
	END PROCESS;
    
    
	-- Debouncing for buttons
	DEBOUNCE_PROCESS : PROCESS (clk_10hz, rst)
		
	BEGIN
		IF rst = '1' THEN
			b1_stable <= '0';
			b3_stable <= '0';
			b4_stable <= '0';
			b2_last <= '0';
			b3_last <= '0';
		ELSIF rising_edge(clk_10hz) THEN
        
			b2_last <= b2;
			b3_last <= b3;
            
            
            -- button b1
			IF b1 = '1' THEN
            	-- check if button is stable (pressed more than 2s)
				IF hold_b1_time = 19 THEN
				hold_b1_time <= 0;
				b1_stable <= '1';
				ELSE
					hold_b1_time <= hold_b1_time + 1;
					b1_stable <= '0';
				END IF;
			ELSE
				b1_stable <= '0';
			END IF;
            
            -- Not used
--            -- button b2
--            IF b2 = '1' THEN
--				-- check if button is stable (pressed more than 2s)
--				IF hold_b2_time = 19 THEN
--				hold_b2_time <= 0;
--				b2_stable <= '1';
--				ELSE
--					hold_b2_time <= hold_b2_time + 1;
--					b2_stable <= '0';
--				END IF;
--			ELSE
--				b2_stable <= '0';
--			END IF;
            
            -- Button b3
			IF b3 = '1' THEN
				-- check if button is stable (pressed more than 2s)
				IF hold_b3_time = 19 THEN
				hold_b3_time <= 0;
				b3_stable <= '1';
				ELSE
					hold_b3_time <= hold_b3_time + 1;
					b3_stable <= '0';
				END IF;
			ELSE
				b3_stable <= '0';
			END IF;
            
            
            -- Button b4
			IF b4 = '1' THEN
				-- check if button is stable (pressed more than 2s)
				IF hold_b4_time = 19 THEN
				hold_b4_time <= 0;
				b4_stable <= '1';
				ELSE
					hold_b4_time <= hold_b4_time + 1;
					b4_stable <= '0';
				END IF;
			ELSE
				b4_stable <= '0';
			END IF;
            
            
		END IF;
	END PROCESS DEBOUNCE_PROCESS;
    
    
END hardware;
