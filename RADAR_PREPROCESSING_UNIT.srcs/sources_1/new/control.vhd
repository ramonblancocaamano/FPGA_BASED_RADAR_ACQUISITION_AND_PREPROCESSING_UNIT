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

    SHARED VARIABLE rec : BOOLEAN := FALSE;
    SHARED VARIABLE save : BOOLEAN := FALSE;
    SHARED VARIABLE up : BOOLEAN := FALSE;
    SHARED VARIABLE down : BOOLEAN := FALSE;
    
    SIGNAL main_resolution: INTEGER := RES;
    SIGNAL main_en_acquire : STD_LOGIC := '0';
    SIGNAL main_en_save : STD_LOGIC := '0';
    SIGNAL main_arming : STD_LOGIC := '0';

BEGIN

      resolution <= main_resolution;
      en_acquire <= main_en_acquire;
      en_save <= main_en_save;
      arming <= main_arming;
  
    reset:PROCESS(rst)
        BEGIN
            IF rst = '1' THEN
                rec := FALSE;
                save := FALSE;
                up := FALSE;
                down := FALSE;
                main_en_acquire <= '0';
                main_en_save <= '0';
                main_arming <= '0';

            END IF;
    END PROCESS reset;

    p0:PROCESS(clk, btn_record)        
        BEGIN
            IF RISING_EDGE(clk) THEN         
                IF btn_record = '1' AND rec = FALSE then
                    rec := TRUE;  
                    main_en_acquire <= NOT main_en_acquire;
                    main_arming <= '1';                              
                ELSIF  btn_record = '0' THEN
                    rec := FALSE;  
                    main_arming <= '0';                     
                END IF;
            END IF;     
    END PROCESS p0;
    
    p1:PROCESS(clk, btn_save) 
        BEGIN
            IF sw_mode = '0' THEN
                save := FALSE;
                main_en_save <= '0';
            ELSIF RISING_EDGE(clk) THEN 
                IF btn_save = '1' AND save = FALSE then
                    save := TRUE;
                    main_en_save <= '1';
                    IF main_en_acquire = '1' THEN
                        main_en_acquire <= '0';
                        main_arming <= '1'; 
                    END IF;  
                ELSIF btn_save = '0' THEN
                    save := FALSE;
                    IF main_arming = '1' THEN
                        main_arming <= '0'; 
                    END IF;
                END IF;
            END IF;
    END PROCESS p1;
    
    p2:PROCESS(clk, btn_up)
        BEGIN
            IF sw_resolution = '1' THEN 
                up := FALSE;
            ELSIF RISING_EDGE(clk) THEN 
                IF btn_up = '1' AND up = FALSE AND main_resolution < 12  THEN
                    main_resolution <= main_resolution + 1;
                    IF main_en_acquire = '1' THEN
                        main_en_acquire <= '0';
                        main_arming <= '1'; 
                    END IF; 
                ELSIF btn_up = '0' THEN
                    up := TRUE;
                    IF main_arming = '1' THEN
                        main_arming <= '0'; 
                    END IF;
                END IF; 
            END IF;
    END PROCESS p2;
    
    p3:PROCESS(clk, btn_down)
        BEGIN
            IF sw_resolution = '1' THEN 
                down := FALSE;
            ELSIF RISING_EDGE(clk) THEN 
                IF btn_down = '1' AND down = FALSE AND main_resolution > 0  THEN
                    main_resolution <= main_resolution - 1;
                    IF main_en_acquire = '1' THEN
                        main_en_acquire <= '0';
                        main_arming <= '1'; 
                    END IF; 
                ELSIF btn_down = '0' THEN
                    down := TRUE;
                    IF main_arming = '1' THEN
                        main_arming <= '0'; 
                    END IF;
                END IF; 
            END IF;
    END PROCESS p3;

END behavioral;
