----------------------------------------------------------------------------------
-- @FILE : sd_memory.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: MANAGEMENT OF NON-VOLATILE SD MEMORY.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY sd_memory IS
    GENERIC( 
        NDATA : INTEGER := 4096;
        NPACKETS : INTEGER := 32768
    );
    PORT(
        rst: IN STD_LOGIC;
        clk_50 : IN STD_LOGIC;
        din: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
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
        i_miso : IN STD_LOGIC;     
        o_cs : OUT STD_LOGIC;				
        o_mosi : OUT STD_LOGIC;					
        o_sclk : OUT STD_LOGIC
    );
END sd_memory;

ARCHITECTURE behavioral OF sd_memory IS

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
            sd_hsk_wr_i: OUT STD_LOGIC;
            sd_hsk_rd_i: OUT STD_LOGIC;  
            sd_hsk_rd_o: IN STD_LOGIC;
            sd_hsk_wr_o: IN STD_LOGIC;
            sd_busy : IN STD_LOGIC 	
        );
    END COMPONENT;
    
    SIGNAL sd_rst : STD_LOGIC :='0';
    SIGNAL sd_addr: STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL sd_rd_en: STD_LOGIC :='0';
    SIGNAL sd_wr_en: STD_LOGIC :='0';      
    SIGNAL sd_busy: STD_LOGIC :='0';
    SIGNAL sd_hsk_rd_i: STD_LOGIC :='0';
    SIGNAL sd_hsk_rd_o: STD_LOGIC :='0';
    SIGNAL sd_hsk_wr_i: STD_LOGIC :='0';
    SIGNAL sd_hsk_wr_o: STD_LOGIC :='0';  
    
BEGIN

    INST_SD : sd
        PORT MAP(
            cs => o_cs,
            mosi => o_mosi,
            miso => i_miso,
            sclk => o_sclk,
            card_present => '1',
            card_write_prot => '0',          
            rd => sd_rd_en,			
            rd_multiple => '0',	
            dout => dout,
            dout_avail => sd_hsk_rd_o,	
            dout_taken => sd_hsk_rd_i,	            
            wr => sd_wr_en,				
            wr_multiple => '0',	
            din => din,
            din_valid => sd_hsk_wr_i,
            din_taken => sd_hsk_wr_o,
            addr => sd_addr,	
            erase_count => x"00",
            sd_error => OPEN,		
            sd_busy => sd_busy,		
            sd_error_code => OPEN,
            reset => sd_rst,
            clk => clk_50,
            sd_type => OPEN,
            sd_fsm => OPEN
        );

    INST_SD_CONTROL : sd_control
        GENERIC MAP( 
            NPACKETS => NPACKETS
        ) 
        PORT MAP(
            rst => rst,
            clk_50 => clk_50,
            hsk_rd0 => hsk_rd0,
            hsk_rd_ok0 => hsk_rd_ok0, 
            hsk_wr0 => hsk_wr0,
            hsk_wr_ok0 => hsk_wr_ok0, 
            hsk_rd1 => hsk_rd1, 
            hsk_rd_ok1 => hsk_rd_ok1,
            hsk_wr1  => hsk_wr1,
            hsk_wr_ok1 => hsk_wr_ok1,
            buff_rd_en => buff_rd_en,
            buff_wr_en => buff_wr_en, 
            sd_rst => sd_rst,
            sd_addr => sd_addr,
            sd_rd_en => sd_rd_en, 
            sd_wr_en => sd_wr_en,
            sd_hsk_wr_i => sd_hsk_wr_i, 
            sd_hsk_rd_i => sd_hsk_rd_i,                         
            sd_hsk_rd_o => sd_hsk_rd_o,
            sd_hsk_wr_o => sd_hsk_wr_o,
            sd_busy => sd_busy  	
        );

END behavioral;