----------------------------------------------------------------------------------
-- @FILE : dram_control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY dram_control IS
    GENERIC( 
        AW : INTEGER;
        DDRWIDTH : INTEGER;
        NDATA : INTEGER;
        NACK : INTEGER;
        DW : INTEGER;
        SELW : INTEGER
    );

    PORT(
            rst_system : IN STD_LOGIC; 
            clock_data : IN STD_LOGIC;        
            clock_i_dram : IN STD_LOGIC;       
            trigger : IN STD_LOGIC;        
            empty_fifo_dram : IN STD_LOGIC;        
            wr_fifo_dram : OUT STD_LOGIC;
            rd_fifo_dram : OUT STD_LOGIC;
            wr_fifo_sd : OUT STD_LOGIC;
            data_in_fifo_sd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            start_sd : OUT STD_LOGIC;  
            start_sd_ok : IN STD_LOGIC;
            continue_sd : IN STD_LOGIC;       
            continue_sd_ok : OUT STD_LOGIC;
            cont_full_dram : OUT INTEGER;            
            start_dram : OUT STD_LOGIC;    
            rst_dram : OUT STD_LOGIC;
            cyc_dram : OUT STD_LOGIC;
            stb_dram : OUT STD_LOGIC;
            we_dram : OUT STD_LOGIC;
            addr_dram : OUT STD_LOGIC_VECTOR ((AW-1) DOWNTO 0);
            ack_dram : IN STD_LOGIC;    
            stall_dram : IN STD_LOGIC;   
            data_out_dram : IN STD_LOGIC_VECTOR(31 DOWNTO 0);    
            start_sd_inst : OUT STD_LOGIC;    
            continue_sd_ok_inst : OUT STD_LOGIC;    
            dram_fsm : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            fifo_fsm : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)            
    );
END dram_control;

ARCHITECTURE behavioral OF dram_control IS

TYPE ST_FIFO IS (IDLE, SEND);

    TYPE ST_DRAM IS (IDLE, SEND, RECEIVE, WAIT_SD);
    SIGNAL fifo_state : ST_FIFO := IDLE;
    SIGNAL dram_state : ST_DRAM := IDLE;
    
    SIGNAL cont_data_dram : INTEGER := 0;
    SIGNAL cont_data_fifo : INTEGER := 0;
    SIGNAL cont_ack : INTEGER := 0;
    SIGNAL cont_addr_dram : INTEGER := 0;
    SIGNAL wr_fifo_dram_inst : STD_LOGIC;
    SIGNAL rd_fifo_dram_inst : STD_LOGIC;
    SIGNAL wr_fifo_sd_inst : STD_LOGIC;

BEGIN

    wr_fifo_dram <= wr_fifo_dram_inst;
    rd_fifo_dram <= rd_fifo_dram_inst;
    wr_fifo_sd <= wr_fifo_sd_inst;
    start_sd <= start_sd_inst;
    continue_sd_ok <= continue_sd_ok_inst;

    p0:PROCESS(clock_data)
    BEGIN
        IF RISING_EDGE(clock_data) THEN
            IF rst_system = '1' THEN
                wr_fifo_dram_inst <= '0';
                fifo_state <= IDLE;
                start_dram <= '0';
                cont_data_fifo <= 0;
            ELSE
                CASE fifo_state IS                    
                    WHEN IDLE => 
                              
                        start_dram <= '0';         
                        wr_fifo_dram_inst <= '0';
                        cont_data_fifo <= 0;                    
                        IF trigger = '1' THEN  
                            fifo_state <= SEND;
                            wr_fifo_dram_inst <= '1';
                            cont_data_fifo <= cont_data_fifo + 1;
                        END IF;
                    
                    WHEN SEND =>
                    
                        IF cont_data_fifo < NDATA THEN
                            wr_fifo_dram_inst <= '1';
                            cont_data_fifo <= cont_data_fifo + 1;
                        ELSE
                            wr_fifo_dram_inst <= '0';
                            cont_data_fifo <= 0;
                            fifo_state <= IDLE;
                            start_dram <= '1';
                        END IF;
                    
                END CASE;
            END IF;
        END IF;
    END PROCESS p0;

    p2:PROCESS(clock_i_dram)
    BEGIN
        IF RISING_EDGE(clock_i_dram) THEN                     
            IF rst_system = '1' THEN
                rst_dram <= '0';
                dram_state <= IDLE;
                cyc_dram <= '0';
                stb_dram <= '0';
                we_dram <= '0';
                cont_data_dram <= 0;
                cont_ack <= 0;
                data_in_fifo_sd <= (OTHERS => '0');
                addr_dram <= (OTHERS => '0');
                start_sd_inst <= '0';
                wr_fifo_sd_inst <= '0';
                cont_addr_dram <= 0;
                cont_full_dram <= 0;
            ELSE    
                IF ack_dram = '1' THEN   
                    cont_ack <= cont_ack + 1;
                END IF;
                IF start_sd_ok = '1' THEN
                    start_sd_inst <= '0';
                END IF;
                
                CASE dram_state IS
                
                    WHEN IDLE =>
                    
                        rst_dram <= '1';
                        data_in_fifo_sd <= (OTHERS => '0');                    
                        cyc_dram <= '0';
                        stb_dram <= '0';
                        we_dram <= '0';
                        cont_data_dram <= 0;
                        cont_ack <= 0;
                        wr_fifo_sd_inst <= '0';
                        addr_dram <= (OTHERS => '0');                        
                        IF start_dram = '1' THEN   
                            dram_state <= SEND;
                        END IF;                       
                        IF cont_full_dram = 32768 THEN
                            dram_state <= RECEIVE;
                            cont_full_dram <= 0;
                            cont_addr_dram <= 0;
                        END IF;                    
                    
                    WHEN SEND =>
                    
                        IF cont_data_dram < NDATA/2 THEN
                            IF stall_dram = '0' THEN
                                stb_dram <= '1';
                                cyc_dram <= '1';
                                we_dram <= '1';
                                addr_dram <= STD_LOGIC_VECTOR(TO_UNSIGNED(cont_addr_dram,AW));
                                cont_data_dram <= cont_data_dram + 1;
                                cont_addr_dram <= cont_addr_dram + 1;
                            END IF;
                        ELSIF stall_dram = '0' THEN
                            stb_dram <= '0';
                        END IF;
                        IF stb_dram = '0' AND ack_dram = '1' AND cont_ack = NACK THEN
                            cont_full_dram <= cont_full_dram + 1;
                            cyc_dram <= '0';
                            dram_state <= IDLE;
                            cont_data_dram <= 0;
                            cont_ack <= 0;
                        END IF;
                    
                    WHEN RECEIVE =>
                    
                        IF continue_sd = '0' THEN
                            continue_sd_ok_inst <= '0';
                        END if;                                                           
                        IF cont_data_dram < NDATA/2 THEN
                            IF stall_dram = '0' THEN
                                stb_dram <= '1';
                                cyc_dram <= '1';
                                we_dram <= '0';
                                addr_dram <= STD_LOGIC_VECTOR(TO_UNSIGNED(cont_addr_dram,AW)); 
                                cont_data_dram <= cont_data_dram + 1;
                                cont_addr_dram <= cont_addr_dram + 1;
                            END if;
                        ELSIF stall_dram = '0' then
                            stb_dram <= '0';
                        END if;                        
                        IF ack_dram = '1' THEN
                            data_in_fifo_sd <= data_out_dram;
                            wr_fifo_sd_inst <= '1';
                        ELSE 
                            wr_fifo_sd_inst <= '0';
                        END if;                        
                        IF stb_dram = '0' AND ack_dram = '1' AND cont_ack = NACK THEN
                            cont_full_dram <= cont_full_dram + 1;
                            cont_data_dram <= 0;
                            cyc_dram <= '0';
                            start_sd_inst <= '1';
                            cont_ack <= 0;
                            dram_state <= WAIT_SD;
                        END IF;
                    
                    WHEN WAIT_SD =>
                    
                        IF ack_dram = '1' THEN
                            data_in_fifo_sd <= data_out_dram;
                            wr_fifo_sd_inst <= '1';
                        ELSE 
                            wr_fifo_sd_inst <= '0';
                        END IF;
                        IF cont_full_dram = 32768 AND start_sd_ok = '1' THEN
                            dram_state <= IDLE;
                            cont_full_dram <= 0;
                            cont_addr_dram <= 0;                        
                        ELSIF continue_sd = '1' THEN
                            continue_sd_ok_inst <= '1';
                            dram_state <= RECEIVE;
                        END IF;
                    
                END CASE;
            END IF;
        END IF;                
    END PROCESS p2;
                                            
    rd_fifo_dram_inst <= '1' WHEN stall_dram = '0' AND empty_fifo_dram = '0' AND dram_state = SEND ELSE '0';
    sel_dram <= "1111";

    STATE_DRAM: BLOCK
    BEGIN
        WITH dram_state SELECT dram_fsm <=
            x"00" WHEN IDLE,
            x"00" WHEN SEND,
            x"01" WHEN RECEIVE,
            x"02" WHEN WAIT_SD,
            x"FF" WHEN OTHERS
         ;
    END BLOCK STATE_DRAM;
    
    STATE_FIFO: BLOCK
    BEGIN
        WITH fifo_state SELECT fifo_fsm <=
            x"00" WHEN IDLE,
            x"01" WHEN SEND,            
            x"FF" WHEN OTHERS
         ;
    END BLOCK STATE_FIFO;
    
END behavioral;
