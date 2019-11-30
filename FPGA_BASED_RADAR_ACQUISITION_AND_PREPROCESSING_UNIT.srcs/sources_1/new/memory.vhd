----------------------------------------------------------------------------------
-- @FILE : memory.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY memory IS
    PORT(
        clock : IN STD_LOGIC;
        rst: IN std_logic;
        din: IN std_logic_vector(7 downto 0);
        dout: OUT std_logic_vector(7 downto 0);
        rd_en: OUT std_logic;        
        wr_en: OUT std_logic;
                 
        start_sd: IN std_logic;
        start_sd_ok: OUT std_logic;
        continue_sd: OUT std_logic;
        continue_sd_ok: IN std_logic;        
        
        trigger_eth: OUT std_logic;
        trigger_eth_ok: IN std_logic;
        continue_eth : IN std_logic;
        continue_eth_ok : OUT std_logic;  
            
        cs : OUT std_logic;				
        mosi : OUT std_logic;			
        miso : IN std_logic;			
        sclk : OUT std_logic
    );
END memory;

ARCHITECTURE behavioral OF memory IS

    COMPONENT sd
        GENERIC (
            clockRate : integer := 50000000;		
            slowClockDivider : integer := 128;	
            R1_TIMEOUT : integer := 64;         
            WRITE_TIMEOUT : integer range 0 to 999 := 500; 
            RESET_TICKS : integer := 64;        
            ACTION_RETRIES : integer := 200;    
            READ_TOKEN_TIMEOUT : integer := 1000 
            );
        PORT(
            cs : out std_logic;
            mosi : out std_logic;
            miso : in std_logic;
            sclk : out std_logic;
            card_present : in std_logic;
            card_write_prot : in std_logic;            
            rd : in std_logic;				
            rd_multiple : in std_logic;		
            dout : out std_logic_vector(7 downto 0);
            dout_avail : out std_logic;		
            dout_taken : in std_logic;		            
            wr : in std_logic;				
            wr_multiple : in std_logic;		
            din : in std_logic_vector(7 downto 0);	
            din_valid : in std_logic;		
            din_taken : out std_logic;		
            addr : in std_logic_vector(31 downto 0);
            erase_count : in std_logic_vector(7 downto 0);
            sd_error : out std_logic;		
            sd_busy : out std_logic;		
            sd_error_code : out std_logic_vector(7 downto 0); 
            reset : in std_logic;
            clk : in std_logic;
            sd_type : out std_logic_vector(1 downto 0);	
            sd_fsm : out std_logic_vector(7 downto 0) := "11111111" 
        );
    END COMPONENT;

    COMPONENT sd_control IS
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
    END COMPONENT;
    
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

    INST_SD : sd
        PORT MAP(
            card_present => '1',
            card_write_prot => '0',
            clk => clock,
            reset => rst_sd,
            rd => rd_sd,
            wr => wr_sd,
            rd_multiple => '0',
            wr_multiple => '0',
            addr => addr_sd,
            din => din,
            dout => dout,
            sd_busy => busy_sd,
            dout_taken => hndShk_rd_i_sd,
            dout_avail => hndShk_rd_o_sd,
            din_valid => hndShk_wr_i_sd,
            din_taken => hndShk_wr_o_sd,
            erase_count => x"00",
            sd_error => error_flag_sd,
            sd_error_code => error_code_sd,
            sd_type => sd_type,
            sd_fsm => sd_fsm,
            cs => cs,
            sclk => sclk,
            mosi => mosi,
            miso => miso
        );

    INST_SD_CONTROL : sd_control 
        PORT MAP( 
            clock_sd  => clock,
            rst_system  => rst,        
            start_sd => start_sd,
            start_sd_ok => start_sd_ok,
            continue_sd => continue_sd,
            continue_sd_ok => continue_sd_ok,      
            rd_fifo_sd => rd_en,        
            wr_fifo_eth => wr_en,
            trigger_eth => trigger_eth,
            trigger_eth_ok => trigger_eth_ok,
            continue_eth  => continue_eth,
            continue_eth_ok  => continue_eth_ok,       
            data_i_sd => din,
            data_o_sd => dout        	
        );

END behavioral;
