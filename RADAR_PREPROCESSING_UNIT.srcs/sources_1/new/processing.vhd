----------------------------------------------------------------------------------
-- @FILE : processing.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: ACQUISITION & SIGNAL PRE-PROCESSING OF THE SAMPLED DATA.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY processing is
    GENERIC( 
        NDATA : INTEGER
    );
    PORT(
        rst: IN STD_LOGIC; 
        clk_radar : IN STD_LOGIC; 
        trigger_radar : IN STD_LOGIC;     
        en_acquire : IN STD_LOGIC;
        en_resolution : IN STD_LOGIC; 
        resolution: IN INTEGER;       
        din: IN STD_LOGIC_VECTOR (11 downto 0);
        overflow: IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        hsk_rd1 : OUT STD_LOGIC;
        hsk_rd_ok1 : IN STD_LOGIC;     
        buff_wr_en : OUT STD_LOGIC 
    );
END processing;

ARCHITECTURE behavioral OF processing IS

    SIGNAL p_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');  
    SIGNAL p_hsk_rd1 : STD_LOGIC := '0';
    SIGNAL p_buff_wr_en : STD_LOGIC := '0';
    
    SIGNAL CAST_SHORT : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL CAST_LONG : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FULL : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '1');
    SIGNAL RES : INTEGER := 0;   

BEGIN

    dout <= p_dout;  
    hsk_rd1 <= p_hsk_rd1;
    buff_wr_en <= p_buff_wr_en;

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
    
    PROCESS(rst, clk_radar, en_acquire, en_resolution, resolution, din, overflow, trigger_radar,
        p_dout, p_hsk_rd1, p_buff_wr_en, CAST_SHORT, CAST_LONG, FULL, RES)
    
        VARIABLE st_enable : BOOLEAN := FALSE;
        VARIABLE counter0 : INTEGER := 0;
        VARIABLE counter1 : INTEGER := 0;
        VARIABLE counter_res : INTEGER := 1;
        
    BEGIN
        
        IF rst = '1' OR en_acquire = '0' THEN
            st_enable := FALSE;
            counter0 := 0;
            counter1 := 0; 
            counter_res := 1;
            p_hsk_rd1 <= '0'; 
            p_dout <= (OTHERS => '0'); 
            p_buff_wr_en <= '0';
        ELSIF RISING_EDGE(clk_radar) THEN
            IF hsk_rd_ok1 = '1' THEN
               p_hsk_rd1 <= '0'; 
            END IF;
            IF st_enable = FALSE THEN
                IF trigger_radar = '1' THEN
                    st_enable := TRUE;                    
                ELSE
                    st_enable := FALSE;
                    counter0 := 0;
                    counter_res := 1;
                    p_dout <= (OTHERS => '0'); 
                    p_buff_wr_en <= '0';
                END IF;
            END IF;
            IF st_enable = TRUE THEN
                IF counter1 > NDATA -1 THEN
                    counter1 := 0; 
                    p_hsk_rd1 <= '1'; 
                END IF;
                IF counter0 < NDATA THEN            
                    IF en_resolution = '1'AND counter_res < RES THEN
                        counter_res := counter_res + 1;
                        p_buff_wr_en <= '0';
                        p_dout <= (OTHERS => '0');  
                    ELSE 
                        IF overflow = '1' THEN
                            p_dout <= CAST_SHORT & FULL;
                        ELSE
                            p_dout <= CAST_SHORT & din;
                        END IF;
                        counter1 := counter1 + 1; 
                        counter_res := 1;
                        p_buff_wr_en <= '1'; 
                    END IF;
                    counter0 := counter0 + 1;
                ELSE 
                    st_enable := FALSE;
                    counter0 := 0;
                    counter_res := 1;                     
                    p_buff_wr_en <= '0'; 
                    p_dout <= (OTHERS => '0'); 
                END IF;  
            END IF;     
        END IF;
        
    END PROCESS;

END behavioral;

