----------------------------------------------------------------------------------
-- @FILE : ddr3_memory.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: INTERMEDIATE VOLATILE MEMORY BETWEEN MEMORY & INTERFACE MODULES.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ddr3_memory IS
    PORT(
        rst : IN STD_LOGIC;
        clk_81 : IN STD_LOGIC;
        clk_200 : IN STD_LOGIC;        
        din: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        hsk_rd0 : IN STD_LOGIC;
        hsk_rd1 : OUT STD_LOGIC;
        hsk_rd_ok1 : IN STD_LOGIC; 
        hsk_wr1 : IN STD_LOGIC;
        hsk_wr_ok1 : OUT STD_LOGIC;    
        buff_rd_en: OUT STD_LOGIC;
        buff_empty: IN STD_LOGIC;
        buff_wr_en: OUT STD_LOGIC;
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
END ddr3_memory;

ARCHITECTURE behavioral OF ddr3_memory IS

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
    
    COMPONENT ddr3_control IS
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
        clk_81 : IN STD_LOGIC;        
        dout: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        hsk_rd0: IN STD_LOGIC; 
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
            i_wb_sel:  IN STD_LOGIC_VECTOR((SELW-1) DOWNTO 0);
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
    
    SIGNAL dram_rst : STD_LOGIC := '0';
    SIGNAL dram_wb_cyc : STD_LOGIC := '0';
    SIGNAL dram_wb_stb : STD_LOGIC := '0';
    SIGNAL dram_wb_we : STD_LOGIC := '0';   
    SIGNAL dram_wb_addr : STD_LOGIC_VECTOR((AW-1) DOWNTO 0) := (OTHERS => '0');
    SIGNAL dram_wb_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dram_wb_ack : STD_LOGIC := '0';
    SIGNAL dram_wb_stall : STD_LOGIC := '0'; 
    SIGNAL dram_wb_sel:  STD_LOGIC_VECTOR((SELW-1) DOWNTO 0) := (OTHERS => '1');
    
    SIGNAL start : STD_LOGIC := '0';
    
BEGIN
    
    INST_DDR3_CONTROL : ddr3_control
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
            clk_81 => clk_81, 
            dout => dout,
            hsk_rd0 => hsk_rd0,
            hsk_rd1 => hsk_rd1,
            hsk_rd_ok1 => hsk_rd_ok1,  
            hsk_wr1 => hsk_wr1,
            hsk_wr_ok1 => hsk_wr_ok1,
            buff_rd_en => buff_rd_en,
            buff_empty => buff_empty,            
            buff_wr_en => buff_wr_en,
            dram_rst => dram_rst,           
            dram_wb_cyc => dram_wb_cyc,
            dram_wb_stb => dram_wb_stb,
            dram_wb_we => dram_wb_we,
            dram_wb_addr => dram_wb_addr,
            dram_wb_data => dram_wb_data,
            dram_wb_ack => dram_wb_ack,
            dram_wb_stall => dram_wb_stall
        );

    INST_MIG_DDR3 : mig_sdram
        PORT MAP(
            i_clk => clk_81,
            i_clk_200mhz => clk_200,
            i_rst => dram_rst,
            i_wb_cyc => dram_wb_cyc,
            i_wb_stb => dram_wb_stb,
            i_wb_we => dram_wb_we,
            i_wb_addr => dram_wb_addr,
            i_wb_data => din,
            i_wb_sel => dram_wb_sel,
            o_wb_data => dram_wb_data,
            o_sys_clk => OPEN,
            o_wb_ack => dram_wb_ack,
            o_wb_stall => dram_wb_stall,
            o_wb_err => OPEN,
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