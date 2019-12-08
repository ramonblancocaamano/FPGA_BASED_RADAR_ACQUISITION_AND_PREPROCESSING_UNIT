----------------------------------------------------------------------------------
-- @FILE : dram.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY dram IS
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
END dram;

ARCHITECTURE behavioral OF dram IS

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
    
    COMPONENT dram_control IS
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
    END COMPONENT;

    COMPONENT mig_sdram 
        PORT(
            i_clk : IN STD_LOGIC;
            i_clk_200mhz : IN STD_LOGIC;
            i_rst : IN STD_LOGIC;
            i_wb_cyc : IN STD_LOGIC;
            i_wb_stb : IN STD_LOGIC;
            i_wb_we : IN STD_LOGIC;
            o_sys_clk : OUT STD_LOGIC;
            o_wb_ack : OUT STD_LOGIC;
            o_wb_stall : OUT STD_LOGIC;
            o_wb_err : OUT STD_LOGIC;
            o_ddr_reset_n : OUT STD_LOGIC;
            o_ddr_ras_n : OUT STD_LOGIC;
            o_ddr_cas_n : OUT STD_LOGIC;
            o_ddr_we_n : OUT STD_LOGIC;
            i_wb_addr : IN STD_LOGIC_VECTOR((AW-1) DOWNTO 0);
            i_wb_data : IN STD_LOGIC_VECTOR((DW-1) DOWNTO 0);
            i_wb_sel:  in STD_LOGIC_VECTOR((SELW-1) DOWNTO 0);
            o_wb_data : OUT STD_LOGIC_VECTOR((DW-1) DOWNTO 0);
            o_ddr_ck_p : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_ck_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_cke : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_cs_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_odt : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            o_ddr_ba : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            o_ddr_addr : OUT STD_LOGIC_VECTOR(13 downto 0);
            o_ddr_dm : OUT STD_LOGIC_VECTOR((DDRWIDTH/8-1) DOWNTO 0);
            io_ddr_dqs_p : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            io_ddr_dqs_n : INOUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            io_ddr_data : INOUT STD_LOGIC_VECTOR((DDRWIDTH-1) DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ila_0
        PORT(
            clk: IN STD_LOGIC;
            probe0 : IN STD_LOGIC;
            probe1 : IN STD_LOGIC;
            probe2 : IN STD_LOGIC;
            probe3 : IN STD_LOGIC;
            probe4 : IN STD_LOGIC;
            probe5 : IN STD_LOGIC;
            probe6 : IN STD_LOGIC;
            probe7 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            probe8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            probe9 : IN INTEGER;
            probe10 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            probe11 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            probe12 : IN STD_LOGIC;
            probe13 : IN STD_LOGIC;
            probe14 : IN STD_LOGIC;
            probe15 : IN STD_LOGIC
        );
    END COMPONENT;
    
    SIGNAL dram_wr_trigger : STD_LOGIC := '0';
    SIGNAL dram_wr_continue_ok : STD_LOGIC := '0';
    SIGNAL i_rst : STD_LOGIC := '0';
    SIGNAL i_wb_cyc : STD_LOGIC := '0';
    SIGNAL i_wb_stb : STD_LOGIC := '0';
    SIGNAL i_wb_we : STD_LOGIC := '0';
    SIGNAL i_wb_addr : STD_LOGIC_VECTOR((AW-1) DOWNTO 0);
    SIGNAL o_wb_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL o_wb_ack : STD_LOGIC;
    SIGNAL o_wb_stall : STD_LOGIC;       
    SIGNAL o_wb_err : STD_LOGIC;
    SIGNAL counter : INTEGER;
    SIGNAL start : STD_LOGIC;
    SIGNAL dram_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fifo_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0); 
    
BEGIN

    wr_trigger <= dram_wr_trigger;
    wr_continue_ok <= dram_wr_continue_ok; 
    
    INST_DRAM_CONTROL : dram_control
        GENERIC MAP( 
            AW => AW,
            DDRWIDTH => DDRWIDTH, 
            NDATA => NDATA, 
            NACK => NACK,            
            DW => DW,
            SELW => SELW
        )    
        PORT MAP(
            rst  => rst,           
            clk_ref => clk_ref,
            clk_81 => clk_81, 
            dout => dout,
            trigger => trigger,
            wr_trigger => dram_wr_trigger,
            wr_trigger_ok => wr_trigger_ok,  
            wr_continue => wr_continue,
            wr_continue_ok => dram_wr_continue_ok,
            i_buff_rd_en => i_buff_rd_en,
            i_buff_wr_en => i_buff_wr_en,
            i_buff_empty => i_buff_empty,
            i_rst => i_rst,           
            i_wb_cyc => i_wb_cyc,
            i_wb_stb => i_wb_stb,
            i_wb_we => i_wb_we,
            i_wb_addr => i_wb_addr,
            o_buff_wr_en => o_buff_wr_en,
            o_wb_data => o_wb_data,
            o_wb_ack => o_wb_ack,
            o_wb_stall => o_wb_stall,
            o_wb_err => o_wb_err,           
            counter => counter,           
            start => start,    
            dram_fsm => dram_fsm,
            fifo_fsm => fifo_fsm   
        );

    INST_ILA_0 : ila_0
        PORT MAP(
            clk => clk_81,
            probe0 => trigger,
            probe1 => start,
            probe2 => rst,
            probe3 => i_rst,
            probe4 => i_wb_cyc,
            probe5 => i_wb_stb,
            probe6 => i_wb_we,
            probe7 => dram_fsm,
            probe8 => din,
            probe9 => counter,
            probe10 => fifo_fsm (4 downto 0),
            probe11 => i_wb_addr (11 downto 0),
            probe12 => dram_wr_continue_ok,
            probe13 => dram_wr_trigger,
            probe14 => wr_trigger_ok,
            probe15 => wr_continue
        );

    INST_MIG_SDRAM : mig_sdram
        PORT MAP(
            i_clk => clk_81,
            i_clk_200mhz => clk_200,
            i_rst => i_rst,
            i_wb_cyc => i_wb_cyc,
            i_wb_stb => i_wb_stb,
            i_wb_we => i_wb_we,
            i_wb_addr => i_wb_addr,
            i_wb_data => din,
            i_wb_sel => "1111",
            o_wb_data => o_wb_data,
            o_sys_clk => OPEN,
            o_wb_ack => o_wb_ack,
            o_wb_stall => o_wb_stall,
            o_wb_err => o_wb_err,
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
        
END behavioral;
