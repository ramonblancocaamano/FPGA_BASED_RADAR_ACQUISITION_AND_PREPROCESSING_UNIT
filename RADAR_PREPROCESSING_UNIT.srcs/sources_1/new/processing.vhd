----------------------------------------------------------------------------------
-- @FILE : processing.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY processing is
    PORT(
        rst: IN STD_LOGIC;
        clk : IN STD_LOGIC;        
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

    SIGNAL data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');  
    
    SIGNAL sp_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');  
    SIGNAL sp_wr_trigger : STD_LOGIC := '0';   

BEGIN

    dout <= sp_dout;
    wr_trigger <= sp_wr_trigger;

    data <= "000" & overflow & din;

    PROCESS(clk)
        BEGIN
            IF rst = '1' THEN
                sp_dout <= (OTHERS => '0'); 
                sp_wr_trigger <= '0'; 
            ELSIF RISING_EDGE(clk) AND en_acquire = '1' THEN
                IF en_resolution = '0' THEN
                    sp_dout <= "000" & overflow & din;
                ELSE
                END IF;
            END IF;
    END PROCESS;

END behavioral;
