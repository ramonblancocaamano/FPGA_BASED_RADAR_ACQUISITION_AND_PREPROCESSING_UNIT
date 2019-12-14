----------------------------------------------------------------------------------
-- @FILE : control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT:
-- TRIGGER[IN]: CONTROL SIGNAL FOR ASCENDING FREQUENCY INDICATION.
-- SWITCH_MODE[IN]: SELECT STANDALONE(ST)/PC MODE.
-- SWITCH_RESOLUTION[IN]: SELECT RESOLUTION ON/OFF. SIGNAL PRE-PROCESSING BASED ON 
--                        SAMPLE WEIGHTING.
-- BUTTON_RECORD[INT]: INITIALIZE ACQUISITION SYSTEM.
-- BUTTON_SAVE[IN]: DUMPS MEMORY(SD) DATA TO THE INTERFACE. NOTE: ONLY AVAILABLE IN 
--                  STANDALONE(ST) MODE.
-- BUTTON__UP[IN]: RESOLUTION HIGHER WEIGHTED SAMPLING.
-- BUTTON_DOWN[IN]: RESOLUTION LOWER WEIGHTED SAMPLING.
-- ARMING[OUT]: RADAR RESET/ENABLE.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
    GENERIC( 
        RES : INTEGER
    );
    PORT(
        rst : IN STD_LOGIC;
        clk: IN STD_LOGIC;
        sw_mode : IN STD_LOGIC;
        sw_resolution : IN STD_LOGIC;
        btn_record : IN STD_LOGIC;
        btn_save : IN STD_LOGIC;        
        btn_up : IN STD_LOGIC;
        btn_down : IN STD_LOGIC;
        en_acquire : OUT STD_LOGIC;
        en_save : OUT STD_LOGIC;
        resolution: OUT INTEGER;
        arming : OUT STD_LOGIC    
    );
END control;


ARCHITECTURE behavioral OF control IS

    SHARED VARIABLE st_reset: BOOLEAN := FALSE;
    SHARED VARIABLE st_arm: BOOLEAN := FALSE;
    SHARED VARIABLE st_rec : BOOLEAN := FALSE;
    SHARED VARIABLE st_save : BOOLEAN := FALSE;
    SHARED VARIABLE st_updown : BOOLEAN := FALSE;
    
    SIGNAL main_en_acquire : STD_LOGIC := '0';
    SIGNAL main_en_save : STD_LOGIC := '0';
    SIGNAL main_resolution: INTEGER := RES;
    SIGNAL main_arming : STD_LOGIC := '0';

BEGIN

      en_acquire <= main_en_acquire;
      en_save <= main_en_save;
      resolution <= main_resolution;
      arming <= main_arming;
  
    p_reset:PROCESS(rst)
        BEGIN
            IF rst = '1' THEN 
                IF st_reset = FALSE THEN            
                    IF main_en_acquire = '1' THEN
                        st_arm := TRUE;
                    END IF;
                    st_rec := FALSE;
                    st_save := FALSE;
                    st_updown := FALSE;
                    main_en_acquire <= '0';
                    main_en_save <= '0';
                    main_resolution <= RES;
                    st_reset := TRUE;
                END IF;
            ELSE 
                st_reset := FALSE;
            END IF;
    END PROCESS p_reset;
    
    p_arming:PROCESS(clk)
        BEGIN
            IF RISING_EDGE(clk) THEN
                IF st_arm = TRUE THEN
                    main_arming <= '1';  
                ELSE
                    main_arming <= '0'; 
                END IF;
                st_arm := FALSE;  
            END IF;
    END PROCESS p_arming;
    
    p_record:PROCESS(clk, btn_record)        
        BEGIN
            IF st_reset = FALSE AND st_save = FALSE AND st_updown = FALSE THEN
                IF RISING_EDGE(clk) THEN
                    IF btn_record = '1' THEN
                        IF st_rec = FALSE THEN  
                            st_arm := TRUE;
                            main_en_acquire <= NOT main_en_acquire;
                            main_en_save <= '0';
                            st_rec := TRUE;
                        END IF;
                    ELSE
                        st_rec := FALSE;
                    END IF;
                END IF; 
            END IF;   
    END PROCESS p_record;
    
    p_save:PROCESS(clk, btn_save) 
        BEGIN
            IF st_reset = FALSE AND st_rec = FALSE AND st_updown = FALSE THEN
                IF sw_mode = '0' THEN
                    IF RISING_EDGE(clk) THEN 
                        IF btn_save = '1' THEN
                            IF st_save = FALSE THEN
                                IF main_en_acquire = '1' THEN
                                    st_arm := TRUE;
                                END IF;
                                main_en_acquire <= '0';
                                main_en_save <= '1';
                                st_save := TRUE;
                            END IF;
                        ELSE
                            st_save := FALSE;  
                        END IF;
                    END IF;
                END IF;
            END IF;        
    END PROCESS p_save;
    
    p_updown:PROCESS(clk, btn_up, btn_down)
        BEGIN
            IF st_reset = FALSE AND st_rec = FALSE AND st_save = FALSE THEN
                IF sw_resolution = '1' THEN
                    IF RISING_EDGE(clk) THEN
                        IF btn_up = '1' OR btn_down = '1' THEN
                            IF st_updown = FALSE THEN
                                IF main_en_acquire = '1' THEN
                                    st_arm := TRUE;
                                END IF;
                                IF btn_up = '1' AND main_resolution < 12 THEN
                                    main_resolution <= main_resolution + 1;
                                ELSIF btn_down = '1' AND main_resolution > 0 THEN
                                    main_resolution <= main_resolution - 1;
                                END IF;
                                main_en_acquire <= '0';
                                st_updown := TRUE;
                            END IF;
                        ELSE
                            st_updown := FALSE;
                        END IF;
                    END IF;
                END IF; 
            END IF;
    END PROCESS p_updown;

END behavioral;
