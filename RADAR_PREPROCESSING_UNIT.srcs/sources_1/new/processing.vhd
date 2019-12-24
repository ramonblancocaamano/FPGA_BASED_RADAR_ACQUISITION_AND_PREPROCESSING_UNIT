----------------------------------------------------------------------------------
-- @FILE : processing.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY processing is
    GENERIC( 
        DATA : INTEGER
    );
    PORT(
        rst: IN STD_LOGIC;
        clk : IN STD_LOGIC;  
        clk_radar : IN STD_LOGIC;      
        en_acquire : IN STD_LOGIC;
        en_resolution : IN STD_LOGIC; 
        resolution: IN INTEGER;       
        din: IN STD_LOGIC_VECTOR (11 downto 0);
        overflow: IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        rd_trigger : IN STD_LOGIC;
        wr_trigger : OUT STD_LOGIC
    );
END processing;

ARCHITECTURE behavioral OF processing IS

    SHARED VARIABLE st_enable : BOOLEAN := FALSE;
    SHARED VARIABLE st_trigger : BOOLEAN := FALSE;
    
    SIGNAL processing_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');  
    SIGNAL processing_wr_trigger : STD_LOGIC := '0';
    
    SIGNAL buff : STD_LOGIC_VECTOR(23 DOWNTO 0) := (OTHERS => '0');
    
    SHARED VARIABLE counter_data : INTEGER := 0;
    SHARED VARIABLE counter_resolution : INTEGER := 0;  
    
    SIGNAL CAST_SHORT : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CAST_LONG : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FULL : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '1');
    SIGNAL RES : INTEGER := 0;   

BEGIN

    dout <= processing_dout;  
    wr_trigger <= processing_wr_trigger;

    WITH resolution SELECT
    RES <= 1 WHEN 0,
           2 WHEN 1,
           4 WHEN 2,
           8 WHEN 3,
           16 WHEN 4,
           32 WHEN 5,
           64 WHEN 6,
           128 WHEN 7,
           256 WHEN 8,
           512 WHEN 9,
           1024 WHEN 10,
           2048 WHEN 11,
           4096 WHEN 12,
           1 WHEN OTHERS;
    
    general:PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF st_trigger = TRUE THEN
                processing_wr_trigger <= '1';  
            ELSE
                processing_wr_trigger <= '0'; 
            END IF;
            st_trigger := FALSE;  
        END IF;
    END PROCESS general;
    
    radar:PROCESS(clk_radar)
    BEGIN
        IF rst = '0' AND en_acquire = '1' THEN
            IF RISING_EDGE(clk) THEN
                IF st_enable = FALSE THEN
                    IF rd_trigger = '1' THEN
                        st_enable := TRUE;
                    ELSE
                        st_enable := FALSE;
                        counter_data := 0;
                        counter_resolution := 0;
                        buff <= (OTHERS => '0'); 
                        processing_dout <= (OTHERS => '0'); 
                    END IF;
                END IF;
                IF st_enable = TRUE THEN
                    IF counter_data < DATA THEN
                        IF en_resolution = '1' THEN
                            IF overflow = '1' THEN
                                buff <= buff + (CAST_LONG & FULL);
                            ELSE
                                buff <= buff + (CAST_LONG & din);
                            END IF;
                            IF counter_resolution < RES THEN
                                processing_dout <=  CAST_SHORT & buff((11+resolution) DOWNTO resolution);
                                st_trigger := TRUE;
                                counter_resolution := 0;
                                buff <= (OTHERS => '0'); 
                            ELSE
                                counter_resolution := counter_resolution + 1;
                            END IF;
                        ELSE 
                            IF overflow = '1' THEN
                                processing_dout <= CAST_SHORT & FULL;
                            ELSE
                                processing_dout <= CAST_SHORT & din;
                            END IF;
                            st_trigger := TRUE;
                        END IF; 
                        counter_data := counter_data + 1;
                    ELSE 
                        st_enable := FALSE;
                        counter_data := 0;
                        counter_resolution := 0;
                        buff <= (OTHERS => '0'); 
                        processing_dout <= (OTHERS => '0'); 
                    END IF;
                END IF;
            END IF;
        ELSE
            st_enable := FALSE;
            counter_data := 0;
            counter_resolution := 0;
            buff <= (OTHERS => '0'); 
            processing_dout <= (OTHERS => '0'); 
        END IF;
    END PROCESS radar;

END behavioral;
