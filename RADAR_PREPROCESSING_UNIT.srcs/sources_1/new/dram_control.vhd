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
        rst : IN STD_LOGIC;           
        clk_ref : IN STD_LOGIC;
        clk_81 : IN STD_LOGIC;        
        dout: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        trigger: IN STD_LOGIC;
        wr_trigger : OUT STD_LOGIC;
        wr_trigger_ok : IN STD_LOGIC; 
        wr_continue : IN STD_LOGIC;
        wr_continue_ok : OUT STD_LOGIC;
        i_buff_rd_en: OUT STD_LOGIC;
        i_buff_wr_en: OUT STD_LOGIC;
        i_buff_empty: IN STD_LOGIC;
        i_rst : OUT STD_LOGIC;           
        i_wb_cyc : OUT STD_LOGIC;
        i_wb_stb : OUT STD_LOGIC;
        i_wb_we : OUT STD_LOGIC;
        i_wb_addr : OUT STD_LOGIC_VECTOR((AW-1) DOWNTO 0);
        o_buff_wr_en: OUT STD_LOGIC;
        o_wb_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        o_wb_ack : IN STD_LOGIC;
        o_wb_stall : IN STD_LOGIC;
        o_wb_err : IN STD_LOGIC;            
        counter : OUT INTEGER;            
        start : OUT STD_LOGIC;    
        dram_fsm : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        fifo_fsm : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)         
    );
END dram_control;

ARCHITECTURE behavioral OF dram_control IS

    TYPE ST_FIFO IS (IDLE, SEND);
    TYPE ST_DRAM IS (IDLE, SEND, RECEIVE, WAIT_FOR);
    SIGNAL fifo_state : ST_FIFO := IDLE;
    SIGNAL dram_state : ST_DRAM := IDLE;
    
    SIGNAL dram_dout: STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dram_wr_trigger : STD_LOGIC := '0';
    SIGNAL dram_wr_continue_ok : STD_LOGIC := '0';
    SIGNAL dram_i_buff_rd_en: STD_LOGIC := '0';
    SIGNAL dram_i_buff_wr_en: STD_LOGIC := '0';
    SIGNAL dram_i_rst : STD_LOGIC := '0';             
    SIGNAL dram_i_wb_cyc : STD_LOGIC := '0';  
    SIGNAL dram_i_wb_stb : STD_LOGIC := '0';  
    SIGNAL dram_i_wb_we : STD_LOGIC := '0';  
    SIGNAL dram_i_wb_addr : STD_LOGIC_VECTOR((AW-1) DOWNTO 0) := (OTHERS => '0'); 
    SIGNAL dram_o_buff_wr_en : STD_LOGIC := '0';  
    SIGNAL dram_start : STD_LOGIC := '0';  
    
    SHARED VARIABLE fifo : INTEGER := 0;   
    SHARED VARIABLE dram : INTEGER := 0;
    SHARED VARIABLE addr: INTEGER := 0; 
    SHARED VARIABLE ack: INTEGER := 0;    
    SHARED VARIABLE full: INTEGER := 0; 
      
    
BEGIN

    dout <= dram_dout;
    wr_trigger <= dram_wr_trigger;
    wr_continue_ok <= dram_wr_continue_ok;
    i_buff_rd_en <= dram_i_buff_rd_en;
    i_buff_wr_en <= dram_i_buff_wr_en;
    i_rst <= dram_i_rst;             
    i_wb_cyc <= dram_i_wb_cyc;  
    i_wb_stb <= dram_i_wb_stb;  
    i_wb_we <= dram_i_wb_we;  
    i_wb_addr <= dram_i_wb_addr;  
    o_buff_wr_en <= dram_o_buff_wr_en;      
    counter <= full;            
    start <= dram_start;
    
    
    p0:PROCESS(clk_ref)
    BEGIN
        IF rst = '1' THEN
            fifo := 0;                           
            dram_start <= '0';
            dram_i_buff_wr_en <= '0';
            fifo_state <= IDLE;
        ELSIF RISING_EDGE(clk_ref) THEN            
            CASE fifo_state IS                    
                WHEN IDLE => 
                    
                    fifo := 0;      
                    dram_start <= '0';         
                    dram_i_buff_wr_en <= '0';          
                    IF trigger = '1' THEN
                        fifo := fifo + 1;  
                        dram_i_buff_wr_en <= '1';
                        fifo_state <= SEND;
                    END IF;
                
                WHEN SEND =>
                
                    IF fifo < NDATA THEN
                        fifo := fifo + 1;
                        dram_i_buff_wr_en <= '1';                        
                    ELSE
                        fifo := 0;
                        dram_start <= '1';
                        dram_i_buff_wr_en <= '0';                       
                        fifo_state <= IDLE;
                    END IF;
                
            END CASE;
        END IF;
    END PROCESS p0;

    p2:PROCESS(clk_81)
    BEGIN
        IF rst = '1' THEN
                dram := 0;
                addr := 0;
                ack := 0;
                full := 0;
                dram_start <= '0'; 
                dram_dout <= (OTHERS => '0');
                dram_o_buff_wr_en <= '0';                
                dram_i_rst <= '0';                
                dram_i_wb_cyc <= '0';
                dram_i_wb_stb <= '0';                
                dram_i_wb_we <= '0';                
                dram_i_wb_addr <= (OTHERS => '0');               
                dram_state <= IDLE;
       ELSIF RISING_EDGE(clk_81) THEN                    
                IF o_wb_ack = '1' THEN   
                    ack := ack + 1;
                END IF;
                IF wr_trigger_ok = '1' THEN
                    dram_start <= '0';
                END IF;
                CASE dram_state IS
                
                    WHEN IDLE =>
                    
                        dram := 0;
                        ack := 0; 
                        dout <= (OTHERS => '0'); 
                        dram_o_buff_wr_en <= '0';
                        dram_i_rst <= '1';                                           
                        dram_i_wb_cyc <= '0';
                        dram_i_wb_stb <= '0';
                        dram_i_wb_we <= '0';
                        dram_i_wb_addr <= (OTHERS => '0');                                         
                        IF dram_start = '1' THEN   
                            dram_state <= SEND;
                        END IF;                       
                        IF full = 32768 THEN                           
                            addr := 0;
                            full := 0;
                            dram_state <= RECEIVE;
                        END IF;                    
                    
                    WHEN SEND =>
                    
                        IF dram < NDATA/2 AND o_wb_stall = '0'  THEN                                                          
                            dram_i_wb_cyc <= '1';
                            dram_i_wb_stb <= '1';
                            dram_i_wb_we <= '1';
                            dram_i_wb_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,AW));
                            dram := dram + 1;
                            addr := addr + 1;                         
                        ELSIF o_wb_stall = '0' THEN
                            dram_i_wb_stb <= '0';
                        END IF;
                        IF dram_i_wb_stb = '0' AND o_wb_ack = '1' AND ack = NACK THEN
                            dram := 0;
                            ack := 0;
                            full := full + 1;
                            dram_i_wb_cyc <= '0';                            
                            dram_state <= IDLE;
                        END IF;
                    
                    WHEN RECEIVE =>
                    
                        IF wr_continue = '0' THEN
                            dram_wr_continue_ok <= '0';
                        END if;                                                           
                        IF dram < NDATA/2 AND o_wb_stall = '0'THEN
                            dram_i_wb_cyc <= '1';
                            dram_i_wb_stb <= '1';                            
                            dram_i_wb_we <= '0';
                            dram_i_wb_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,AW)); 
                            dram := dram + 1;
                            addr := addr + 1;
                        ELSIF o_wb_stall = '0' then
                            dram_i_wb_stb <= '0';
                        END if;                        
                        IF o_wb_ack = '1' THEN
                            dout <= o_wb_data;
                            dram_o_buff_wr_en <= '1';
                        ELSE 
                            dram_o_buff_wr_en <= '0';
                        END if;                        
                        IF dram_i_wb_stb = '0' AND o_wb_ack = '1' AND ack = NACK THEN
                            dram := 0;
                            ack := 0;
                            full := full + 1;
                            dram_i_wb_cyc <= '0';
                            dram_start <= '1';                           
                            dram_state <= WAIT_FOR;
                        END IF;
                    
                    WHEN WAIT_FOR =>
                    
                        IF o_wb_ack = '1' THEN
                            dout <= o_wb_data;
                            dram_o_buff_wr_en <= '1';
                        ELSE 
                            dram_o_buff_wr_en <= '0';
                        END IF;
                        IF full = 32768 AND wr_trigger_ok = '1' THEN                            
                            addr := 0;
                            full := 0;
                            dram_state <= IDLE;                        
                        ELSIF wr_continue = '1' THEN
                            dram_wr_continue_ok <= '1';
                            dram_state <= RECEIVE;
                        END IF;
                    
                END CASE;
            END IF;                
    END PROCESS p2;
                                            
    dram_i_buff_rd_en <= '1' WHEN o_wb_stall = '0' AND i_buff_empty = '0' AND dram_state = SEND 
                    ELSE '0';

    STATE_DRAM: BLOCK
    BEGIN
        WITH dram_state SELECT dram_fsm <=
            x"00" WHEN IDLE,
            x"00" WHEN SEND,
            x"01" WHEN RECEIVE,
            x"02" WHEN WAIT_FOR,
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
