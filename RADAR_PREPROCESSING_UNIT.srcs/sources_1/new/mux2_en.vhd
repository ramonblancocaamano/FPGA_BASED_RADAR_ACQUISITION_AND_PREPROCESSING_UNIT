----------------------------------------------------------------------------------
-- @FILE : mux2_en.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: MULTIPLEX. MULTIPLE-INPUT, SINGLE-OUTPUT.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2_en IS
    PORT(
        sel : IN STD_LOGIC;
        i0 : IN STD_LOGIC;
        i1 : IN STD_LOGIC;
        en0 : IN STD_LOGIC;
        en1 :IN STD_LOGIC;
        o : OUT STD_LOGIC
    );
END mux2_en;

ARCHITECTURE behavioral OF mux2_en IS
 
BEGIN

    PROCESS(sel, i0, i1, en0, en1)
    
    BEGIN
    
        IF sel = '0' AND en0 = '1' THEN
            o <= i0;
        ELSIF sel = '1' AND en1 = '1' THEN
            o <= i1;
        ELSE
            o <= '0';
        END IF;
               
    END PROCESS;
 
end behavioral;
