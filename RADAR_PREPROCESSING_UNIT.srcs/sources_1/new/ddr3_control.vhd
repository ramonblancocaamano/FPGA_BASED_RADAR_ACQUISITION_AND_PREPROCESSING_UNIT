----------------------------------------------------------------------------------
-- @FILE : ddr3_control.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ddr3_control IS
    GENERIC( 
        AW : INTEGER;
        NDATA : INTEGER;
        NACK : INTEGER
    );
    PORT(
        rst : IN STD_LOGIC;    
        clk_81 : IN STD_LOGIC;        
        dout: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        hsk_rd0 : IN STD_LOGIC; 
        hsk_rd_ok0 : OUT STD_LOGIC;
        hsk_rd1 : OUT STD_LOGIC;
        hsk_rd_ok1 : IN STD_LOGIC; 
        hsk_wr1 : IN STD_LOGIC;
        hsk_wr_ok1 : OUT STD_LOGIC;
        buff_rd_en: OUT STD_LOGIC;
        buff_empty: IN STD_LOGIC;
        buff_wr_en: OUT STD_LOGIC;
        dram_rst : OUT STD_LOGIC;           
        dram_wb_cyc : OUT STD_LOGIC;
        dram_wb_stb : OUT STD_LOGIC;
        dram_wb_we : OUT STD_LOGIC;
        dram_wb_addr : OUT STD_LOGIC_VECTOR((AW-1) DOWNTO 0);        
        dram_wb_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dram_wb_ack : IN STD_LOGIC;
        dram_wb_stall : IN STD_LOGIC     
    );
END ddr3_control;

ARCHITECTURE behavioral OF ddr3_control IS

    TYPE ST_DRAM IS (IDLE, SEND, RECEIVE, WAIT_FOR);
    SIGNAL state : ST_DRAM := IDLE;
    
    SIGNAL dc_dout: STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dc_hsk_rd_ok0 : STD_LOGIC := '0';
    SIGNAL dc_hsk_rd1 : STD_LOGIC := '0';
    SIGNAL dc_hsk_wr_ok1 : STD_LOGIC := '0';
    SIGNAL dc_buff_rd_en: STD_LOGIC := '0';
    SIGNAL dc_buff_wr_en : STD_LOGIC := '0';
    SIGNAL dc_dram_rst : STD_LOGIC := '0';             
    SIGNAL dc_dram_wb_cyc : STD_LOGIC := '0';  
    SIGNAL dc_dram_wb_stb : STD_LOGIC := '0';  
    SIGNAL dc_dram_wb_we : STD_LOGIC := '0';  
    SIGNAL dc_dram_wb_addr : STD_LOGIC_VECTOR((AW-1) DOWNTO 0) := (OTHERS => '0');
        
BEGIN

    dout <= dc_dout;
    hsk_rd_ok0 <= dc_hsk_rd_ok0;
    hsk_rd1 <= dc_hsk_rd1;
    hsk_wr_ok1 <= dc_hsk_wr_ok1;
    buff_rd_en <= dc_buff_rd_en;
    buff_wr_en <= dc_buff_wr_en;    
    dram_rst <= dc_dram_rst;             
    dram_wb_cyc <= dc_dram_wb_cyc;  
    dram_wb_stb <= dc_dram_wb_stb;  
    dram_wb_we <= dc_dram_wb_we;  
    dram_wb_addr <= dc_dram_wb_addr;  
    
   PROCESS(rst, clk_81, hsk_rd0, hsk_rd_ok1, hsk_wr1, buff_empty, dram_wb_data, dram_wb_ack, dram_wb_stall, dc_dout, 
        state, dc_hsk_rd_ok0, dc_hsk_rd1, dc_hsk_wr_ok1, dc_buff_rd_en, dc_dram_rst, dc_dram_wb_cyc, 
        dc_dram_wb_stb, dc_dram_wb_we, dc_dram_wb_addr, dc_buff_wr_en)
     
        VARIABLE counter : INTEGER := 0;
        VARIABLE addr: INTEGER := 0; 
        VARIABLE ack: INTEGER := 0;
        VARIABLE full: INTEGER := 0;   
    
    BEGIN
    
        IF rst = '1' THEN
                state <= IDLE;
                counter := 0;
                addr := 0;
                ack := 0;
                full := 0;                
                dc_dout <= (OTHERS => '0');
                dc_hsk_rd_ok0 <= '0';
                dc_hsk_rd1 <= '0'; 
                dc_hsk_wr_ok1 <= '0';
                dc_buff_rd_en <= '0';
                dc_buff_wr_en <= '0';                
                dc_dram_rst <= '0';                
                dc_dram_wb_cyc <= '0';
                dc_dram_wb_stb <= '0';                
                dc_dram_wb_we <= '0';                
                dc_dram_wb_addr <= (OTHERS => '0');               
                
                
       ELSIF RISING_EDGE(clk_81) THEN                    
                IF dram_wb_ack = '1' THEN   
                    ack := ack + 1;
                END IF;
                IF hsk_rd_ok1 = '1' THEN
                    dc_hsk_rd1 <= '0';
                END IF;
                CASE state IS
                
                    WHEN IDLE =>
                    
                        counter := 0;
                        ack := 0; 
                        dc_dout <= (OTHERS => '0'); 
                        dc_buff_wr_en <= '0';
                        dc_dram_rst <= '1';                                           
                        dc_dram_wb_cyc <= '0';
                        dc_dram_wb_stb <= '0';
                        dc_dram_wb_we <= '0';
                        dc_dram_wb_addr <= (OTHERS => '0');                                         
                        IF hsk_rd0 = '1' THEN   
                            state <= SEND;
                            dc_hsk_rd_ok0 <= '1';
                        END IF;                       
                        IF full = 32768 THEN
                            state <= RECEIVE;                           
                            addr := 0;
                            full := 0;                            
                        END IF;                    
                    
                    WHEN SEND =>
                    
                        IF counter < NDATA/2 AND dram_wb_stall = '0'  THEN                                                          
                            dc_dram_wb_cyc <= '1';
                            dc_dram_wb_stb <= '1';
                            dc_dram_wb_we <= '1';
                            dc_dram_wb_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,AW));
                            counter := counter + 1;
                            addr := addr + 1;                         
                        ELSIF dram_wb_stall = '0' THEN
                            dc_dram_wb_stb <= '0';
                        END IF;
                        IF dc_dram_wb_stb = '0' AND dram_wb_ack = '1' AND ack = NACK THEN
                            counter := 0;
                            ack := 0;
                            full := full + 1;
                            dc_dram_wb_cyc <= '0';                            
                            state <= IDLE;
                        END IF;
                    
                    WHEN RECEIVE =>
                    
                        IF hsk_wr1 = '0' THEN
                            dc_hsk_wr_ok1 <= '0';
                        END if;                                                           
                        IF counter < NDATA/2 AND dram_wb_stall = '0'THEN
                            dc_dram_wb_cyc <= '1';
                            dc_dram_wb_stb <= '1';                            
                            dc_dram_wb_we <= '0';
                            dc_dram_wb_addr <= STD_LOGIC_VECTOR(TO_UNSIGNED(addr,AW)); 
                            counter := counter + 1;
                            addr := addr + 1;
                        ELSIF dram_wb_stall = '0' then
                            dc_dram_wb_stb <= '0';
                        END if;                        
                        IF dram_wb_ack = '1' THEN
                            dc_dout <= dram_wb_data;
                            dc_buff_wr_en <= '1';
                        ELSE 
                            dc_buff_wr_en <= '0';
                        END if;                        
                        IF dc_dram_wb_stb = '0' AND dram_wb_ack = '1' AND ack = NACK THEN
                            counter := 0;
                            ack := 0;
                            full := full + 1;
                            dc_hsk_rd1 <= '1';
                            dc_dram_wb_cyc <= '0';                                                       
                            state <= WAIT_FOR;
                        END IF;
                    
                    WHEN WAIT_FOR =>
                    
                        IF dram_wb_ack = '1' THEN
                            dc_dout <= dram_wb_data;
                            dc_buff_wr_en <= '1';
                        ELSE 
                            dc_buff_wr_en <= '0';
                        END IF;
                        IF full = 32768 AND hsk_rd_ok1 = '1' THEN                            
                            addr := 0;
                            full := 0;
                            state <= IDLE;                        
                        ELSIF hsk_wr1 = '1' THEN
                            dc_hsk_wr_ok1 <= '1';
                            state <= RECEIVE;
                        END IF;
                    
                END CASE;
            END IF;
    END PROCESS;
                                            
    dc_buff_rd_en <= '1' WHEN dram_wb_stall = '0' AND buff_empty = '0' AND state = SEND ELSE '0';
    
END behavioral;