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
END dram;

ARCHITECTURE behavioral OF dram IS

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
            rst_system : IN STD_LOGIC; 
            clock_data : IN STD_LOGIC;        
            clock_i_dram : IN STD_LOGIC;       
            trigger : IN STD_LOGIC;        
            empty_fifo_dram : IN STD_LOGIC;        
            wr_fifo_dram : OUT STD_LOGIC;
            rd_fifo_dram : OUT STD_LOGIC;
            wr_fifo_sd : OUT STD_LOGIC;
            data_in_fifo_sd : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            start_sd : OUT STD_LOGIC;  
            start_sd_ok : IN STD_LOGIC;
            continue_sd : IN STD_LOGIC;       
            continue_sd_ok : OUT STD_LOGIC;
            cont_full_dram : INTEGER;            
            start_dram : STD_LOGIC;    
            rst_dram : STD_LOGIC;
            cyc_dram : STD_LOGIC;
            stb_dram : STD_LOGIC;
            we_dram : STD_LOGIC;
            addr_dram : STD_LOGIC_VECTOR ((AW-1) DOWNTO 0);
            ack_dram : STD_LOGIC;    
            stall_dram : STD_LOGIC;    
            error_dram : STD_LOGIC;    
            sel_dram : STD_LOGIC_VECTOR((SELW-1) DOWNTO 0);    
            data_out_dram : STD_LOGIC_VECTOR(31 DOWNTO 0);    
            start_sd_inst : STD_LOGIC;    
            continue_sd_ok_inst : STD_LOGIC;    
            dram_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0);
            fifo_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0)          
        );
    END COMPONENT;

    COMPONENT migsdram 
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
            i_wb_sel :  IN STD_LOGIC_VECTOR((SELW-1) DOWNTO 0);
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
    
    SIGNAL cont_full_dram : INTEGER := 0;
    SIGNAL start_dram : STD_LOGIC := '0';    
    SIGNAL rst_dram : STD_LOGIC := '1';
    SIGNAL cyc_dram : STD_LOGIC := '0';
    SIGNAL stb_dram : STD_LOGIC := '0';
    SIGNAL we_dram : STD_LOGIC := '0';
    SIGNAL addr_dram : STD_LOGIC_VECTOR ((AW-1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL ack_dram : STD_LOGIC := '0';    
    SIGNAL stall_dram : STD_LOGIC := '0';    
    SIGNAL error_dram : STD_LOGIC := '0';    
    SIGNAL sel_dram : STD_LOGIC_VECTOR((SELW-1) DOWNTO 0) := (OTHERS => '0');     
    SIGNAL data_out_dram : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');    
    SIGNAL start_sd_inst : STD_LOGIC := '0';    
    SIGNAL continue_sd_ok_inst : STD_LOGIC := '0';    
    SIGNAL dram_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');   
    SIGNAL fifo_fsm : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');   

BEGIN

    start_sd <= start_sd_inst;
    continue_sd_ok <= continue_sd_ok_inst;
    
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
            rst_system  => rst_system,
            clock_data  => clock_data,    
            clock_i_dram => clock_i_dram,     
            trigger  => trigger,     
            empty_fifo_dram => empty_fifo_dram,       
            wr_fifo_dram => wr_fifo_dram,
            rd_fifo_dram => rd_fifo_dram,
            wr_fifo_sd => wr_fifo_sd,
            data_in_fifo_sd => data_in_fifo_sd,
            start_sd => start_sd,
            start_sd_ok => start_sd_ok,
            continue_sd => continue_sd,       
            continue_sd_ok => continue_sd_ok,
            cont_full_dram => cont_full_dram,
            start_dram => start_dram, 
            rst_dram => rst_dram,
            cyc_dram => cyc_dram,
            stb_dram => stb_dram,
            we_dram => we_dram,
            addr_dram => addr_dram,
            ack_dram => ack_dram, 
            stall_dram => stall_dram,   
            error_dram => error_dram,    
            sel_dram => sel_dram,    
            data_out_dram => data_out_dram, 
            start_sd_inst => start_sd_inst,
            continue_sd_ok_inst => continue_sd_ok_inst,   
            dram_fsm => dram_fsm,
            fifo_fsm => fifo_fsm    
        );

    INST_ILA_0 : ila_0
        PORT MAP(
            clk => clock_i_dram,
            probe0 => trigger,
            probe1 => start_dram,
            probe2 => rst_system,
            probe3 => rst_dram,
            probe4 => cyc_dram,
            probe5 => stb_dram,
            probe6 => we_dram,
            probe7 => dram_fsm,
            probe8 => data_in_dram,
            probe9 => cont_full_dram,
            probe10 => fifo_fsm (4 downto 0),
            probe11 => addr_dram (11 downto 0),
            probe12 => continue_sd_ok_inst,
            probe13 => start_sd_inst,
            probe14 => start_sd_ok,
            probe15 => continue_sd
        );

    INST_MIGSDRAM : migsdram
        PORT MAP(
            i_clk => clock_i_dram,
            i_clk_200mhz => clock_200,
            i_rst => rst_dram,
            i_wb_cyc => cyc_dram,
            i_wb_stb => stb_dram,
            i_wb_we => we_dram,
            i_wb_addr => addr_dram,
            i_wb_data => data_in_dram,
            i_wb_sel => sel_dram,
            o_wb_data => data_out_dram,
            o_sys_clk => clock_o_dram,
            o_wb_ack => ack_dram,
            o_wb_stall => stall_dram,
            o_wb_err => error_dram,
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
