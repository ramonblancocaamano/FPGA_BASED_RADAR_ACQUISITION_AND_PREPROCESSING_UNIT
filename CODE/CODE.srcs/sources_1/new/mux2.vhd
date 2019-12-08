----------------------------------------------------------------------------------
-- @FILE : mux2.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2 IS
    PORT(
        sel : IN STD_LOGIC;
        i0 : IN STD_LOGIC;
        i1 : IN STD_LOGIC;
        o : OUT STD_LOGIC
    );
END mux2;

ARCHITECTURE behavioral OF mux2 IS
 
BEGIN

    WITH sel SELECT
        o <= i0 WHEN '0',
             i1 WHEN OTHERS;
 
end behavioral;