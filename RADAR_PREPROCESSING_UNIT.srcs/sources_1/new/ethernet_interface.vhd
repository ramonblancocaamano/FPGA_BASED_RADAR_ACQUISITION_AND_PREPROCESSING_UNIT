----------------------------------------------------------------------------------
-- @FILE : ethernet_interface.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: MANAGEMENT OF ETHERNET INTERFACE.
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ethernet_interface IS
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
END ethernet_interface;

ARCHITECTURE behavioral OF ethernet_interface IS

    COMPONENT enable
        PORT(
            en : IN STD_LOGIC;
            i0 : IN STD_LOGIC;
            o : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT enable_16b
        PORT(
            en : IN STD_LOGIC;
            i0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
            o : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ethernet
        GENERIC( 
            ETH_SRC_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0);
            ETH_DST_MAC : STD_LOGIC_VECTOR(47 DOWNTO 0);
            IP_SRC_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
            IP_DST_ADDR : STD_LOGIC_VECTOR(31 DOWNTO 0);
            UPD_SRC_PORT : STD_LOGIC_VECTOR(15 DOWNTO 0);
            UDP_DST_PORT : STD_LOGIC_VECTOR(15 DOWNTO 0);
            PAYLOAD: INTEGER;
            LOWER_BOUND : UNSIGNED (11 DOWNTO 0);
            HIGHER_BOUND : UNSIGNED (11 DOWNTO 0) 
        );
        PORT( 
            clock : IN STD_LOGIC; 
            data_16b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);      
            eth_rstn : OUT STD_LOGIC := '1';
            eth_tx_d : OUT STD_LOGIC_VECTOR := (OTHERS => '0');
            eth_tx_en : OUT STD_LOGIC := '0';
            eth_tx_clk  : IN  STD_LOGIC;        
            eth_ref_clk : OUT STD_LOGIC;
            start: IN STD_LOGIC;
            counter : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)                              
           );
    END COMPONENT;
    
    COMPONENT ethernet_control 
        GENERIC( 
            NDATA : INTEGER;
            LOWER_BOUND : UNSIGNED (11 DOWNTO 0);
            HIGHER_BOUND : UNSIGNED (11 DOWNTO 0) 
        );
        PORT(
            rst : IN STD_LOGIC;
            clk: IN STD_LOGIC;   
            hsk_rd0 : IN STD_LOGIC;
            hsk_rd_ok0 : OUT STD_LOGIC;              
            hsk_wr0 : OUT STD_LOGIC;              
            hsk_wr_ok0 : IN STD_LOGIC;
            buff_rd_en : OUT STD_LOGIC;   
            eth_start : OUT STD_LOGIC;
            eth_counter : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
            eth_block : OUT STD_LOGIC    
        );
    END COMPONENT;
    
    SIGNAL buff_rd_en_0 : STD_LOGIC := '0';
    SIGNAL din_0 : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');   
    SIGNAL eth_start : STD_LOGIC := '0';
    SIGNAL eth_counter : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');  
    SIGNAL eth_block : STD_LOGIC := '0';
    SIGNAL wire_enable : STD_LOGIC := '0';

BEGIN

    wire_enable <= buff_empty OR eth_block;
    
    INST_ENABLE:  enable
        PORT MAP(
            en => wire_enable,
            i0 => buff_rd_en_0,
            o => buff_rd_en
        );
        
    INST_ENABLE_16B: enable_16b
        PORT MAP (
            en => eth_block,
            i0 => din, 
            o => din_0
        );

    INST_ETHERNET : ethernet
        GENERIC MAP( 
            ETH_SRC_MAC => ETH_SRC_MAC,
            ETH_DST_MAC => ETH_DST_MAC,
            IP_SRC_ADDR => IP_SRC_ADDR,
            IP_DST_ADDR => IP_DST_ADDR,
            UPD_SRC_PORT => UPD_SRC_PORT,
            UDP_DST_PORT => UDP_DST_PORT,
            PAYLOAD => PAYLOAD,
            LOWER_BOUND => LOWER_BOUND,
            HIGHER_BOUND => HIGHER_BOUND
        )
        PORT MAP(
            clock => clk,
            data_16b => din_0,
            eth_rstn => o_eth_rstn,
            eth_tx_d => o_eth_tx_d,
            eth_tx_en => o_eth_tx_en,
            eth_tx_clk => i_eth_tx_clk,
            eth_ref_clk => o_eth_ref_clk,
            start => eth_start,
            counter => eth_counter
        );
        
    INST_ETHERNET_CONTROL : ethernet_control
        GENERIC MAP( 
            NDATA => NDATA,
            LOWER_BOUND => LOWER_BOUND,
            HIGHER_BOUND => HIGHER_BOUND
        ) 
        PORT MAP(
            rst => rst,
            clk => i_eth_tx_clk,                            
            hsk_rd0 => hsk_rd0,
            hsk_rd_ok0 => hsk_rd_ok0,             
            hsk_wr0 => hsk_wr0,              
            hsk_wr_ok0 => hsk_wr_ok0,
            buff_rd_en => buff_rd_en_0,   
            eth_start => eth_start,
            eth_counter => eth_counter,
            eth_block => eth_block 
        );

END behavioral;

