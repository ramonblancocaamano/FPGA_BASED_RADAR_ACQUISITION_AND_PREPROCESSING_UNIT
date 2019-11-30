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
        trigger : IN STD_LOGIC;
        switch_mode : IN STD_LOGIC;
        switch_resolution : IN STD_LOGIC;
        button_record : IN STD_LOGIC;
        button_save : IN STD_LOGIC;        
        button_resolution_up : IN STD_LOGIC;
        button_resolution_down : IN STD_LOGIC;
        enable_acquire : OUT STD_LOGIC;
        enable_save : OUT STD_LOGIC;
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

    p0:PROCESS(button_record)
        
    BEGIN
        
        IF button_record = '1' AND press_button_record = FALSE THEN
            enable <= '1';
            acquiring <= NOT acquiring;            
        ELSIF  button_record = '0' THEN
            enable <= '0';
            press_button_record := FALSE;
        ELSE
            press_button_record := TRUE;
        END IF;
        
        enable_acquire <= acquiring;
        arming <= enable;
        
    END PROCESS p0;
    
    p1:PROCESS(button_save)
        
    BEGIN
        
        IF switch_mode = '1' THEN 
            IF button_save = '1' AND press_button_save = FALSE THEN                
                IF acquiring = '1' THEN
                    enable <= '1';
                    acquiring <= '0';
                END IF;                
                saving <= NOT saving;                     
            ELSIF button_save = '1' THEN
                press_button_save := TRUE;
            ELSE
                press_button_save := FALSE;
            END IF;
        END IF;
        
        enable_acquire <= acquiring;
        enable_save <= saving;
        arming <= enable;
           
    END PROCESS p1;
    
    p2:PROCESS(button_resolution_up)
        
    BEGIN
    
        IF switch_resolution = '1' THEN 
            IF button_resolution_up = '1' AND press_button_resolution_up = FALSE THEN
             
            ELSIF button_resolution_up = '1' THEN
                press_button_resolution_up := TRUE;
            ELSE
                press_button_resolution_up := FALSE;
            END IF; 
        END IF;
               
    END PROCESS p2;
    
    p3:PROCESS(button_resolution_down)
        
    BEGIN
    
        IF switch_resolution = '1' THEN 
            IF button_resolution_down = '1' AND press_button_resolution_down = FALSE THEN
             
            ELSIF button_resolution_down = '1' THEN
                press_button_resolution_down := TRUE;
            ELSE
                press_button_resolution_down := FALSE;
            END IF;    
        END IF; 
               
    END PROCESS p3;

END behavioral;
