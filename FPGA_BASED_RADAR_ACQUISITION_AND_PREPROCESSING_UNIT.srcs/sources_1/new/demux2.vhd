----------------------------------------------------------------------------------
-- @FILE : demux2.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY demux2 IS
    PORT(
        sel : IN STD_LOGIC;
        i : IN STD_LOGIC;
        o0 : OUT STD_LOGIC;
        o1 : OUT STD_LOGIC
    );
END demux2;

ARCHITECTURE behavioral OF demux2 IS
 
BEGIN

    WITH sel SELECT
        o0 <= i WHEN '0',
            '0' WHEN OTHERS;
    WITH sel SELECT
        o1 <= i WHEN '1',
            '0' WHEN OTHERS;
 
end behavioral;
