----------------------------------------------------------------------------------
-- @FILE : enable_16b.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: ENABLE 16b PORTS.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY enable_16b IS
    PORT(
        en : IN STD_LOGIC;
        i0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
        o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END enable_16b;

ARCHITECTURE behavioral OF enable_16b IS
 
BEGIN

    WITH en SELECT
        o <= (OTHERS => '0') WHEN '1',
             i0 WHEN OTHERS;
 
end behavioral;