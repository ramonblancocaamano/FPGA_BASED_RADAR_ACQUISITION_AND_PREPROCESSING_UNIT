----------------------------------------------------------------------------------
-- @FILE : memory.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY memory IS
    GENERIC( 
        DATA : INTEGER;
        PACKETS : INTEGER
    );
    PORT(
        rst: IN STD_LOGIC;
        clk_50 : IN STD_LOGIC;
        din: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
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
        i_miso : IN STD_LOGIC;     
        o_cs : OUT STD_LOGIC;				
        o_mosi : OUT STD_LOGIC;					
        o_sclk : OUT STD_LOGIC
    );
END memory;

ARCHITECTURE behavioral OF memory IS

    COMPONENT sd
        GENERIC (
            clockRate : INTEGER := 50000000;		
            slowClockDivider : INTEGER := 128;	
            R1_TIMEOUT : INTEGER := 64;         
            WRITE_TIMEOUT : INTEGER range 0 to 999 := 500; 
            RESET_TICKS : INTEGER := 64;        
            ACTION_RETRIES : INTEGER := 200;    
            READ_TOKEN_TIMEOUT : INTEGER := 1000 
            );
        PORT(
            cs : OUT STD_LOGIC;
            mosi : OUT STD_LOGIC;
            miso : IN STD_LOGIC;
            sclk : OUT STD_LOGIC;
            card_present : IN STD_LOGIC;
            card_write_prot : IN STD_LOGIC;            
            rd : IN STD_LOGIC;				
            rd_multiple : IN STD_LOGIC;		
            dout : OUT STD_LOGIC_VECTOR(7 downto 0);
            dout_avail : OUT STD_LOGIC;		
            dout_taken : IN STD_LOGIC;		            
            wr : IN STD_LOGIC;				
            wr_multiple : IN STD_LOGIC;		
            din : IN STD_LOGIC_VECTOR(7 downto 0);	
            din_valid : IN STD_LOGIC;		
            din_taken : OUT STD_LOGIC;		
            addr : IN STD_LOGIC_VECTOR(31 downto 0);
            erase_count : IN STD_LOGIC_VECTOR(7 downto 0);
            sd_error : OUT STD_LOGIC;		
            sd_busy : OUT STD_LOGIC;		
            sd_error_code : OUT STD_LOGIC_VECTOR(7 downto 0); 
            reset : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            sd_type : OUT STD_LOGIC_VECTOR(1 downto 0);	
            sd_fsm : OUT STD_LOGIC_VECTOR(7 downto 0) := "11111111" 
        );
    END COMPONENT;

    COMPONENT sd_control IS
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
    END COMPONENT;
    
    SIGNAL i_rst : STD_LOGIC :='0';
    SIGNAL i_addr: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL i_rd_en: STD_LOGIC :='0';
    SIGNAL i_wr_en: STD_LOGIC :='0';
    SIGNAL i_wr: STD_LOGIC :='0';
    SIGNAL i_rd: STD_LOGIC :='0';
    SIGNAL o_rd: STD_LOGIC :='0';
    SIGNAL o_wr: STD_LOGIC :='0';    
    SIGNAL o_busy: STD_LOGIC :='0';
    
BEGIN

    INST_SD : sd
        PORT MAP(
            cs => o_cs,
            mosi => o_mosi,
            miso => i_miso,
            sclk => o_sclk,
            card_present => '1',
            card_write_prot => '0',          
            rd => i_rd_en,			
            rd_multiple => '0',	
            dout => dout,
            dout_avail => o_rd,	
            dout_taken => i_rd,	            
            wr => i_wr_en,				
            wr_multiple => '0',	
            din => din,
            din_valid => i_wr,
            din_taken => o_wr,
            addr => i_addr,	
            erase_count => x"00",
            sd_error => OPEN,		
            sd_busy => o_busy,		
            sd_error_code => OPEN,
            reset => i_rst,
            clk => clk_50,
            sd_type => OPEN,
            sd_fsm => OPEN
        );

    INST_SD_CONTROL : sd_control
        GENERIC MAP( 
            DATA => DATA,
            PACKETS => PACKETS
        ) 
        PORT MAP(
            rst => rst,
            clk_50 => clk_50,
            rd_trigger => rd_trigger,
            rd_trigger_ok => rd_trigger_ok, 
            rd_continue => rd_continue,
            rd_continue_ok => rd_continue_ok, 
            wr_trigger => wr_trigger, 
            wr_trigger_ok => wr_trigger_ok,
            wr_continue  => wr_continue,
            wr_continue_ok => wr_continue_ok,
            i_buff_rd_en => i_buff_rd_en,
            o_buff_wr_en => o_buff_wr_en, 
            i_rst => i_rst,
            i_addr => i_addr,
            i_rd_en => i_rd_en, 
            i_wr_en => i_wr_en,
            i_wr => i_wr, 
            i_rd => i_rd,                         
            o_rd => o_rd,
            o_wr => o_wr,
            o_busy => o_busy  	
        );

END behavioral;
