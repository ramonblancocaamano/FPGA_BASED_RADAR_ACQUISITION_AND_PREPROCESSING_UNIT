----------------------------------------------------------------------------------
-- @FILE : demux2_en.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: DEMULTIPLEX. SINGLE-INPUT, MULTIPLE-OUTPUT.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY demux2_en IS
    PORT(
        sel : IN STD_LOGIC;
        i : IN STD_LOGIC;
        en0 : IN STD_LOGIC;
        en1 :IN STD_LOGIC;
        o0 : OUT STD_LOGIC;
        o1 : OUT STD_LOGIC
    );
END demux2_en;

ARCHITECTURE behavioral OF demux2_en IS
 
BEGIN

    PROCESS(sel, i, en0, en1)
    
    BEGIN
    
        IF sel = '0' AND en0 = '1' THEN
            o0 <= i;
        ELSE
            o0 <= '0';
        END IF;
        
        IF sel = '1' AND en1 = '1' THEN
            o1 <= i;
        ELSE
            o1 <= '0';
        END IF;
        
    END PROCESS;
 
end behavioral;