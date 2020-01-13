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
    GENERIC( 
        DATA : INTEGER := 4096;
        PACKETS : INTEGER := 32768;
        RES : INTEGER := 4
    );
    PORT(
        rst : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        clk_out: OUT STD_LOGIC;       
        radar_clk : IN STD_LOGIC;
        radar_trigger : IN STD_LOGIC;
        radar_arming : OUT STD_LOGIC;
        radar_din: IN STD_LOGIC_VECTOR (11 downto 0);
        radar_overflow: IN STD_LOGIC;        
        sw_mode : IN STD_LOGIC;
        sw_resolution : IN STD_LOGIC;        
        btn_save : IN STD_LOGIC; 
        btn_record : IN STD_LOGIC;             
        btn_up : IN STD_LOGIC;
        btn_down : IN STD_LOGIC;
        i_miso : IN STD_LOGIC;
        o_cs : OUT STD_LOGIC;				
        o_mosi : OUT STD_LOGIC;			 			
        o_sclk : OUT STD_LOGIC;
        i_eth_tx_clk : IN  STD_LOGIC;
        i_eth_rx_d : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        i_eth_rx_err : IN  STD_LOGIC;
        i_eth_rx_dv : IN  STD_LOGIC;
        i_eth_rx_clk : IN  STD_LOGIC; 
        i_eth_col : IN  STD_LOGIC;
        i_eth_crs : IN  STD_LOGIC;          
        o_eth_mdc : OUT   STD_LOGIC;
        o_eth_rstn : OUT   STD_LOGIC;
        o_eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_eth_tx_en : OUT STD_LOGIC;            
        o_eth_ref_clk : OUT STD_LOGIC;
        io_eth_mdio : INOUT STD_LOGIC; 
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
        PORT(
            clk_in1: IN STD_LOGIC;
            resetn: IN STD_LOGIC;
            clk_25: OUT STD_LOGIC;
            clk_50: OUT STD_LOGIC;
            clk_81:  OUT STD_LOGIC;
            clk_200: OUT STD_LOGIC        
        );
    END COMPONENT;

    COMPONENT control
        GENERIC( 
            RES : INTEGER
        );
        PORT(
            rst : IN STD_LOGIC;
            clk: IN STD_LOGIC;
            sw_mode : IN STD_LOGIC;
            sw_resolution : IN STD_LOGIC;
            btn_record : IN STD_LOGIC;
            btn_save : IN STD_LOGIC;        
            btn_up : IN STD_LOGIC;
            btn_down : IN STD_LOGIC;
            en_acquire : OUT STD_LOGIC;
            en_save : OUT STD_LOGIC;
            resolution: OUT INTEGER;
            arming : OUT STD_LOGIC    
        );
    END COMPONENT;
    
    COMPONENT debouncer 
        PORT(
            clk : IN STD_LOGIC;
            i : IN STD_LOGIC;
            o : OUT STD_LOGIC
        );
    END COMPONENT; 
    
    COMPONENT demux2 
        PORT(
            sel : IN STD_LOGIC;
            i : IN STD_LOGIC;
            o0 : OUT STD_LOGIC;
            o1 : OUT STD_LOGIC
        ); 
    END COMPONENT; 
    
    COMPONENT demux2_32b 
        PORT(
            sel : IN STD_LOGIC;
            i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            o0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            o1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;  

    COMPONENT dram
       PORT( 
            rst : IN STD_LOGIC;
            clk_ref : IN STD_LOGIC;
            clk_81 : IN STD_LOGIC;
            clk_200 : IN STD_LOGIC;        
            din: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            dout: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            trigger: IN STD_LOGIC;
            wr_trigger : OUT STD_LOGIC;
            wr_trigger_ok : IN STD_LOGIC; 
            wr_continue : IN STD_LOGIC;
            wr_continue_ok : OUT STD_LOGIC;    
            i_buff_rd_en: OUT STD_LOGIC;
            i_buff_wr_en: OUT STD_LOGIC;
            i_buff_empty: IN STD_LOGIC;
            o_buff_wr_en: OUT STD_LOGIC;
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
        GENERIC( 
            DATA : INTEGER;
            PACKETS : INTEGER
        );
        PORT(
            rst : IN STD_LOGIC;
            clk: IN STD_LOGIC;                
            din: IN std_logic_vector(15 downto 0);         
            rd_trigger : IN STD_LOGIC;
            rd_trigger_ok : OUT STD_LOGIC;              
            rd_continue : OUT STD_LOGIC;              
            rd_continue_ok : IN STD_LOGIC;    
            i_buff_rd_en : OUT STD_LOGIC;   
            i_eth_tx_clk : IN  STD_LOGIC;
            i_eth_rx_d : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            i_eth_rx_err : IN  STD_LOGIC;
            i_eth_rx_dv : IN  STD_LOGIC;
            i_eth_rx_clk : IN  STD_LOGIC; 
            i_eth_col : IN  STD_LOGIC;
            i_eth_crs : IN  STD_LOGIC;           
            o_eth_mdc : OUT   STD_LOGIC;
            o_eth_rstn : OUT   STD_LOGIC;
            o_eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            o_eth_tx_en : OUT STD_LOGIC;            
            o_eth_ref_clk : OUT STD_LOGIC;
            io_eth_mdio : INOUT STD_LOGIC
        );  
    END COMPONENT;
    
    COMPONENT memory 
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
        GENERIC( 
            DATA : INTEGER
        );
        PORT(
            rst: IN STD_LOGIC;
            clk : IN STD_LOGIC;  
            clk_radar : IN STD_LOGIC;      
            en_acquire : IN STD_LOGIC;
            en_resolution : IN STD_LOGIC; 
            resolution: IN INTEGER;       
            din: IN STD_LOGIC_VECTOR (11 downto 0);
            overflow: IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            rd_trigger : IN STD_LOGIC;
            wr_trigger : OUT STD_LOGIC  
        );
    END COMPONENT;

    SIGNAL btn_record_0 : STD_LOGIC := '0';
    SIGNAL btn_save_0 : STD_LOGIC := '0';
    SIGNAL btn_up_0 : STD_LOGIC := '0';
    SIGNAL btn_down_0 : STD_LOGIC := '0';
    
    SIGNAL clk_25 : STD_LOGIC := '0';
    SIGNAL clk_50 : STD_LOGIC := '0';
    SIGNAL clk_81 : STD_LOGIC := '0';
    SIGNAL clk_200 : STD_LOGIC := '0';
    
    SIGNAL resolution : INTEGER := 0;
    
    SIGNAL dram_dout  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); 
    SIGNAL dram_trigger : STD_LOGIC := '0';
    SIGNAL dram_wr_trigger : STD_LOGIC := '0';
    SIGNAL dram_wr_trigger_ok : STD_LOGIC := '0'; 
    SIGNAL dram_wr_continue : STD_LOGIC := '0';
    SIGNAL dram_wr_continue_ok : STD_LOGIC := '0';
    SIGNAL dram_o_buff_wr_en : STD_LOGIC := '0';
    
    SIGNAL en_acquire : STD_LOGIC := '0';
    SIGNAL en_save : STD_LOGIC := '0';
    
    SIGNAL f_ref_81_din : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_ref_81_wr_en : STD_LOGIC := '0';
    SIGNAL f_ref_81_rd_en : STD_LOGIC := '0';
    SIGNAL f_ref_81_dout : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_ref_81_empty : STD_LOGIC := '0';
    
    SIGNAL f_81_50_din : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_81_50_wr_en : STD_LOGIC := '0';
    SIGNAL f_81_50_rd_en : STD_LOGIC := '0';
    SIGNAL f_81_50_dout : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
  
    SIGNAL f_50_eth_din : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_50_eth_wr_en : STD_LOGIC := '0';
    SIGNAL f_50_eth_rd_en : STD_LOGIC := '0';
    SIGNAL f_50_eth_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL f_81_eth_din : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL f_81_eth_wr_en : STD_LOGIC := '0';
    SIGNAL f_81_eth_rd_en : STD_LOGIC := '0';
    SIGNAL f_81_eth_dout : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
 
    SIGNAL interface_din : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL interface_rd_trigger : STD_LOGIC := '0';
    SIGNAL interface_rd_trigger_ok : STD_LOGIC := '0';              
    SIGNAL interface_rd_continue : STD_LOGIC := '0';             
    SIGNAL interface_rd_continue_ok : STD_LOGIC := '0'; 
    SIGNAL interface_i_buff_rd_en : STD_LOGIC := '0';
    
    SIGNAL memory_rd_trigger : STD_LOGIC := '0';
    SIGNAL memory_rd_trigger_ok : STD_LOGIC := '0';
    SIGNAL memory_rd_continue : STD_LOGIC := '0';
    SIGNAL memory_rd_continue_ok : STD_LOGIC := '0'; 
    SIGNAL memory_wr_trigger : STD_LOGIC := '0';
    SIGNAL memory_wr_trigger_ok : STD_LOGIC := '0';
    SIGNAL memory_wr_continue : STD_LOGIC := '0';
    SIGNAL memory_wr_continue_ok : STD_LOGIC := '0';

BEGIN

    clk_out <= clk_25;
        
    INST_CLK: clk_wiz_0
        PORT MAP(
            clk_in1 => clk,
            resetn => rst,
            clk_25 => clk_25,
            clk_50 => clk_50,
            clk_81 => clk_81,
            clk_200 => clk_200            
        );  

    INST_CONTROL : control
        GENERIC MAP( 
            RES => RES
        )   
        PORT MAP(
            rst => rst,
            clk => clk,
            sw_mode => sw_mode,
            sw_resolution => sw_resolution,
            btn_record=> btn_record_0,
            btn_save => btn_save_0,        
            btn_up => btn_up_0,
            btn_down => btn_down_0,
            en_acquire => en_acquire,
            en_save => en_save,
            resolution => resolution,
            arming => radar_arming
        );
        
    INST_DEBOUNCER_0 : debouncer 
        PORT MAP(
            clk => clk,
            i => btn_record,
            o => btn_record_0
        );
        
    INST_DEBOUNCER_1 : debouncer 
        PORT MAP(
            clk => clk,
            i => btn_save,
            o => btn_save_0
        );
        
    INST_DEBOUNCER_2 : debouncer 
        PORT MAP(
            clk => clk,
            i => btn_up,
            o => btn_up_0
        );
        
    INST_DEBOUNCER_3 : debouncer 
        PORT MAP(
            clk => clk,
            i => btn_down,
            o => btn_down_0
        );
    
    INST_DEMUX2_0 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => dram_wr_trigger,
            o0 => interface_rd_trigger,
            o1 => memory_rd_trigger
        );
        
    INST_DEMUX2_1 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => dram_wr_continue_ok,
            o0 => interface_rd_continue_ok,
            o1 => memory_rd_continue_ok
        );
                                
    INST_DEMUX2_2 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => interface_i_buff_rd_en,
            o0 => f_81_eth_rd_en,
            o1 => f_50_eth_rd_en
        );
        
    INST_DEMUX2_3 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => dram_o_buff_wr_en,
            o0 => f_81_eth_wr_en,
            o1 => f_81_50_wr_en
        );

    INST_DEMUX2_32B : demux2_32b 
        PORT MAP(
            sel => sw_mode,
            i => dram_dout,
            o0 => f_81_eth_din,
            o1 => f_81_50_din
        );       
          
    INST_DRAM : dram
         PORT MAP( 
            rst => rst,
            clk_ref => radar_clk,
            clk_81 => clk_81,
            clk_200 => clk_200,       
            din => f_ref_81_dout,
            dout => dram_dout,
            trigger => dram_trigger,
            wr_trigger => dram_wr_trigger,
            wr_trigger_ok => dram_wr_trigger_ok,
            wr_continue => dram_wr_continue,
            wr_continue_ok =>  dram_wr_continue_ok, 
            i_buff_rd_en => f_ref_81_rd_en,
            i_buff_wr_en => f_ref_81_wr_en,
            i_buff_empty => f_ref_81_empty,
            o_buff_wr_en => dram_o_buff_wr_en,
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
            io_ddr_data => io_ddr_data            
        );
    
    INST_FIFO_REF_81 : fifo_ref_81 
        PORT MAP(
            rst => rst,
            wr_clk => radar_clk,
            rd_clk => clk_81,
            din => f_ref_81_din,
            wr_en => f_ref_81_wr_en,
            rd_en => f_ref_81_rd_en,
            dout => f_ref_81_dout,
            full => OPEN,
            empty => f_ref_81_empty
        );

    INST_FIFO_81_50 : fifo_81_50 
        PORT MAP(
            rst => rst,
            wr_clk => clk_81,
            rd_clk => clk_50,
            din => f_81_50_din,
            wr_en => f_81_50_wr_en,
            rd_en => f_81_50_rd_en,
            dout => f_81_50_dout,
            full => OPEN,
            empty => OPEN
        );
        
    INST_FIFO_50_ETH : fifo_50_eth 
        PORT MAP(
            rst => rst,
            wr_clk => clk_50,
            rd_clk => i_eth_tx_clk,
            din => f_50_eth_din,
            wr_en => f_50_eth_wr_en,
            rd_en => f_50_eth_rd_en,
            dout => f_50_eth_dout,
            full => OPEN,
            empty => OPEN
        );
    
    INST_FIFO_81_ETH : fifo_81_eth 
        PORT MAP(
            rst => rst,
            wr_clk => clk_81,
            rd_clk => i_eth_tx_clk,
            din => f_81_eth_din,
            wr_en => f_81_eth_wr_en,
            rd_en => f_81_eth_rd_en,
            dout => f_81_eth_dout,
            full => OPEN,
            empty => OPEN
        );
   
   INST_MUX2_0 : mux2 
        PORT MAP(
            sel => sw_mode,
            i0 => interface_rd_trigger_ok,
            i1 => memory_rd_trigger_ok,
            o => dram_wr_trigger_ok
        );

    INST_MUX2_1 : mux2 
        PORT MAP(
            sel => sw_mode,
            i0 => interface_rd_continue,
            i1 => memory_rd_continue,
            o => dram_wr_continue
        );

    INST_MUX2_16B : mux2_16b 
        PORT MAP(
            sel => sw_mode,
            i0 => f_81_eth_dout,
            i1 => f_50_eth_dout,
            o => interface_din
        );
        
    INST_INTERFACE : interface
        GENERIC MAP( 
            DATA => DATA,
            PACKETS => PACKETS
        )
        PORT MAP(
            rst => rst,
            clk => clk,                       
            din => interface_din,           
            rd_trigger => interface_rd_trigger,
            rd_trigger_ok => interface_rd_trigger_ok,              
            rd_continue => interface_rd_continue,             
            rd_continue_ok => interface_rd_continue_ok,
            i_buff_rd_en => interface_i_buff_rd_en,                 
            i_eth_tx_clk => i_eth_tx_clk,         
            i_eth_rx_d => i_eth_rx_d,
            i_eth_rx_err => i_eth_rx_err,
            i_eth_rx_dv => i_eth_rx_dv,
            i_eth_rx_clk => i_eth_rx_clk,
            i_eth_col => i_eth_col,
            i_eth_crs => i_eth_crs,           
            o_eth_mdc => o_eth_mdc,
            o_eth_rstn => o_eth_rstn,           
            o_eth_tx_d => o_eth_tx_d,
            o_eth_tx_en => o_eth_tx_en,            
            o_eth_ref_clk => o_eth_ref_clk,
            io_eth_mdio => io_eth_mdio
        );  
        
    INST_MEMORY : memory 
        GENERIC MAP( 
            DATA => DATA,
            PACKETS => PACKETS
        )
        PORT MAP(
            rst => rst,
            clk_50 => clk_50,            
            din => f_81_50_dout,
            dout => f_50_eth_din,    
            rd_trigger => memory_rd_trigger,
            rd_trigger_ok =>  memory_rd_trigger_ok,
            rd_continue =>  memory_rd_continue,
            rd_continue_ok =>  memory_rd_continue_ok, 
            wr_trigger =>  memory_wr_trigger,
            wr_trigger_ok =>  memory_wr_trigger_ok,
            wr_continue =>  memory_wr_continue,
            wr_continue_ok =>  memory_wr_continue_ok,
            i_buff_rd_en => f_81_50_rd_en,     
            o_buff_wr_en=> f_50_eth_wr_en,     
            i_miso => i_miso,
            o_cs => o_cs,			
            o_mosi => o_mosi,		
            o_sclk => o_sclk
        );
    
    INST_PROCESSING : processing
        GENERIC MAP( 
            DATA => DATA
        )
        PORT MAP(
            rst => rst,
            clk => clk,
            clk_radar => radar_clk,            
            en_acquire => en_acquire,
            en_resolution =>  sw_resolution,    
            resolution => resolution,
            din => radar_din,
            overflow => radar_overflow,
            dout => f_ref_81_din,
            rd_trigger => radar_trigger,
            wr_trigger => dram_trigger     
        );

END behavioral;
