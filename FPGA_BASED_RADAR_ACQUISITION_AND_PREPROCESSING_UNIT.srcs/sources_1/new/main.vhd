----------------------------------------------------------------------------------
-- @FILE : main.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: FPGA BASED RADAR ACQUISITION AND PREPROCESSING UNIT.
----------------------------------------------------------------------------------
LIBRARY IEEE;
LIBRARY UNISIM;
USE IEEE.STD_LOGIC_1164.ALL;
USE UNISIM.VCOMPONENTS.ALL;

ENTITY main IS
    PORT(
        clk_in : IN STD_LOGIC;
        clk_out: OUT STD_LOGIC;       
        
        -- RADAR.
        clock : IN STD_LOGIC;
        trigger : IN STD_LOGIC;
        arming : OUT STD_LOGIC;
        data: IN std_logic_vector (11 downto 0);
        data_overflow: in std_logic;        
        
        -- INTERFACE.
        sw_mode : IN STD_LOGIC;
        sw_resolution : IN STD_LOGIC;
        sw_reset : IN STD_LOGIC;
        btn_save : IN STD_LOGIC; 
        btn_record : IN STD_LOGIC;               
        btn_resolution_up : IN STD_LOGIC;
        btn_resolution_down : IN STD_LOGIC;
        
        -- SD MEMORY.
        cs : OUT std_logic;				
        mosi : OUT std_logic;			
        miso : IN std_logic;			
        sclk : OUT std_logic;
        
        -- ETHERNET INTERFACE.
        eth_mdio : INOUT STD_LOGIC; 
        eth_mdc : OUT   STD_LOGIC;
        eth_rstn : OUT   STD_LOGIC;            
        eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        eth_tx_en : OUT STD_LOGIC;
        eth_tx_clk : IN  STD_LOGIC;           
        eth_rx_d : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        eth_rx_err : IN  STD_LOGIC;
        eth_rx_dv : IN  STD_LOGIC;
        eth_rx_clk : IN  STD_LOGIC;
        eth_col : IN  STD_LOGIC;
        eth_crs : IN  STD_LOGIC;
        eth_ref_clk : OUT STD_LOGIC;   
        
        -- DRAM
        o_ddr_reset_n : OUT STD_LOGIC;
        o_ddr_ras_n : OUT STD_LOGIC;
        o_ddr_cas_n : OUT STD_LOGIC;
        o_ddr_we_n : OUT STD_LOGIC;
        o_ddr_ck_p : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        o_ddr_ck_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        o_ddr_cke : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        o_ddr_cs_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        o_ddr_odt : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
        o_ddr_ba : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        o_ddr_addr : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        o_ddr_dm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        io_ddr_dqs_p : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        io_ddr_dqs_n : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        io_ddr_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0)     
    );
END main;

ARCHITECTURE behavioral OF main IS
        
    COMPONENT clk_wiz_0
    port(
        clk_in1: IN STD_LOGIC;
        resetn: IN STD_LOGIC;
        clk_25: OUT STD_LOGIC;
        clk_50: OUT STD_LOGIC;
        clk_81:  OUT STD_LOGIC;
        clk_200: OUT STD_LOGIC        
    );
    END COMPONENT;

    COMPONENT control
        PORT(
            trigger : IN STD_LOGIC;
            switch_mode : IN STD_LOGIC;
            switch_resolution : IN STD_LOGIC;
            button_record : IN STD_LOGIC;
            button_save : IN STD_LOGIC;        
            button_resolution_up : IN STD_LOGIC;
            button_resolution_down : IN STD_LOGIC;
            enable_acquire : OUT STD_LOGIC;
            enable_save : OUT STD_LOGIC;
            arming : OUT STD_LOGIC    
        );
    END COMPONENT;
    
    COMPONENT debouncer 
        PORT(
            clock : IN STD_LOGIC;
            i : IN STD_LOGIC;
            o : OUT STD_LOGIC
        );
    END COMPONENT;
    
    CONSTANT NDATA : INTEGER := 4096;
    CONSTANT NACK : INTEGER := NDATA/2-1;
    CONSTANT DDRWIDTH : INTEGER := 16;
    CONSTANT WBDATAWIDTH : INTEGER :=32;
    CONSTANT AXIDWIDTH : INTEGER := 6;
    CONSTANT RAMABITS : INTEGER := 28;
    CONSTANT AXIWIDTH : INTEGER := DDRWIDTH *8;
    CONSTANT DW : INTEGER :=WBDATAWIDTH;
    CONSTANT AW : INTEGER :=RAMABITS-2;
    CONSTANT SELW : INTEGER := (WBDATAWIDTH/8);

    COMPONENT dram
        GENERIC( 
            AW : INTEGER;
            DDRWIDTH : INTEGER;
            NDATA : INTEGER;
            NACK : INTEGER;
            DW : INTEGER;
            SELW : INTEGER
        );    
        PORT( 
            clock_data : IN STD_LOGIC;
            clock_i_dram : IN STD_LOGIC;
            clock_200 : IN STD_LOGIC;
            rst_system : IN STD_LOGIC;
            trigger : IN STD_LOGIC;
            empty_fifo_dram : IN STD_LOGIC;
            wr_fifo_dram : OUT STD_LOGIC;
            rd_fifo_dram : OUT STD_LOGIC;
            wr_fifo_sd : OUT STD_LOGIC;
            data_in_fifo_sd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);        
            clock_o_dram : OUT STD_LOGIC;
            o_ddr_reset_n : OUT STD_LOGIC;
            o_ddr_ras_n : OUT STD_LOGIC;
            o_ddr_cas_n : OUT STD_LOGIC;
            o_ddr_we_n : OUT STD_LOGIC;
            o_ddr_ck_p : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_ck_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_cke : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_cs_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_odt : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_ba : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_ddr_addr : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
            o_ddr_dm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            io_ddr_dqs_p : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            io_ddr_dqs_n : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            io_ddr_data : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            data_in_dram : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            start_sd : OUT STD_LOGIC;
            continue_sd : IN STD_LOGIC;
            continue_sd_ok : OUT STD_LOGIC;
            start_sd_ok : IN STD_LOGIC       
        );
    END COMPONENT;
    
    COMPONENT fifo_ref_81 
        PORT(
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT fifo_81_50 
        PORT(
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT fifo_50_eth 
        PORT(
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT fifo_81_eth 
        PORT(
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT interface
        PORT(
            clock: IN STD_LOGIC;
            rst : IN STD_LOGIC;    
            din: IN std_logic_vector(15 downto 0);            
            rd_en: OUT STD_LOGIC;
            
            trigger : IN STD_LOGIC;
            trigger_ok : OUT STD_LOGIC;              
            continue : OUT STD_LOGIC;              
            continue_ok : IN STD_LOGIC;
            
            eth_mdio : INOUT STD_LOGIC;
            eth_mdc : OUT   STD_LOGIC;
            eth_rstn : OUT   STD_LOGIC;
            eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            eth_tx_en : OUT STD_LOGIC;
            eth_tx_clk : IN  STD_LOGIC;
            eth_rx_d : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            eth_rx_err : IN  STD_LOGIC;
            eth_rx_dv : IN  STD_LOGIC;
            eth_rx_clk : IN  STD_LOGIC; 
            eth_col : IN  STD_LOGIC;
            eth_crs : IN  STD_LOGIC;
            eth_ref_clk : OUT STD_LOGIC
        );  
    END COMPONENT;
    
    COMPONENT memory 
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
    END COMPONENT;
    
    COMPONENT mux2 
        PORT(
            sel : IN STD_LOGIC;
            i0 : IN STD_LOGIC;
            i1 : IN STD_LOGIC;
            o : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT mux2_16b 
        PORT(
            sel : IN STD_LOGIC;
            i0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            i1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT processing 
        PORT(
            clk : IN STD_LOGIC;
            en_acquire : IN STD_LOGIC;
            en_resolution : IN STD_LOGIC;        
            din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    
    SIGNAL button_record_0 : STD_LOGIC := '0';
    SIGNAL button_save_0 : STD_LOGIC := '0';
    SIGNAL button_resolution_up_0 : STD_LOGIC := '0';
    SIGNAL button_resolution_down_0 : STD_LOGIC := '0';
    
    SIGNAL clk_25 : STD_LOGIC := '0';
    SIGNAL clk_50 : STD_LOGIC := '0';
    SIGNAL clk_81 : STD_LOGIC := '0';
    SIGNAL clk_200 : STD_LOGIC := '0';
    
    SIGNAL enable_acquire : STD_LOGIC := '0';
    SIGNAL enable_save : STD_LOGIC := '0';
    
    SIGNAL f_ref_81_rst : STD_LOGIC := '0';
    SIGNAL f_ref_81_din : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_ref_81_wr_en : STD_LOGIC := '0';
    SIGNAL f_ref_81_rd_en : STD_LOGIC := '0';
    SIGNAL f_ref_81_dout : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_ref_81_full : STD_LOGIC := '0';
    SIGNAL f_ref_81_empty : STD_LOGIC := '0';
    
    SIGNAL f_81_50_rst : STD_LOGIC := '0';
    SIGNAL f_81_50_din : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_81_50_wr_en : STD_LOGIC := '0';
    SIGNAL f_81_50_rd_en : STD_LOGIC := '0';
    SIGNAL f_81_50_dout : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_81_50_full : STD_LOGIC := '0';
    SIGNAL f_81_50_empty : STD_LOGIC := '0';
    
    SIGNAL f_50_eth_rst : STD_LOGIC := '0';
    SIGNAL f_50_eth_din : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_50_eth_wr_en : STD_LOGIC := '0';
    SIGNAL f_50_eth_rd_en : STD_LOGIC := '0';
    SIGNAL f_50_eth_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_50_eth_full : STD_LOGIC := '0';
    SIGNAL f_50_eth_empty : STD_LOGIC := '0';
    
    SIGNAL f_81_eth_rst : STD_LOGIC := '0';
    SIGNAL f_81_eth_din : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_81_eth_wr_en : STD_LOGIC := '0';
    SIGNAL f_81_eth_rd_en : STD_LOGIC := '0';
    SIGNAL f_81_eth_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_81_eth_full : STD_LOGIC := '0';
    SIGNAL f_81_eth_empty : STD_LOGIC := '0';
    
    SIGNAL interface_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL interface_rd_en : STD_LOGIC := '0'; 
    
    SIGNAL processing_din : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); 
    
    SIGNAL dram_trigger : STD_LOGIC := '0';

BEGIN

    clk_out <= clk_25;
    
    processing_din <= "000" & data_overflow & data;
    
    f_81_eth_rd_en <= interface_rd_en;
    f_50_eth_rd_en <= interface_rd_en;
        
    INST_CLOCK: clk_wiz_0
        PORT MAP(
            clk_in1 => clock,
            resetn => sw_reset,
            clk_25 => clk_25,
            clk_50 => clk_50,
            clk_81 => clk_81,
            clk_200 => clk_200            
        );  

    INST_CONTROL : control
        PORT MAP(
            trigger => trigger,
            switch_mode => sw_mode,
            switch_resolution => sw_resolution,
            button_record=> button_record_0,
            button_save => button_save_0,        
            button_resolution_up => button_resolution_up_0,
            button_resolution_down => button_resolution_down_0,
            enable_acquire => enable_acquire,
            enable_save => enable_save,
            arming => arming
        );
        
    INST_DEBOUNCER_0 : debouncer 
        PORT MAP(
            clock => clock,
            i => btn_record,
            o => button_record_0
        );
        
    INST_DEBOUNCER_1 : debouncer 
        PORT MAP(
            clock => clock,
            i => btn_save,
            o => button_save_0
        );
        
    INST_DEBOUNCER_2 : debouncer 
        PORT MAP(
            clock => clock,
            i => btn_resolution_up,
            o => button_resolution_up_0
        );
        
    INST_DEBOUNCER_3 : debouncer 
        PORT MAP(
            clock => clock,
            i => btn_resolution_down,
            o => button_resolution_down_0
        );
        
    INST_DRAM : dram
        GENERIC MAP( 
            AW => AW,
            DDRWIDTH => DDRWIDTH,
            NDATA => NDATA,
            NACK => NACK,
            DW => DW,
            SELW => SELW
        )   
        PORT MAP( 
            clock_data => clk_in,
            clock_i_dram => clk_81,
            clock_200 => clk_200,
            rst_system => sw_reset,
            trigger => dram_trigger,
            empty_fifo_dram => f_ref_81_empty,
            wr_fifo_dram => f_ref_81_wr_en,
            rd_fifo_dram => f_ref_81_rd_en,
            wr_fifo_sd => f_81_50_wr_en,
            data_in_fifo_sd => f_81_50_din,    
            clock_o_dram => OPEN,
            o_ddr_reset_n => o_ddr_reset_n,
            o_ddr_ras_n => o_ddr_ras_n,
            o_ddr_cas_n => o_ddr_cas_n,
            o_ddr_we_n => o_ddr_we_n,
            o_ddr_ck_p => o_ddr_ck_p,
            o_ddr_ck_n => o_ddr_ck_n,
            o_ddr_cke => o_ddr_cke,
            o_ddr_cs_n => o_ddr_cs_n,
            o_ddr_odt => o_ddr_odt,
            o_ddr_ba => o_ddr_ba,
            o_ddr_addr => o_ddr_addr,
            o_ddr_dm => o_ddr_dm,
            io_ddr_dqs_p => io_ddr_dqs_p,
            io_ddr_dqs_n => io_ddr_dqs_n,
            io_ddr_data => io_ddr_data,
            data_in_dram => f_ref_81_dout,
            start_sd => OPEN,
            continue_sd => '0',
            continue_sd_ok => OPEN,
            start_sd_ok => '0'           
        );
    
    INST_FIFO_REF_81 : fifo_ref_81 
        PORT MAP(
            rst => sw_reset,
            wr_clk => clk_in,
            rd_clk => clk_81,
            din => f_ref_81_din,
            wr_en => f_ref_81_wr_en,
            rd_en => f_ref_81_rd_en,
            dout => f_ref_81_dout,
            full => f_ref_81_full,
            empty => f_ref_81_empty
        );

    INST_FIFO_81_50 : fifo_81_50 
        PORT MAP(
            rst => sw_reset,
            wr_clk => clk_81,
            rd_clk => clk_50,
            din => f_81_50_din,
            wr_en => f_81_50_wr_en,
            rd_en => f_81_50_rd_en,
            dout => f_81_50_dout,
            full => f_81_50_full,
            empty => f_81_50_empty
        );
        
    INST_FIFO_50_ETH : fifo_50_eth 
        PORT MAP(
            rst => sw_reset,
            wr_clk => clk_50,
            rd_clk => eth_tx_clk,
            din => f_50_eth_din,
            wr_en => f_50_eth_wr_en,
            rd_en => f_50_eth_rd_en,
            dout => f_50_eth_dout,
            full => f_50_eth_full,
            empty => f_50_eth_empty
        );
    
    INST_FIFO_81_ETH : fifo_81_eth 
        PORT MAP(
            rst => sw_reset,
            wr_clk => clk_81,
            rd_clk => eth_tx_clk,
            din => f_81_eth_din,
            wr_en => f_81_eth_wr_en,
            rd_en => f_81_eth_rd_en,
            dout => f_81_eth_dout,
            full => f_81_eth_full,
            empty => f_81_eth_empty
        );
        
    INST_INTERFACE : interface
        PORT MAP(
            clock => clock,
            rst => sw_reset,
            din => interface_data,            
            rd_en => interface_rd_en,
            
            trigger => '0',
            trigger_ok => OPEN,              
            continue => OPEN,             
            continue_ok => '0',
             
            eth_mdio => eth_mdio,
            eth_mdc => eth_mdc,
            eth_rstn => eth_rstn,           
            eth_tx_d => eth_tx_d,
            eth_tx_en => eth_tx_en,
            eth_tx_clk => eth_tx_clk,           
            eth_rx_d => eth_rx_d,
            eth_rx_err => eth_rx_err,
            eth_rx_dv => eth_rx_dv,
            eth_rx_clk => eth_rx_clk,
            eth_col => eth_col,
            eth_crs => eth_crs,
            eth_ref_clk => eth_ref_clk
        );  
        
    INST_MEMORY : memory 
        PORT MAP(
            clock => clock,
            rst => sw_reset,
            din => f_81_50_dout,
            dout => f_50_eth_din,
            rd_en => f_81_50_rd_en,     
            wr_en => f_50_eth_wr_en,
                   
            start_sd => '0',
            start_sd_ok => OPEN,
            continue_sd => OPEN,
            continue_sd_ok => '0',    
            
            trigger_eth => OPEN,
            trigger_eth_ok => '0',
            continue_eth => '0',
            continue_eth_ok => OPEN,      
            
            cs => cs,			
            mosi =>	mosi,	
            miso =>	miso,		
            sclk => sclk
        );
        
    INST_MUX2_16B_0 : mux2_16b 
        PORT MAP(
            sel => enable_save,
            i0 => f_81_eth_dout,
            i1 => f_50_eth_dout,
            o =>  interface_data
        );
    
    INST_PROCESSING : processing 
        PORT MAP(
            clk => clock,
            en_acquire => enable_acquire,
            en_resolution =>  sw_resolution,       
            din => processing_din,
            dout => f_ref_81_din      
        );

END behavioral;
