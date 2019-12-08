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
-- BUTTON_RESOLUTION_UP[IN]: HIGHER WEIGHTED SAMPLING.
-- BUTTON_RESOLUTION_DOWN[IN]: LOWER WEIGHTED SAMPLING.
-- ARMING[OUT]: RADAR RESET/ENABLE.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY control IS
    PORT(
        rst : IN STD_LOGIC;
        clk: IN STD_LOGIC;
        trigger : IN STD_LOGIC;
        sw_mode : IN STD_LOGIC;
        sw_resolution : IN STD_LOGIC;
        btn_record : IN STD_LOGIC;
        btn_save : IN STD_LOGIC;        
        btn_up : IN STD_LOGIC;
        btn_down : IN STD_LOGIC;
        en_acquire : OUT STD_LOGIC;
        en_save : OUT STD_LOGIC;
        arming : OUT STD_LOGIC    
    );
END control;


ARCHITECTURE behavioral OF control IS

    SHARED VARIABLE press_button_record : BOOLEAN := FALSE;
    SHARED VARIABLE press_button_save : BOOLEAN := FALSE;
    SHARED VARIABLE press_button_resolution_up : BOOLEAN := FALSE;
    SHARED VARIABLE press_button_resolution_down : BOOLEAN := FALSE;
    
    SIGNAL acquiring: STD_LOGIC := '0';
    SIGNAL saving: STD_LOGIC := '0';
    SIGNAL enable: STD_LOGIC := '0';

BEGIN

    p0:PROCESS(btn_record)
        
    BEGIN
        
        IF btn_record = '1' AND press_button_record = FALSE THEN
            enable <= '1';
            acquiring <= NOT acquiring;            
        ELSIF  btn_record = '0' THEN
            enable <= '0';
            press_button_record := FALSE;
        ELSE
            press_button_record := TRUE;
        END IF;
        
        en_acquire <= acquiring;
        arming <= enable;
        
    END PROCESS p0;
    
    p1:PROCESS(btn_save)
        
    BEGIN
        
        IF sw_mode = '1' THEN 
            IF btn_save = '1' AND press_button_save = FALSE THEN                
                IF acquiring = '1' THEN
                    enable <= '1';
                    acquiring <= '0';
                END IF;                
                saving <= NOT saving;                     
            ELSIF btn_save = '1' THEN
                press_button_save := TRUE;
            ELSE
                press_button_save := FALSE;
            END IF;
        END IF;
        
        en_acquire <= acquiring;
        en_save <= saving;
        arming <= enable;
           
    END PROCESS p1;
    
    p2:PROCESS(btn_up)
        
    BEGIN
    
        IF sw_resolution = '1' THEN 
            IF btn_up = '1' AND press_button_resolution_up = FALSE THEN
             
            ELSIF btn_up = '1' THEN
                press_button_resolution_up := TRUE;
            ELSE
                press_button_resolution_up := FALSE;
            END IF; 
        END IF;
               
    END PROCESS p2;
    
    p3:PROCESS(btn_down)
        
    BEGIN
    
        IF sw_resolution = '1' THEN 
            IF btn_down = '1' AND press_button_resolution_down = FALSE THEN
             
            ELSIF btn_down = '1' THEN
                press_button_resolution_down := TRUE;
            ELSE
                press_button_resolution_down := FALSE;
            END IF;    
        END IF; 
               
    END PROCESS p3;

END behavioral;
