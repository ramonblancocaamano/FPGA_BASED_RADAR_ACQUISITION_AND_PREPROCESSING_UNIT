----------------------------------------------------------------------------------
-- @FILE : mux2_16b.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: MULTIPLEX. MULTIPLE-INPUT, SINGLE-OUTPUT.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2_16b IS
    PORT(
        sel : IN STD_LOGIC;
        i0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        i1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END mux2_16b;

ARCHITECTURE behavioral OF mux2_16b IS
 
BEGIN

    WITH sel SELECT
        o <= i0 WHEN '0',
             i1 WHEN OTHERS;
 
end behavioral;

