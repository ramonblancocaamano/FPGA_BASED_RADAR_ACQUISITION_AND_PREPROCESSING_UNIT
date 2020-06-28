----------------------------------------------------------------------------------
-- @FILE : control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: GENERAL MANAGEMENT OF THE SYSTEM FUNCTIONALITIES. 
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
 
    SIGNAL main_en_acquire : STD_LOGIC := '0';
    SIGNAL main_en_save : STD_LOGIC := '0';
    SIGNAL main_resolution: INTEGER := RES;
    SIGNAL main_arming : STD_LOGIC := '0';
    
BEGIN

      en_acquire <= main_en_acquire;
      en_save <= main_en_save;
      resolution <= main_resolution;
      arming <= main_arming;
    
    PROCESS(rst, clk, sw_mode, sw_resolution, btn_record, btn_save, btn_up, btn_down, 
        main_en_acquire, main_en_save, main_resolution, main_arming )
    
        VARIABLE st_arm : BOOLEAN := FALSE;
        VARIABLE st_reset : BOOLEAN := FALSE;        
        VARIABLE st_rec : BOOLEAN := FALSE;
        VARIABLE st_save : BOOLEAN := FALSE;
        VARIABLE st_updown : BOOLEAN := FALSE;
    
    BEGIN
            
        IF rst = '1' THEN 
                IF st_reset = FALSE THEN            
                    IF main_en_acquire = '1' THEN
                        st_arm := TRUE;
                    END IF;
                    st_reset := TRUE;
                    st_rec := FALSE;
                    st_save := FALSE;
                    st_updown := FALSE;
                    main_en_acquire <= '0';
                    main_en_save <= '0';
                    main_resolution <= RES;                
                END IF;
        ELSIF RISING_EDGE(clk) THEN
        
            st_reset := FALSE;
                        
            -- ARMING.       
            IF st_arm = TRUE THEN
                main_arming <= '1';
                st_arm := FALSE;   
            ELSE
                main_arming <= '0';
                st_arm := FALSE;  
            END IF;             
            
            -- RECORD.
            IF st_reset = FALSE AND st_save = FALSE AND st_updown = FALSE THEN
                IF btn_record = '1' THEN
                    IF st_rec = FALSE THEN  
                        st_arm := TRUE;
                        st_rec := TRUE;
                        main_en_save <= '0';
                        IF main_en_acquire = '1' THEN
                            main_en_acquire <= '0';
                        ELSE
                            main_en_acquire <= '1';
                        END IF;
                    END IF;
                ELSE
                    st_rec := FALSE;
                END IF; 
            END IF; 
         
            -- SAVE.        
            IF st_reset = FALSE AND st_rec = FALSE AND st_updown = FALSE THEN
                IF sw_mode = '1' THEN
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
            
           -- UP/DOWN.
           IF st_reset = FALSE AND st_rec = FALSE AND st_save = FALSE THEN
                IF sw_resolution = '1' THEN
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
    END PROCESS;

END behavioral;