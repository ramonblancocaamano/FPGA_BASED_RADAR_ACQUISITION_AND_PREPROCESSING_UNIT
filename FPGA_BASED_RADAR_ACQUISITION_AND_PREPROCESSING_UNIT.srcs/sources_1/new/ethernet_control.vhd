----------------------------------------------------------------------------------
-- @FILE : ethernet_control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ethernet_control IS
    PORT(
        clock_eth: IN STD_LOGIC;    
        data_eth_in: IN std_logic_vector(15 downto 0);
        rst_system : IN STD_LOGIC;
        rd_fifo_eth : OUT STD_LOGIC;
        trigger_eth : IN STD_LOGIC;
        trigger_eth_ok : OUT STD_LOGIC;              
        continue_eth : OUT STD_LOGIC;              
        continue_eth_ok : IN STD_LOGIC;
        eth_tx_clk : IN  STD_LOGIC;
        start : IN STD_LOGIC;
        counter : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)  
    );
END ethernet_control;

ARCHITECTURE behavioral OF ethernet_control IS

    SIGNAL count_data_eth : INTEGER := 0;
    SIGNAL count_pack : INTEGER := 0;
    SIGNAL start_eth : STD_LOGIC := '0';
    SIGNAL counter_eth : STD_LOGIC_VECTOR(11 DOWNTO 0);
    
    TYPE ST_ETH IS (IDLE, SEND);
    SIGNAL state : ST_ETH := IDLE;
    
    -- DEBUG.
    SIGNAL rd_fifo_eth_inst : STD_LOGIC;
    SIGNAL trigger_eth_ok_inst : STD_LOGIC;
    SIGNAL continue_eth_inst : STD_LOGIC;
    SIGNAL eth_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    PROCESS(eth_tx_clk)
        BEGIN
            IF RISING_EDGE(eth_tx_clk) THEN
                IF rst_system = '1' THEN
                    start_eth <= '0';
                    state <= IDLE;
                    rd_fifo_eth_inst <= '0';
                    count_data_eth <= 0;
                    trigger_eth_ok <= '0';
                    count_pack <= 0;
                ELSE            
                    CASE (state) IS
                        WHEN IDLE =>
                        
                            rd_fifo_eth_inst <= '0';
                            start_eth <= '0';
                            count_data_eth <= 0;
                            
                            IF count_pack = 32768 THEN
                                count_pack <= 0;
                            END IF;                        
                            IF continue_eth_ok = '1' THEN
                                continue_eth_inst <= '0';
                            END IF;                        
                            IF trigger_eth = '1' THEN
                                state <= SEND;
                                trigger_eth_ok <= '1';
                            END IF;
                        
                        WHEN SEND =>
                        
                            IF trigger_eth = '0' THEN
                                trigger_eth_ok <= '0';
                            END IF;                            
                            IF count_data_eth < 4096 THEN                    
                                IF counter_eth = x"000" AND start_eth = '0' THEN
                                    rd_fifo_eth_inst <= '1';
                                    count_data_eth <= count_data_eth + 1;
                                    start_eth <= '1';
                                ELSIF counter_eth = x"000" AND start_eth = '1' THEN
                                    rd_fifo_eth_inst <= '0';
                                ELSIF counter_eth /= x"000" THEN
                                    start_eth <= '0';                                    
                                END IF;                                
                            ELSE rd_fifo_eth_inst <= '0';
                                IF counter_eth /= x"000" AND count_pack < 32768-1 THEN
                                    start_eth <= '0';
                                    state <= IDLE;
                                    continue_eth_inst <= '1';
                                    count_pack <= count_pack + 1;
                                ELSIF counter_eth /= x"000" AND count_pack = 32768-1 THEN
                                    start_eth <= '0';
                                    state <= IDLE;
                                    count_pack <= count_pack + 1;
                                END IF;
                            END IF;
                                
                        END CASE;
                END IF;
            END IF;
        END PROCESS;
        
        STATE_ETH: BLOCK
        BEGIN
            WITH state SELECT eth_fsm <=
                x"00" WHEN IDLE,
                x"01" WHEN SEND,	
                x"FF" WHEN OTHERS
             ;
        END BLOCK STATE_ETH;

END behavioral;