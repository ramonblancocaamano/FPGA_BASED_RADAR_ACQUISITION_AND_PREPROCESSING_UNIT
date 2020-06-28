----------------------------------------------------------------------------------
-- @FILE : enable.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: ENABLE PORTS.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY enable IS
    PORT(
        en : IN STD_LOGIC;
        i0 : IN STD_LOGIC;
        o : OUT STD_LOGIC
    );
END enable;

ARCHITECTURE behavioral OF enable IS
 
BEGIN

    WITH en SELECT
        o <= '0' WHEN '1',
             i0 WHEN OTHERS;
 
end behavioral;