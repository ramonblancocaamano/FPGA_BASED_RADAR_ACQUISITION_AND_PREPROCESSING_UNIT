----------------------------------------------------------------------------------
-- @FILE : debouncer.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY debouncer IS
    PORT(
        clk : IN STD_LOGIC;
        i : IN STD_LOGIC;
        o : OUT STD_LOGIC
    );
END debouncer;

ARCHITECTURE behavioral OF debouncer IS

    CONSTANT SIZE : INTEGER := 3;    
    SIGNAL previous : STD_LOGIC := '0';
    SIGNAL counter : STD_LOGIC_vector(SIZE DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS(clk)
    
    BEGIN
    
        IF RISING_EDGE(clk) THEN
            IF (previous xor i) = '1' THEN
                counter <= (others => '0');
                previous <= i;
            ELSIF counter(SIZE) = '0' THEN
                counter <= counter + 1;
            ELSE
                o <= previous;
            END IF;
        END IF;
        
    END process;
END behavioral;
