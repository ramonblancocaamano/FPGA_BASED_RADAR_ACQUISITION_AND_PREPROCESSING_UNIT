-----------------------------------------------------------------------------------
-- @FILE : main.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: FPGA BASED RADAR ACQUISITION AND PREPROCESSING UNIT.
----------------------------------------------------------------------------------
LIBRARY IEEE;
LIBRARY UNISIM;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE UNISIM.VCOMPONENTS.ALL;

ENTITY main IS
    GENERIC( 
        NDATA : INTEGER := 4;
        NPACKETS : INTEGER := 32768;
        RES : INTEGER := 1;
        ETH_SRC_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0) := x"DEADBEEF0123"; -- RANDOM.
        ETH_DST_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0) := x"000EC6E1F958"; -- PC.
        IP_SRC_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"0A0A0A0A"; -- 10.10.10.10
        IP_DST_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"0A0A0A01"; -- 10.10.10.1
        UPD_SRC_PORT : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000"; -- 4096
        UDP_DST_PORT : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"1000" -- 4096
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
        o_eth_mdc : OUT   STD_LOGIC;
        o_eth_rstn : OUT   STD_LOGIC;
        o_eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_eth_tx_en : OUT STD_LOGIC;            
        o_eth_ref_clk : OUT STD_LOGIC;
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
            reset: IN STD_LOGIC;
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
    
    COMPONENT ddr3_memory
        PORT(
            rst : IN STD_LOGIC;
            clk_81 : IN STD_LOGIC;
            clk_200 : IN STD_LOGIC;        
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            hsk_rd0 : IN STD_LOGIC;
            hsk_rd1 : OUT STD_LOGIC;
            hsk_rd_ok1 : IN STD_LOGIC; 
            hsk_wr1 : IN STD_LOGIC;
            hsk_wr_ok1 : OUT STD_LOGIC;    
            buff_rd_en : OUT STD_LOGIC;
            buff_empty : IN STD_LOGIC;
            buff_wr_en : OUT STD_LOGIC;
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
    
    COMPONENT debouncer 
        PORT(
            rst : IN STD_LOGIC;
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
    
    COMPONENT demux2_en
        PORT(
            sel : IN STD_LOGIC;
            i : IN STD_LOGIC;
            en0 : IN STD_LOGIC;
            en1 :IN STD_LOGIC;
            o0 : OUT STD_LOGIC;
            o1 : OUT STD_LOGIC
        );
    END COMPONENT;
        
    COMPONENT ethernet_interface IS
        GENERIC( 
            NDATA : INTEGER;
            PAYLOAD: INTEGER := 1024;
            LOWER_BOUND : UNSIGNED(11 DOWNTO 0) := x"058";  
            HIGHER_BOUND : UNSIGNED(11 DOWNTO 0) := x"875"; 
            ETH_SRC_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0);
            ETH_DST_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0);
            IP_SRC_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
            IP_DST_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
            UPD_SRC_PORT : STD_LOGIC_VECTOR(15 DOWNTO 0);
            UDP_DST_PORT : STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
        PORT(
            rst : IN STD_LOGIC;
            clk: IN STD_LOGIC;                
            din: IN STD_LOGIC_VECTOR(15 DOWNTO 0);         
            hsk_rd0 : IN STD_LOGIC;
            hsk_rd_ok0 : OUT STD_LOGIC;              
            hsk_wr0 : OUT STD_LOGIC;              
            hsk_wr_ok0 : IN STD_LOGIC;    
            buff_rd_en : OUT STD_LOGIC;   
            buff_empty : IN STD_LOGIC;
            i_eth_tx_clk : IN  STD_LOGIC;  
            o_eth_rstn : OUT   STD_LOGIC;
            o_eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            o_eth_tx_en : OUT STD_LOGIC;            
            o_eth_ref_clk : OUT STD_LOGIC
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
    
    COMPONENT holder 
        PORT(
            rst : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            i : IN STD_LOGIC;
            o : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT interface
        GENERIC( 
            DATA : INTEGER;
            PACKETS : INTEGER;
            ETH_SRC_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0);
            ETH_DST_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0);
            IP_SRC_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
            IP_DST_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0)
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
    
    COMPONENT mux2_en
        PORT(
            sel : IN STD_LOGIC;
            i0 : IN STD_LOGIC;
            i1 : IN STD_LOGIC;
            en0 : IN STD_LOGIC;
            en1 :IN STD_LOGIC;
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
            NDATA : INTEGER
        );
        PORT(
            rst: IN STD_LOGIC; 
            clk_radar : IN STD_LOGIC; 
            trigger_radar : IN STD_LOGIC;     
            en_acquire : IN STD_LOGIC;
            en_resolution : IN STD_LOGIC; 
            resolution: IN INTEGER;       
            din: IN STD_LOGIC_VECTOR (11 downto 0);
            overflow: IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            hsk_rd1 : OUT STD_LOGIC;
            hsk_rd_ok1 : IN STD_LOGIC;     
            buff_wr_en : OUT STD_LOGIC 
        );
    END COMPONENT;
    
    COMPONENT sd_memory
        GENERIC( 
            NDATA : INTEGER;
            NPACKETS : INTEGER
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
    END COMPONENT;

    SIGNAL btn_record_0 : STD_LOGIC := '0';
    SIGNAL btn_save_0 : STD_LOGIC := '0';
    SIGNAL btn_up_0 : STD_LOGIC := '0';
    SIGNAL btn_down_0 : STD_LOGIC := '0';
    SIGNAL radar_arming_0 : STD_LOGIC := '0';
    
    SIGNAL clk_25 : STD_LOGIC := '0';
    SIGNAL clk_50 : STD_LOGIC := '0';
    SIGNAL clk_81 : STD_LOGIC := '0';
    SIGNAL clk_200 : STD_LOGIC := '0';
    
    SIGNAL resolution : INTEGER := 0;
    SIGNAL en_acquire : STD_LOGIC := '0';
    SIGNAL en_save : STD_LOGIC := '0';
    
    SIGNAL processing_data_out : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ddr3_memory_data_in : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');    
    SIGNAL ddr3_memory_data_out_0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ddr3_memory_data_out  : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_memory_data_in_0 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_memory_data_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_memory_data_out_0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sd_memory_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ethernet_interface_data_in_0 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ethernet_interface_data_in : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); 
    
    
    SIGNAL buff_ddr3_memory_ethernet_interface_wr_en : STD_LOGIC := '0'; 
    SIGNAL buff_ddr3_memory_sd_memory_wr_en : STD_LOGIC := '0';
    SIGNAL buff_ethernet_interface_ddr3_memory_rd_en : STD_LOGIC := '0';
    SIGNAL buff_ethernet_interface_sd_memory_rd_en : STD_LOGIC := '0';
    
    SIGNAL hsk_processing_rd1 : STD_LOGIC := '0';
    SIGNAL buff_processing_wr_en : STD_LOGIC := '0';
    
    SIGNAL hsk_ddr3_memory_rd1 : STD_LOGIC := '0';
    SIGNAL hsk_ddr3_memory_rd_ok1 : STD_LOGIC := '0'; 
    SIGNAL hsk_ddr3_memory_wr1 : STD_LOGIC := '0';
    SIGNAL hsk_ddr3_memory_wr_ok1 : STD_LOGIC := '0';
    SIGNAL buff_ddr3_memory_wr_en : STD_LOGIC := '0';
    SIGNAL buff_ddr3_memory_rd_en : STD_LOGIC := '0';
    SIGNAL buff_ddr3_memory_empty : STD_LOGIC := '0';

    SIGNAL hsk_ethernet_interface_rd0_0 : STD_LOGIC := '0';
    SIGNAL hsk_ethernet_interface_rd_ok0_0 : STD_LOGIC := '0';
    SIGNAL hsk_ethernet_interface_wr0_0 : STD_LOGIC := '0';
    SIGNAL hsk_ethernet_interface_wr_ok0_0 : STD_LOGIC := '0';
    SIGNAL hsk_ethernet_interface_rd0 : STD_LOGIC := '0';
    SIGNAL hsk_ethernet_interface_rd_ok0 : STD_LOGIC := '0';              
    SIGNAL hsk_ethernet_interface_wr0 : STD_LOGIC := '0';              
    SIGNAL hsk_ethernet_interface_wr_ok0 : STD_LOGIC := '0'; 
    SIGNAL buff_ethernet_interface_rd_en : STD_LOGIC := '0';
    SIGNAL buff_ethernet_interface_empty : STD_LOGIC := '0';
    
    SIGNAL hsk_sd_memory_rd0 : STD_LOGIC := '0';
    SIGNAL hsk_sd_memory_rd_ok0 : STD_LOGIC := '0';
    SIGNAL hsk_sd_memory_wr0 : STD_LOGIC := '0';
    SIGNAL hsk_sd_memory_wr_ok0 : STD_LOGIC := '0'; 
    SIGNAL hsk_sd_memory_rd1 : STD_LOGIC := '0';
    SIGNAL hsk_sd_memory_rd_ok1 : STD_LOGIC := '0';
    SIGNAL hsk_sd_memory_wr1 : STD_LOGIC := '0';
    SIGNAL hsk_sd_memory_wr_ok1 : STD_LOGIC := '0';
    SIGNAL buff_sd_memory_rd_en : STD_LOGIC := '0';
    SIGNAL buff_sd_memory_wr_en : STD_LOGIC := '0';

BEGIN

    clk_out <= clk_25;
        
    INST_CLK: clk_wiz_0
        PORT MAP(
            clk_in1 => clk,
            reset => rst,
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
            arming => radar_arming_0
        );
        
    INST_DEBOUNCER_0 : debouncer 
        PORT MAP(
            rst => rst,
            clk => clk,
            i => btn_record,
            o => btn_record_0
        );
        
    INST_DEBOUNCER_1 : debouncer 
        PORT MAP(
            rst => rst,
            clk => clk,
            i => btn_save,
            o => btn_save_0
        );
        
    INST_DEBOUNCER_2 : debouncer 
        PORT MAP(
            rst => rst,
            clk => clk,
            i => btn_up,
            o => btn_up_0
        );
        
    INST_DEBOUNCER_3 : debouncer 
        PORT MAP(
            rst => rst,
            clk => clk,
            i => btn_down,
            o => btn_down_0
        );
    
    INST_DEMUX2_0 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => hsk_ddr3_memory_rd1,
            o0 => hsk_ethernet_interface_rd0_0,
            o1 => hsk_sd_memory_rd0
        );
        
    INST_DEMUX2_1 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => hsk_ddr3_memory_wr_ok1,
            o0 => hsk_ethernet_interface_wr_ok0_0,
            o1 => hsk_sd_memory_wr_ok0
        );
                                
    INST_DEMUX2_2 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => buff_ethernet_interface_rd_en,
            o0 => buff_ethernet_interface_ddr3_memory_rd_en,
            o1 => buff_ethernet_interface_sd_memory_rd_en
        );
       
    INST_DEMUX2_3 : demux2 
        PORT MAP(
            sel => sw_mode,
            i => buff_ddr3_memory_wr_en,
            o0 => buff_ddr3_memory_ethernet_interface_wr_en,
            o1 => buff_ddr3_memory_sd_memory_wr_en
        );

    INST_DEMUX2_32B : demux2_32b 
        PORT MAP(
            sel => sw_mode,
            i => ddr3_memory_data_out,
            o0 => ethernet_interface_data_in_0,
            o1 => sd_memory_data_in_0
        );
        
    INST_DEMUX2_EN_0 : demux2_en
        PORT MAP (
            sel => sw_mode,
            i => hsk_ethernet_interface_rd_ok0,
            en0 => '1',
            en1 => en_save,
            o0 => hsk_ethernet_interface_rd_ok0_0,
            o1 => hsk_sd_memory_rd_ok1
        );
        
    INST_DEMUX2_EN_1 : demux2_en
        PORT MAP (
            sel => sw_mode,
            i => hsk_ethernet_interface_wr0,
            en0 => '1',
            en1 => en_save,
            o0 => hsk_ethernet_interface_wr0_0,
            o1 => hsk_sd_memory_wr1
        );       
                  
    INST_DDR3_MEMORY : ddr3_memory
        PORT MAP(
            rst => rst,
            clk_81 => clk_81,
            clk_200 => clk_200,         
            din => ddr3_memory_data_in,
            dout => ddr3_memory_data_out,
            hsk_rd0 => hsk_processing_rd1,
            hsk_rd1 => hsk_ddr3_memory_rd1,
            hsk_rd_ok1 => hsk_ddr3_memory_rd_ok1,
            hsk_wr1 => hsk_ddr3_memory_wr1,
            hsk_wr_ok1 => hsk_ddr3_memory_wr_ok1,   
            buff_rd_en => buff_ddr3_memory_rd_en,
            buff_empty => buff_ddr3_memory_empty,
            buff_wr_en => buff_ddr3_memory_wr_en,
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

        
    INST_ETHERNET_INTERFACE : ethernet_interface
        GENERIC MAP( 
            NDATA => NDATA, 
            ETH_SRC_MAC => ETH_SRC_MAC,
            ETH_DST_MAC => ETH_DST_MAC,
            IP_SRC_ADDR => IP_SRC_ADDR,
            IP_DST_ADDR => IP_DST_ADDR,
            UPD_SRC_PORT => UPD_SRC_PORT,
            UDP_DST_PORT => UDP_DST_PORT
        )
        PORT MAP(
            rst => rst,
            clk => clk,               
            din => ethernet_interface_data_in,         
            hsk_rd0 => hsk_ethernet_interface_rd0,
            hsk_rd_ok0 => hsk_ethernet_interface_rd_ok0,              
            hsk_wr0 => hsk_ethernet_interface_wr0,              
            hsk_wr_ok0 => hsk_ethernet_interface_wr_ok0,   
            buff_rd_en => buff_ethernet_interface_rd_en,  
            buff_empty => buff_ethernet_interface_empty,
            i_eth_tx_clk => i_eth_tx_clk,  
            o_eth_rstn => o_eth_rstn,
            o_eth_tx_d => o_eth_tx_d,
            o_eth_tx_en => o_eth_tx_en,          
            o_eth_ref_clk => o_eth_ref_clk
        ); 
         
    INST_FIFO_REF_81 : fifo_ref_81 
        PORT MAP(
            rst => rst,
            wr_clk => radar_clk,
            rd_clk => clk_81,
            din => processing_data_out,
            wr_en => buff_processing_wr_en,
            rd_en => buff_ddr3_memory_rd_en,
            dout => ddr3_memory_data_in,
            full => OPEN,
            empty => buff_ddr3_memory_empty
        );

    INST_FIFO_81_50 : fifo_81_50 
        PORT MAP(
            rst => rst,
            wr_clk => clk_81,
            rd_clk => clk_50,
            din => sd_memory_data_in_0,
            wr_en => buff_ddr3_memory_sd_memory_wr_en,
            rd_en => buff_sd_memory_rd_en,
            dout => sd_memory_data_in,
            full => OPEN,
            empty => OPEN
        );
        
    INST_FIFO_50_ETH : fifo_50_eth 
        PORT MAP(
            rst => rst,
            wr_clk => clk_50,
            rd_clk => i_eth_tx_clk,
            din => sd_memory_data_out,
            wr_en => buff_sd_memory_wr_en,
            rd_en => buff_ethernet_interface_sd_memory_rd_en,
            dout => sd_memory_data_out_0,
            full => OPEN,
            empty => OPEN
        );
    
    INST_FIFO_81_ETH : fifo_81_eth 
        PORT MAP(
            rst => rst,
            wr_clk => clk_81,
            rd_clk => i_eth_tx_clk,
            din => ethernet_interface_data_in_0,
            wr_en => buff_ddr3_memory_ethernet_interface_wr_en,
            rd_en => buff_ethernet_interface_ddr3_memory_rd_en,
            dout => ddr3_memory_data_out_0,
            full => OPEN,
            empty => OPEN
        );
      
    INST_HOLDER : holder 
        PORT MAP(
            rst => rst,
            clk => clk,
            i => radar_arming_0,
            o => radar_arming
        );
             
   INST_MUX2_0 : mux2 
        PORT MAP(
            sel => sw_mode,
            i0 => hsk_ethernet_interface_rd_ok0_0,
            i1 => hsk_sd_memory_rd_ok0,
            o => hsk_ddr3_memory_rd_ok1
        );
                
    INST_MUX2_1 : mux2 
        PORT MAP(
            sel => sw_mode,
            i0 => hsk_ethernet_interface_wr0_0,
            i1 => hsk_sd_memory_wr0,
            o => hsk_ddr3_memory_wr1
        );
        
    INST_MUX2_16B : mux2_16b 
        PORT MAP(
            sel => sw_mode,
            i0 => ddr3_memory_data_out_0,
            i1 => sd_memory_data_out_0,
            o => ethernet_interface_data_in
        );
    
    INST_MUX2_EN_0 : mux2_en
        PORT MAP(
            sel => sw_mode,
            i0 => hsk_ethernet_interface_rd0_0,
            i1 => hsk_sd_memory_rd1,
            en0 => '1',
            en1 => en_save,
            o => hsk_ethernet_interface_rd0
        );
     
   INST_MUX2_EN_1 : mux2_en
        PORT MAP(
            sel => sw_mode,
            i0 => hsk_ethernet_interface_wr_ok0_0,
            i1 => hsk_sd_memory_wr_ok1,
            en0 => '1',
            en1 => en_save,
            o => hsk_ethernet_interface_wr_ok0
        );
    
    INST_PROCESSING : processing
        GENERIC MAP( 
            NDATA => NDATA
        )
        PORT MAP(
            rst => rst, 
            clk_radar => radar_clk,
            trigger_radar => radar_trigger,     
            en_acquire => en_acquire,
            en_resolution => sw_resolution,
            resolution => resolution,      
            din => radar_din,
            overflow => radar_overflow,
            dout => processing_data_out,
            hsk_rd1 => hsk_processing_rd1,
            hsk_rd_ok1 => '1',  
            buff_wr_en => buff_processing_wr_en  
        );
        
        
    INST_SD_MEMORY : sd_memory
        GENERIC MAP( 
            NDATA => NDATA,
            NPACKETS => NPACKETS
        )
        PORT MAP(
            rst => rst,
            clk_50 => clk_50,
            din => sd_memory_data_in,
            dout => sd_memory_data_out,
            hsk_rd0 => hsk_sd_memory_rd0,
            hsk_rd_ok0 => hsk_sd_memory_rd_ok0,
            hsk_wr0 => hsk_sd_memory_wr0,
            hsk_wr_ok0 => hsk_sd_memory_wr_ok0,
            hsk_rd1 => hsk_sd_memory_rd1,
            hsk_rd_ok1 => hsk_sd_memory_rd_ok1,
            hsk_wr1 => hsk_sd_memory_wr1,
            hsk_wr_ok1 => hsk_sd_memory_wr_ok1,
            buff_rd_en => buff_sd_memory_rd_en,       
            buff_wr_en => buff_sd_memory_wr_en,   
            i_miso => i_miso,    
            o_cs =>	o_cs,			
            o_mosi => o_mosi,					
            o_sclk => o_sclk
        );

END behavioral;
