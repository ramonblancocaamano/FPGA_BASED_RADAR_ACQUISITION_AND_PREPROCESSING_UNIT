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
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        i : IN STD_LOGIC;
        o : OUT STD_LOGIC
    );
END debouncer;

ARCHITECTURE behavioral OF debouncer IS

    CONSTANT MAX : INTEGER := 8;
    SIGNAL previous : STD_LOGIC := '0';    
    SIGNAL debouncer_o : STD_LOGIC := '0';
        
BEGIN

    o <= debouncer_o;
    
    PROCESS(rst, clk, i)
    
        VARIABLE counter : INTEGER := 0;
        
    BEGIN
        
        IF rst = '1' THEN
            counter := 0; 
            debouncer_o <= '0';
        ELSIF RISING_EDGE(clk) THEN
            IF (previous XOR i) = '1' THEN
                counter := 0;
                previous <= i;
            ELSIF counter < MAX THEN
                counter := counter + 1;
            ELSE
                debouncer_o <= previous;
            END IF;
        END IF; 
        
    END PROCESS;
END behavioral;
