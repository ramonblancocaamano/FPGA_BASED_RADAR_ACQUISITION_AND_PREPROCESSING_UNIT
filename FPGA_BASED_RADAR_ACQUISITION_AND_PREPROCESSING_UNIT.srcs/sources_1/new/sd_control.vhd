----------------------------------------------------------------------------------
-- @FILE : sd_control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY sd_control IS
    PORT( 
        clock_sd : IN STD_LOGIC;
        rst_system: IN std_logic;        
        start_sd: IN std_logic;
        start_sd_ok: OUT std_logic;
        continue_sd: OUT std_logic;
        continue_sd_ok: IN std_logic;        
        rd_fifo_sd: OUT std_logic;        
        wr_fifo_eth: OUT std_logic;
        trigger_eth: OUT std_logic;
        trigger_eth_ok: IN std_logic;
        continue_eth : IN std_logic;
        continue_eth_ok : OUT std_logic;        
        data_i_sd: IN std_logic_vector(7 downto 0);
        data_o_sd: OUT std_logic_vector(7 downto 0)        	
    );
END sd_control;

ARCHITECTURE behavioral OF sd_control IS

    type ST_SD is (IDLE, W1, W2, W3, R1, R2, R3, WAIT_ETH);
    signal state : ST_SD := IDLE;
    
    signal cont: integer:=0;
    signal cont_addr: integer:=0;
    signal cont_addr_pack: integer:=0;
    signal cont_pack: integer:=0;
    signal rst_sd : std_logic;
    signal wr_sd: std_logic;
    signal rd_sd: std_logic;
    signal hndShk_wr_i_sd: std_logic:='0';
    signal hndShk_wr_o_sd: std_logic;
    signal hndShk_rd_i_sd: std_logic:='0';
    signal hndShk_rd_o_sd: std_logic;
    signal busy_sd: std_logic;
    signal error_flag_sd: std_logic;
    signal addr_sd: std_logic_vector (31 downto 0);
    signal error_code_sd: std_logic_vector (7 downto 0);
    signal sd_type: std_logic_vector (1 downto 0);
    signal sd_fsm: std_logic_vector (7 downto 0);
    
        -- DEBUG.
    signal wr_fifo_eth_inst: std_logic;
    signal start_sd_ok_inst: std_logic;
    signal rd_fifo_sd_inst: std_logic;
    signal trigger_eth_inst: std_logic;
    signal data_o_sd_inst: std_logic_vector(7 downto 0);
    signal sd1_fsm : std_logic_vector(7 downto 0);
    signal continue_sd_inst: std_logic;

BEGIN

    -- DEBUG.
    wr_fifo_eth <= wr_fifo_eth_inst;
    rd_fifo_sd <= rd_fifo_sd_inst;
    trigger_eth <= trigger_eth_inst;
    data_o_sd <= data_o_sd_inst;
    continue_sd <= continue_sd_inst;
    start_sd_ok <= start_sd_ok_inst;

    PROCESS(clock_sd)
    BEGIN
        IF RISING_EDGE(clock_sd) THEN        
            IF rst_system = '1' THEN
                start_sd_ok_inst <= '0';
                rd_sd <= '0';
                wr_sd <= '0';
                addr_sd <= (OTHERS => '0');
                hndShk_rd_i_sd <= '0';
                hndShk_wr_i_sd <= '0';
                rd_fifo_sd_inst <= '0';
                rst_sd <= '1';
                state <= IDLE;
                trigger_eth_inst <= '0';
                wr_fifo_eth_inst <= '0';
                cont <= 0;
                cont_addr <= 0;
                cont_addr_pack <= 0;
                cont_pack <= 0;        
            END IF;        
            IF trigger_eth_ok = '1' THEN
                trigger_eth_inst <= '0';
            END IF;        
            IF continue_eth = '1' THEN
                continue_eth_ok <= '1';
            ELSE 
                continue_eth_ok <= '0';
            END IF;        
            IF continue_sd_ok = '1' THEN
                continue_sd_inst <= '0';
            END IF;
        
            CASE (state) IS
            
                WHEN IDLE =>
                
                    rst_sd <= '0';
                    wr_fifo_eth <= '0';
                    wr_sd <= '0';
                    rd_sd <= '0';
                    cont <= 0;
                    cont_addr_pack <= 0;
                    hndShk_wr_i_sd <= '0';
                    hndShk_rd_i_sd <= '0';
                    
                    IF start_sd = '1' AND busy_sd = '0' THEN
                        state <= w1;
                        rd_fifo_sd_inst <= '1';
                        start_sd_ok_inst <= '1';
                    ELSE rd_fifo_sd_inst <= '0';
                        start_sd_ok_inst <= '0';
                    END IF;                      
                
                WHEN W1 =>
                
                    rd_fifo_sd_inst <= '0';
                    
                    IF start_sd = '0' THEN
                        start_sd_ok_inst <= '0';
                    END IF;
                    
                    IF busy_sd = '0' AND cont_addr_pack < 16 then
                        state <= W2;
                        wr_sd <= '1';
                        addr_sd <= std_logic_vector(to_unsigned(cont_addr,32));
                        cont_addr <= cont_addr + 1;
                        cont_addr_pack <= cont_addr_pack + 1;
                        hndShk_wr_i_sd <= '1';
                    ELSIF cont_addr_pack >= 16 AND cont_pack < 32768-1 then
                        cont_pack <= cont_pack + 1;
                        state <= IDLE;
                        continue_sd_inst <= '1';
                        cont_addr_pack <= 0;
                        cont <= 0;
                        rd_fifo_sd_inst <= '0';
                    ELSIF cont_addr_pack >= 16 AND cont_pack = 32768-1 then
                        cont_pack <= 0;
                        state <= R1;
                        cont_addr_pack <= 0;
                        cont <= 0;
                        cont_addr <= 0;
                        rd_fifo_sd_inst <= '0';                                               
                    END IF;
                
                WHEN W2 =>
                
                    IF hndShk_wr_o_sd = '1' THEN
                        hndShk_wr_i_sd <= '0';                                                        
                        state <= W3;
                        rd_fifo_sd_inst <= '1';
                    END IF;
                
                WHEN W3 =>
                
                    rd_fifo_sd_inst <= '0';
                    IF hndShk_wr_o_sd = '0' THEN
                        IF cont < (512-1) THEN
                            state <= W2;
                            cont <= cont + 1;
                            hndShk_wr_i_sd <= '1';
                        ELSE
                            cont <= 0;
                            state <= W1;
                            wr_sd <= '0';
                        END IF;
                    END IF;
                
                WHEN R1 =>
                
                    IF busy_sd = '0' AND cont_addr_pack < 16 THEN
                        state <= R2;
                        rd_sd <= '1';
                        addr_sd <= std_logic_vector(to_unsigned(cont_addr,32));
                        cont_addr <= cont_addr + 1;
                        cont_addr_pack <= cont_addr_pack + 1;                    
                    ELSIF cont_addr_pack >= 16 THEN
                        cont_pack <= cont_pack + 1;
                        cont_addr_pack <= 0;
                        trigger_eth_inst <= '1';
                        state <= WAIT_ETH;  
                    END IF;
                
                WHEN R2 =>
                
                    IF hndShk_rd_o_sd = '1' THEN
                        wr_fifo_eth <= '1';
                        hndShk_rd_i_sd <= '1';
                        state <= R3;
                    END IF;
                
                WHEN R3 =>
                
                    wr_fifo_eth <= '0';
                    IF hndShk_rd_o_sd = '0' THEN
                        IF cont < (512-1) THEN
                            hndShk_rd_i_sd <= '0';                            
                            state <= R2;
                            cont <= cont + 1;
                        ELSE
                            hndShk_rd_i_sd <= '0';
                            cont <= 0;
                            state <= R1;
                            rd_sd <= '0';
                        END IF;
                    END IF;
                
                WHEN WAIT_ETH =>
                
                    IF cont_pack = 32768 THEN
                        state <= IDLE;
                        cont_pack <= 0;
                        cont_addr_pack <= 0;
                        cont_addr <= 0;
                    ELSIF continue_eth = '1' AND busy_sd = '0' THEN
                        state <= R1;
                    END IF;
            
            END CASE;
        END IF;
    END PROCESS;
    
    STATE_SD: BLOCK
    BEGIN
        WITH state SELECT sd1_fsm <=
            x"00" WHEN IDLE,
            x"01" WHEN W1,
            x"02" WHEN W2,
            x"03" WHEN W3,
            x"04" WHEN R1,
            x"05" WHEN R2,
            x"06" WHEN R3,			
            x"FF" WHEN OTHERS
         ;
    END BLOCK STATE_SD;

END behavioral;
