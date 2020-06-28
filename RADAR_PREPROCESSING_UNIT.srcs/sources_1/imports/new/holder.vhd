----------------------------------------------------------------------------------
-- @FILE : holder.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY holder IS
    PORT(
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        i : IN STD_LOGIC;
        o : OUT STD_LOGIC
    );
END holder;

ARCHITECTURE behavioral OF holder IS

    CONSTANT MAX : INTEGER := 8;    
    SIGNAL holder_o : STD_LOGIC := '0';

BEGIN

    o <= holder_o;
    
    PROCESS(rst, clk, i)
    
        VARIABLE counter : INTEGER := 0;
        
    BEGIN 
           
        IF rst = '1' THEN
            counter := 0;
            holder_o <= '0';    
        ELSIF RISING_EDGE(clk) THEN
            IF i = '0' THEN
                IF counter < MAX THEN
                    counter := counter + 1;
                ELSE
                    holder_o <= '0';  
                END IF;
            ELSE 
                counter := 0;
                holder_o <= '1';
            END IF;
        END IF;
                
    END PROCESS;
END behavioral;

