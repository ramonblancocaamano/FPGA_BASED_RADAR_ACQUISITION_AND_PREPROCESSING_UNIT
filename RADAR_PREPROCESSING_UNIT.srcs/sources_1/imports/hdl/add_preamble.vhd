----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz> 
-- 
-- Module Name: add_preamble - Behavioral
--
-- Description: Add the required 16 nibbles of preamble to the data packet. 
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity add_preamble is
    Port ( clk             : in  STD_LOGIC;
           data_in         : in  STD_LOGIC_VECTOR (3 downto 0);
           data_enable_in  : in  STD_LOGIC;
           data_out        : out STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
           data_enable_out : out STD_LOGIC                     := '0');
end add_preamble;

architecture Behavioral of add_preamble is
    signal delay_data        : std_logic_vector(16*4-1 downto 0) := (others => '0');
    signal delay_data_enable : std_logic_vector(16-1 downto 0) := (others => '0');
begin

process(clk)
    begin
        if rising_edge(clk) then
            if delay_data_enable(delay_data_enable'high)= '1' then
                -- Passing through data
                data_out        <= delay_data(delay_data'high downto delay_data'high-3);
                data_enable_out <= '1';        
            elsif delay_data_enable(delay_data_enable'high-1)= '1' then
                -- Start Frame Delimiter
                data_out        <= "1101"; 
                data_enable_out <= '1';
            elsif data_enable_in = '1' then
                -- Preamble nibbles
                data_out        <= "0101"; 
                data_enable_out <= '1';        
            else
                -- Link idle
                data_out        <= "0000"; 
                data_enable_out <= '0';                
            end if;
            -- Move the data through the delay line
            delay_data        <= delay_data(delay_data'high-4 downto 0) & data_in;  
            delay_data_enable <= delay_data_enable(delay_data_enable'high-1 downto 0) & data_enable_in;
        end if;
    end process;

end Behavioral;
