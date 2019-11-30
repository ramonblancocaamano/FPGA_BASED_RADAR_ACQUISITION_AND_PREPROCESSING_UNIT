----------------------------------------------------------------------------------
-- @FILE : interface.vhd 
-- @AUTHOR: BLANCO CAAMANO, RAMON. <ramonblancocaamano@gmail.com> 
-- 
-- @ABOUT: .
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY interface IS
    PORT (
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
        PORT(
            clock_eth: IN STD_LOGIC;    
            data_eth_in: IN std_logic_vector(15 downto 0);
            rst_system : IN STD_LOGIC;
            rd_fifo_eth : OUT STD_LOGIC;
            trigger_eth : IN STD_LOGIC;
            trigger_eth_ok : OUT STD_LOGIC;              
            continue_eth : OUT STD_LOGIC;              
            continue_eth_ok : IN STD_LOGIC;
            eth_tx_clk : IN  STD_LOGIC;
            start : IN STD_LOGIC;
            counter : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)  
        );
    END COMPONENT;
    
    SIGNAL start : STD_LOGIC := '0';
    SIGNAL counter : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');  

BEGIN

    INST_ETHERNET : ethernet
        PORT MAP(
            clock => clock,
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
            eth_ref_clk => eth_ref_clk,
            start => start,
            counter => counter,
            data_16b => din
        );
        
    INST_ETHERNET_CONTROL : ethernet_control 
        PORT MAP(
            clock_eth  => clock,   
            data_eth_in => din,
            rst_system => rst,
            rd_fifo_eth => rd_en,
            trigger_eth => trigger,
            trigger_eth_ok => trigger_ok,          
            continue_eth => continue,            
            continue_eth_ok =>continue_ok,
            eth_tx_clk => eth_tx_clk,
            start => start,
            counter => counter
        );

END behavioral;
