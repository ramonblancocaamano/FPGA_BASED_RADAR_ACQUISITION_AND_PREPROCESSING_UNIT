----------------------------------------------------------------------------------
-- @FILE : interface.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY interface IS
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
END interface;

ARCHITECTURE behavioral OF interface IS

    COMPONENT ethernet
        PORT( 
            clock : IN STD_LOGIC;        
            eth_mdio : INOUT STD_LOGIC := '0';
            eth_mdc : OUT STD_LOGIC := '0';
            eth_rstn : OUT STD_LOGIC := '1';           
            eth_tx_d : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
            eth_tx_en : OUT STD_LOGIC  := '0';
            eth_tx_clk : IN  STD_LOGIC;           
            eth_rx_d : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            eth_rx_err : IN STD_LOGIC;
            eth_rx_dv : IN STD_LOGIC;
            eth_rx_clk : IN STD_LOGIC;            
            eth_col : IN STD_LOGIC;
            eth_crs : IN STD_LOGIC;           
            eth_ref_clk : OUT STD_LOGIC;           
            start : IN STD_LOGIC;
            counter : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            data_16b: IN STD_LOGIC_VECTOR(15 DOWNTO 0)                      
           );
    END COMPONENT;
    
    COMPONENT ethernet_control 
        GENERIC( 
            DATA : INTEGER;
            PACKETS : INTEGER
        );
        PORT(
            rst : IN STD_LOGIC;
            clk: IN STD_LOGIC;   
            rd_trigger : IN STD_LOGIC;
            rd_trigger_ok : OUT STD_LOGIC;              
            rd_continue : OUT STD_LOGIC;              
            rd_continue_ok : IN STD_LOGIC;
            i_buff_rd_en : OUT STD_LOGIC;   
            start : OUT STD_LOGIC;
            counter : IN STD_LOGIC_VECTOR(11 DOWNTO 0)  
        );
    END COMPONENT;
    
    SIGNAL start : STD_LOGIC := '0';
    SIGNAL counter : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');  

BEGIN

    INST_ETHERNET : ethernet
        PORT MAP(
            clock => clk,
            eth_mdio => io_eth_mdio,
            eth_mdc => o_eth_mdc,
            eth_rstn => o_eth_rstn,
            eth_tx_d => o_eth_tx_d,
            eth_tx_en => o_eth_tx_en,
            eth_tx_clk => i_eth_tx_clk,
            eth_rx_d => i_eth_rx_d,
            eth_rx_err => i_eth_rx_err,
            eth_rx_dv => i_eth_rx_dv,
            eth_rx_clk => i_eth_rx_clk,
            eth_col => i_eth_col,
            eth_crs => i_eth_crs,
            eth_ref_clk => o_eth_ref_clk,
            start => start,
            counter => counter,
            data_16b => din
        );
        
    INST_ETHERNET_CONTROL : ethernet_control
        GENERIC MAP( 
            DATA => DATA,
            PACKETS => PACKETS
        ) 
        PORT MAP(
            rst => rst,
            clk => i_eth_tx_clk,                            
            rd_trigger => rd_trigger,
            rd_trigger_ok => rd_trigger_ok,             
            rd_continue => rd_continue,              
            rd_continue_ok => rd_continue_ok,
            i_buff_rd_en => i_buff_rd_en,   
            start => start,
            counter => counter
        );

END behavioral;
