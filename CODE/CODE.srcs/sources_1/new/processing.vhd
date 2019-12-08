----------------------------------------------------------------------------------
-- @FILE : processing.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY processing is
    PORT(
        clk : IN STD_LOGIC;
        en_acquire : IN STD_LOGIC;
        en_resolution : IN STD_LOGIC;        
        din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END processing;

ARCHITECTURE behavioral OF processing IS

    COMPONENT acquisition IS
        PORT(
            clk : IN STD_LOGIC;
            en : IN STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT resolution IS
        PORT(
            clk : IN STD_LOGIC;
            en : IN STD_LOGIC
        );
    END COMPONENT;

BEGIN

    INST_ACQUISITION : acquisition
        PORT MAP( 
            clk => clk,
            en => en_acquire
        );
        
    INST_RESOLUTION : resolution
        PORT MAP( 
            clk => clk,
            en => en_resolution
        );

END behavioral;
