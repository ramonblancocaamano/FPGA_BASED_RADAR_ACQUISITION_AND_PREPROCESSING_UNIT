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
    GENERIC( 
        NPACKETS : INTEGER
    );
    PORT( 
        rst: IN STD_LOGIC;
        clk_50 : IN STD_LOGIC;           
        hsk_rd0: IN STD_LOGIC;
        hsk_rd_ok0: OUT STD_LOGIC;
        hsk_wr0: OUT STD_LOGIC;
        hsk_wr_ok0: IN STD_LOGIC;                        
        hsk_rd1: OUT STD_LOGIC;
        hsk_rd_ok1: IN STD_LOGIC;
        hsk_wr1 : IN STD_LOGIC;
        hsk_wr_ok1 : OUT STD_LOGIC;
        buff_rd_en: OUT STD_LOGIC;        
        buff_wr_en: OUT STD_LOGIC;  
        sd_rst : OUT STD_LOGIC ;
        sd_addr: OUT STD_LOGIC_VECTOR(31 downto 0);
        sd_rd_en: OUT STD_LOGIC;        
        sd_wr_en: OUT STD_LOGIC;
        sd_hsk_rd_i: OUT STD_LOGIC;  
        sd_hsk_wr_i: OUT STD_LOGIC;        
        sd_hsk_rd_o: IN STD_LOGIC;
        sd_hsk_wr_o: IN STD_LOGIC;
        sd_busy : IN STD_LOGIC 		
    );
END sd_control;

ARCHITECTURE behavioral OF sd_control IS
    
    TYPE ST_SD is (IDLE, W1, W2, W3, R1, R2, R3, WAIT_FOR);
    SIGNAL state : ST_SD := IDLE;
    
    SIGNAL sc_hsk_rd_ok0: STD_LOGIC := '0';
    SIGNAL sc_hsk_wr0: STD_LOGIC := '0';
    SIGNAL sc_hsk_rd1: STD_LOGIC := '0'; 
    SIGNAL sc_hsk_wr_ok1 : STD_LOGIC := '0'; 
    SIGNAL sc_buff_rd_en: STD_LOGIC := '0';             
    SIGNAL sc_buff_wr_en: STD_LOGIC := '0';
    SIGNAL sc_sd_rst : STD_LOGIC := '0';
    SIGNAL sc_sd_addr : STD_LOGIC_VECTOR(31  DOWNTO 0):= (OTHERS => '0');
    SIGNAL sc_sd_rd_en : STD_LOGIC := '0';
    SIGNAL sc_sd_wr_en : STD_LOGIC := '0';
    SIGNAL sc_sd_hsk_rd_i : STD_LOGIC := '0'; 
    SIGNAL sc_sd_hsk_wr_i : STD_LOGIC := '0';
      
    
BEGIN
    
    hsk_rd_ok0 <= sc_hsk_rd_ok0;
    hsk_wr0 <= sc_hsk_wr0;           
    hsk_rd1 <= sc_hsk_rd1;    
    hsk_wr_ok1 <= sc_hsk_wr_ok1;
    buff_rd_en <= sc_buff_rd_en;
    buff_wr_en <= sc_buff_wr_en;     
    sd_rst <= sc_sd_rst;
    sd_addr <= sc_sd_addr;
    sd_rd_en <= sc_sd_rd_en;
    sd_wr_en <= sc_sd_wr_en;
    sd_hsk_rd_i <= sc_sd_hsk_rd_i;
    sd_hsk_wr_i <= sc_sd_hsk_wr_i;

    PROCESS(rst, clk_50, hsk_rd0, hsk_wr_ok0, hsk_rd_ok1, hsk_wr1, sd_hsk_rd_o, sd_hsk_wr_o, sd_busy,
        state, sc_hsk_rd_ok0, sc_hsk_wr0, sc_hsk_rd1, sc_hsk_wr_ok1, sc_buff_rd_en, 
        sc_buff_wr_en , sc_sd_rst, sc_sd_addr, sc_sd_rd_en, sc_sd_wr_en, sc_sd_hsk_rd_i, sc_sd_hsk_wr_i)
    
        VARIABLE counter : INTEGER := 0;
        VARIABLE counter_packets : INTEGER := 0;    
        VARIABLE addr: INTEGER := 0;
        VARIABLE addr_packets: INTEGER := 0;
        
    BEGIN
        IF rst = '1' THEN
                state <= IDLE;
                counter := 0;
                counter_packets := 0;
                addr := 0;
                addr_packets := 0;               
                sc_hsk_rd_ok0 <= '0';
                sc_hsk_wr0 <= '0';
                sc_hsk_rd1 <= '0';
                sc_hsk_wr_ok1 <= '0';
                sc_buff_rd_en <= '0';
                sc_buff_wr_en <= '0';
                sc_sd_rst <= '1';
                sc_sd_addr <= (OTHERS => '0');
                sc_sd_rd_en <= '0';      
                sc_sd_wr_en <= '0';   
                sc_sd_hsk_rd_i <= '0';                    
                sc_sd_hsk_wr_i <= '0';                               
        ELSIF RISING_EDGE(clk_50) THEN                
            IF hsk_rd_ok1 = '1' THEN
                sc_hsk_rd1 <= '0';
            END IF;        
            IF hsk_wr1 = '1' THEN
                sc_hsk_wr_ok1 <= '1';
            ELSE 
                sc_hsk_wr_ok1 <= '0';
            END IF;        
            IF hsk_wr_ok0 = '1' THEN
                sc_hsk_wr0 <= '0';
            END IF;        
            CASE (state) IS
            
                WHEN IDLE =>
                
                    counter := 0;
                    addr_packets := 0;
                    sc_buff_wr_en <= '0';
                    sc_sd_rst <= '0';
                    sc_sd_rd_en <= '0'; 
                    sc_sd_wr_en <= '0';
                    sc_sd_hsk_rd_i <= '0';                    
                    sc_sd_hsk_wr_i <= '0';                  
                    IF hsk_rd0 = '1' AND sd_busy = '0' THEN
                        state <= W1;                        
                        sc_hsk_rd_ok0 <= '1';
                        sc_buff_rd_en <= '1';                       
                    ELSE
                        sc_hsk_rd_ok0 <= '0'; 
                        sc_buff_rd_en <= '0';                        
                    END IF;                      
                
                WHEN W1 =>
                
                    sc_buff_rd_en <= '0';                    
                    IF hsk_rd0 = '0' THEN
                        sc_hsk_rd_ok0 <= '0';
                    END IF;                    
                    IF sd_busy = '0' AND addr_packets < 16 THEN  
                        state <= W2;
                        sc_sd_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,32));
                        addr := addr + 1;
                        addr_packets := addr_packets + 1;                          
                        sc_sd_wr_en <= '1';
                        sc_sd_hsk_wr_i <= '1';                        
                    ELSIF addr_packets >= 16 AND counter_packets < NPACKETS-1 THEN
                        state <= IDLE;                                              
                        counter := 0;
                        counter_packets := counter_packets + 1;
                        addr_packets := 0; 
                        sc_hsk_wr0 <= '1';                
                    ELSIF addr_packets >= 16 AND counter_packets = NPACKETS-1 THEN
                        state <= R1;
                        counter := 0;
                        counter_packets := 0;                        
                        addr := 0;
                        addr_packets := 0;                                                    
                    END IF;
                
                WHEN W2 =>
                
                    IF sd_hsk_wr_o = '1' THEN
                        state <= W3;
                        sc_buff_rd_en <= '1';
                        sc_sd_hsk_wr_i <= '0';                                                       
                    END IF;
                
                WHEN W3 =>
                
                    sc_buff_rd_en <= '0';
                    IF sd_hsk_wr_o = '0' THEN
                        IF counter < (512-1) THEN
                            state <= W2;
                            counter := counter + 1;
                            sc_sd_hsk_wr_i <= '1';                            
                        ELSE
                            state <= W1;
                            counter := 0;
                            sc_sd_wr_en <= '0';
                        END IF;
                    END IF;
                
                WHEN R1 =>
                
                    IF sd_busy = '0' AND addr_packets < 16 THEN
                        state <= R2; 
                        sc_sd_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,32));  
                        addr := addr + 1;
                        addr_packets := addr_packets + 1;
                        sc_sd_rd_en <= '1';                                                                
                    ELSIF addr_packets >= 16 THEN
                        state <= WAIT_FOR;
                        counter_packets := counter_packets + 1;
                        addr_packets := 0;
                        sc_hsk_rd1 <= '1';                                                
                    END IF;
                
                WHEN R2 =>
                
                    IF sd_hsk_rd_o = '1' THEN 
                        state <= R3;
                        sc_buff_wr_en <= '1';                       
                        sc_sd_hsk_rd_i <= '1';
                    END IF;
                
                WHEN R3 =>
                
                    sc_buff_wr_en <= '0';
                    IF sd_hsk_rd_o = '0' THEN
                        sc_sd_hsk_rd_i <= '0';
                        IF counter < (512-1) THEN
                            state <= R2;
                            counter := counter + 1;
                        ELSE
                            state <= R1;
                            counter := 0;
                            sc_sd_rd_en <= '0';
                        END IF;
                    END IF;
                
                WHEN WAIT_FOR =>
                
                    IF counter_packets = NPACKETS THEN                              
                        state <= IDLE;
                        counter_packets := 0;
                        addr_packets := 0;
                        addr := 0;    
                    ELSIF hsk_wr1 = '1' AND sd_busy = '0' THEN
                        state <= R1;
                    END IF;
            
            END CASE;
        END IF;
    END PROCESS;

END behavioral;

