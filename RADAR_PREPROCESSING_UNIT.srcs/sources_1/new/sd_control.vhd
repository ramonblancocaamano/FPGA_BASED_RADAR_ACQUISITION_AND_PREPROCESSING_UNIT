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
        DATA : INTEGER;
        PACKETS : INTEGER
    );
    PORT( 
        rst: IN STD_LOGIC;
        clk_50 : IN STD_LOGIC;            
        rd_trigger: IN STD_LOGIC;
        rd_trigger_ok: OUT STD_LOGIC;
        rd_continue: OUT STD_LOGIC;
        rd_continue_ok: IN STD_LOGIC;                        
        wr_trigger: OUT STD_LOGIC;
        wr_trigger_ok: IN STD_LOGIC;
        wr_continue : IN STD_LOGIC;
        wr_continue_ok : OUT STD_LOGIC;
        i_buff_rd_en: OUT STD_LOGIC;        
        o_buff_wr_en: OUT STD_LOGIC;  
        i_rst : OUT STD_LOGIC ;
        i_addr: OUT STD_LOGIC_VECTOR(31 downto 0);
        i_rd_en: OUT STD_LOGIC;        
        i_wr_en: OUT STD_LOGIC;
        i_wr: OUT STD_LOGIC;
        i_rd: OUT STD_LOGIC;  
        o_rd: IN STD_LOGIC;
        o_wr: IN STD_LOGIC;
        o_busy : IN STD_LOGIC 	
    );
END sd_control;

ARCHITECTURE behavioral OF sd_control IS

    TYPE ST_SD is (IDLE, W1, W2, W3, R1, R2, R3, WAIT_FOR);
    SIGNAL state : ST_SD := IDLE;
    SIGNAL sd_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL sd_i_buff_rd_en: STD_LOGIC := '0';
    SIGNAL sd_rd_trigger_ok: STD_LOGIC := '0';
    SIGNAL sd_rd_continue: STD_LOGIC := '0';              
    SIGNAL sd_o_buff_wr_en: STD_LOGIC := '0';
    SIGNAL sd_wr_trigger: STD_LOGIC := '0';
    SIGNAL sd_wr_continue_ok : STD_LOGIC := '0'; 
    SIGNAL sd_i_rst : STD_LOGIC := '0';
    SIGNAL sd_i_wr_en : STD_LOGIC := '0';
    SIGNAL sd_i_rd_en : STD_LOGIC := '0';
    SIGNAL sd_i_addr : STD_LOGIC_VECTOR(31  DOWNTO 0):= (OTHERS => '0');
    SIGNAL sd_i_wr : STD_LOGIC := '0';
    SIGNAL sd_i_rd : STD_LOGIC := '0';   
    
    SHARED VARIABLE counter_data : INTEGER := 0;
    SHARED VARIABLE counter_packets : INTEGER := 0;    
    SHARED VARIABLE addr: INTEGER := 0;
    SHARED VARIABLE addr_packets: INTEGER := 0;
    
BEGIN
    
    rd_trigger_ok <= sd_rd_trigger_ok;
    rd_continue <= sd_rd_continue;             
    wr_trigger <= sd_wr_trigger;
    wr_continue_ok <= sd_wr_continue_ok;
    i_buff_rd_en <= sd_i_buff_rd_en;
    o_buff_wr_en <= sd_o_buff_wr_en; 
    i_rst <= sd_i_rst;
    i_wr_en <= sd_i_wr_en;
    i_rd_en <= sd_i_rd_en;
    i_addr <= sd_i_addr;
    i_wr <= sd_i_wr;
    i_rd <= sd_i_rd; 

    PROCESS(clk_50)
    BEGIN
        IF rst = '1' THEN
                state <= IDLE;
                counter_data := 0;
                counter_packets := 0;
                addr := 0;
                addr_packets := 0;               
                sd_rd_trigger_ok <= '0';
                sd_rd_continue <= '0';
                sd_wr_trigger <= '0';
                sd_wr_continue_ok <= '0';
                sd_i_buff_rd_en <= '0';
                sd_o_buff_wr_en <= '0';
                sd_i_rst <= '1'; 
                sd_i_wr_en <= '0';
                sd_i_rd_en <= '0';
                sd_i_addr <= (OTHERS => '0');             
                sd_i_wr <= '0';
                sd_i_rd <= '0';                               
        ELSIF RISING_EDGE(clk_50) THEN                
            IF wr_trigger_ok = '1' THEN
                sd_wr_trigger <= '0';
            END IF;        
            IF wr_continue = '1' THEN
                wr_continue_ok <= '1';
            ELSE 
                wr_continue_ok <= '0';
            END IF;        
            IF rd_continue_ok = '1' THEN
                sd_rd_continue <= '0';
            END IF;        
            CASE (state) IS
            
                WHEN IDLE =>
                
                    counter_data := 0;
                    addr_packets := 0;
                    sd_o_buff_wr_en <= '0';
                    sd_i_rst <= '0';
                    sd_i_wr <= '0';
                    sd_i_rd <= '0';                                        
                    IF rd_trigger = '1' AND o_busy = '0' THEN                        
                        sd_rd_trigger_ok <= '1';
                        sd_i_buff_rd_en <= '1';                        
                        state <= W1;
                    ELSE 
                        sd_i_buff_rd_en <= '0';
                        sd_rd_trigger_ok <= '0';
                    END IF;                      
                
                WHEN W1 =>
                
                    sd_i_buff_rd_en <= '0';                    
                    IF rd_trigger = '0' THEN
                        sd_rd_trigger_ok <= '0';
                    END IF;                    
                    IF o_busy = '0' AND addr_packets < 16 THEN                        
                        sd_o_buff_wr_en <= '1';
                        sd_i_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,32));
                        sd_i_wr <= '1';
                        addr := addr + 1;
                        addr_packets := addr_packets + 1;                        
                        state <= W2;
                    ELSIF addr_packets >= 16 AND counter_packets < PACKETS-1 THEN                                              
                        counter_data := 0;
                        counter_packets := counter_packets + 1;
                        addr_packets := 0;
                        sd_rd_continue <= '1';                        
                        state <= IDLE;
                    ELSIF addr_packets >= 16 AND counter_packets = PACKETS-1 THEN
                        counter_data := 0;
                        counter_packets := 0;                        
                        addr := 0;
                        addr_packets := 0;                        
                        state <= R1;                                               
                    END IF;
                
                WHEN W2 =>
                
                    IF o_wr = '1' THEN
                        sd_i_buff_rd_en <= '1';
                        sd_i_wr <= '0';                                                       
                        state <= W3;
                    END IF;
                
                WHEN W3 =>
                
                    sd_i_buff_rd_en <= '0';
                    IF o_wr = '0' THEN
                        IF counter_data < (512-1) THEN
                            counter_data := counter_data + 1;
                            sd_i_wr <= '1';
                            state <= W2;
                        ELSE
                            counter_data := 0;
                            sd_o_buff_wr_en <= '0';                            
                            state <= W1;
                        END IF;
                    END IF;
                
                WHEN R1 =>
                
                    IF o_busy = '0' AND addr_packets < 16 THEN
                        addr := addr + 1;
                        addr_packets := addr_packets + 1;                          
                        sd_i_buff_rd_en <= '1';
                        sd_i_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(counter_data,32));
                        state <= R2;                    
                    ELSIF addr_packets >= 16 THEN
                        counter_packets := counter_packets + 1;
                        addr_packets := 0;
                        sd_wr_trigger <= '1';                                                
                        state <= WAIT_FOR;  
                    END IF;
                
                WHEN R2 =>
                
                    IF o_rd = '1' THEN 
                        sd_o_buff_wr_en <= '1';                       
                        sd_i_rd <= '1';
                        state <= R3;
                    END IF;
                
                WHEN R3 =>
                
                    sd_o_buff_wr_en <= '0';
                    IF o_rd = '0' THEN
                        sd_i_rd <= '0';
                        IF counter_data < (512-1) THEN
                            counter_data := counter_data + 1;
                            state <= R2;
                        ELSE
                            counter_data := 0;
                            sd_i_buff_rd_en <= '0';                            
                            state <= R1;
                        END IF;
                    END IF;
                
                WHEN WAIT_FOR =>
                
                    IF counter_packets = PACKETS THEN                        
                        counter_packets := 0;
                        addr_packets := 0;
                        addr := 0;                        
                        state <= IDLE;
                    ELSIF wr_continue = '1' AND o_busy = '0' THEN
                        state <= R1;
                    END IF;
            
            END CASE;
        END IF;
    END PROCESS;
    
    STATE_SD: BLOCK
    BEGIN
        WITH state SELECT sd_fsm <=
            x"00" WHEN IDLE,
            x"01" WHEN W1,
            x"02" WHEN W2,
            x"03" WHEN W3,
            x"04" WHEN R1,
            x"05" WHEN R2,
            x"06" WHEN R3,
            x"07" WHEN WAIT_FOR,			
            x"FF" WHEN OTHERS
         ;
    END BLOCK STATE_SD;

END behavioral;
