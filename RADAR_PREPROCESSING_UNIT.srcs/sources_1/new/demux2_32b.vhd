----------------------------------------------------------------------------------
-- @FILE : demux2_32b.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: DEMULTIPLEX. SINGLE-INPUT, MULTIPLE-OUTPUT.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY demux2_32b IS
    PORT(
        sel : IN STD_LOGIC;
        i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        o1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END demux2_32b;

ARCHITECTURE behavioral OF demux2_32b IS
 
BEGIN

    WITH sel SELECT
        o0 <= i WHEN '0',
            (OTHERS => '0') WHEN OTHERS;
    WITH sel SELECT
        o1 <= i WHEN '1',
            (OTHERS => '0') WHEN OTHERS;
 
end behavioral;
