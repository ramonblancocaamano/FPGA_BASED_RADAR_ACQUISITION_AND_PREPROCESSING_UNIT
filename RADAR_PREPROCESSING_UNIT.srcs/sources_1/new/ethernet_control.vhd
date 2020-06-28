----------------------------------------------------------------------------------
-- @FILE : ethernet_control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ethernet_control IS
    GENERIC( 
        NDATA : INTEGER;
        LOWER_BOUND : UNSIGNED(11 DOWNTO 0);
        HIGHER_BOUND : UNSIGNED(11 DOWNTO 0) 
    );
    PORT(
        rst : IN STD_LOGIC;
        clk: IN STD_LOGIC;   
        hsk_rd0 : IN STD_LOGIC;
        hsk_rd_ok0 : OUT STD_LOGIC;              
        hsk_wr0 : OUT STD_LOGIC;              
        hsk_wr_ok0 : IN STD_LOGIC;
        buff_rd_en : OUT STD_LOGIC;   
        eth_start : OUT STD_LOGIC;
        eth_counter : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        eth_block : OUT STD_LOGIC  
    );
END ethernet_control;

ARCHITECTURE behavioral OF ethernet_control IS

    TYPE ST_ETH IS (IDLE, SEND);
    CONSTANT END_FRAME : UNSIGNED(11 DOWNTO 0) :=  x"8A3";

    SIGNAL state : ST_ETH := IDLE;    
    SIGNAL module : UNSIGNED(11 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL ec_hsk_rd_ok0 : STD_LOGIC := '0';              
    SIGNAL ec_hsk_wr0 : STD_LOGIC := '0'; 
    SIGNAL ec_buff_rd_en : STD_LOGIC := '0';  
    SIGNAL ec_eth_start : STD_LOGIC := '0';
    SIGNAL ec_eth_block : STD_LOGIC := '0';
    
   
BEGIN
    
    hsk_rd_ok0 <=  ec_hsk_rd_ok0;              
    hsk_wr0 <= ec_hsk_wr0; 
    buff_rd_en <= ec_buff_rd_en;  
    eth_start <= ec_eth_start;
    eth_block <= ec_eth_block;
        
    PROCESS(rst, clk, hsk_rd0, hsk_wr_ok0, eth_counter,
        state, module, ec_hsk_rd_ok0, ec_hsk_wr0, ec_buff_rd_en, ec_eth_start, ec_eth_block)
    
        VARIABLE counter : INTEGER := 0;
        
    BEGIN
    
        IF rst = '1' THEN
            state <= IDLE;
            counter := 0;
            ec_hsk_rd_ok0 <= '0';
            ec_hsk_wr0 <= '0';
            ec_buff_rd_en <= '0';
            ec_eth_start <= '0';
            ec_eth_block <= '0';                    
        ELSE        
    
            IF state = SEND THEN
                IF counter < NDATA THEN
                    ec_eth_block <= '0';
                    IF UNSIGNED(eth_counter) > LOWER_BOUND AND UNSIGNED(eth_counter) < HIGHER_BOUND THEN
                        module <= (UNSIGNED(eth_counter) - (LOWER_BOUND + 1)) MOD 4;
                        IF module = x"000" THEN                
                            ec_buff_rd_en <= '1';
                        ELSE
                            ec_buff_rd_en <= '0';
                        END IF;
                    END IF;
                ELSE 
                     ec_buff_rd_en <= '0';              
                END IF;
            END IF;
            
            IF RISING_EDGE(clk) THEN           
                CASE (state) IS
                
                    WHEN IDLE =>
                    
                        ec_buff_rd_en <= '0';
                        ec_eth_start <= '0';
                        IF hsk_wr_ok0 = '1' THEN
                            ec_hsk_wr0 <= '0';
                        END IF;
                        IF counter < NDATA THEN
                            state <= SEND;
                        ELSE 
                            counter := 0;                      
                            IF hsk_rd0 = '1' THEN                            
                                ec_hsk_rd_ok0 <= '1';
                                state <= SEND;
                            END IF;
                        END IF;
                    
                    WHEN SEND =>
                    
                        IF hsk_rd0 = '0' THEN
                            ec_hsk_rd_ok0 <= '0';
                        END IF;                            
                        IF counter < NDATA THEN
                           IF eth_counter = x"000" THEN
                                ec_buff_rd_en <= '0'; 
                                ec_eth_start <= '1';
                           ELSE
                                ec_eth_start <= '0';
                                IF UNSIGNED(eth_counter) > LOWER_BOUND AND UNSIGNED(eth_counter) < HIGHER_BOUND THEN
                                    IF module = x"000" THEN
                                        counter := counter + 1;    
                                    END IF;
                                END IF;                            
                           END IF;                                                        
                        ELSE
                            ec_buff_rd_en <= '0'; 
                            ec_eth_start <= '0';
                            IF module = x"003" THEN
                                ec_eth_block <= '1';
                            END IF;
                            IF UNSIGNED(eth_counter) = END_FRAME THEN
                                ec_hsk_wr0 <= '1';
                                state <= IDLE;
                            END IF;                        
                        END IF;                            
                    END CASE;
                END IF;
            END IF;
        END PROCESS;
        
END behavioral;