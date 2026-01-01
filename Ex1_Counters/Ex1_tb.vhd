library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Ex1_tb is
end Ex1_tb;

architecture Behavioral of Ex1_tb is
    component Ex1 
        Port ( i_clk        : in STD_LOGIC;
                           i_rst         : in STD_LOGIC;
                           o_count1 : out STD_LOGIC_VECTOR (7 downto 0);
                           o_count2 : out STD_LOGIC_VECTOR (7 downto 0);
                           o_count3 : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    signal i_clk    : STD_LOGIC := '0';
    signal i_rst    : STD_LOGIC := '0';
    signal o_count1 : STD_LOGIC_VECTOR (7 downto 0);
    signal o_count2 : STD_LOGIC_VECTOR (7 downto 0);
    signal o_count3 : STD_LOGIC_VECTOR (7 downto 0);
    
begin

    dut: Ex1 
        port map (
            i_clk    => i_clk,
            i_rst    => i_rst,
            o_count1 => o_count1,
            o_count2 => o_count2,
            o_count3 => o_count3
        );

    clock_process : process
    begin
        i_clk <= '0';
        wait for 10 ns;
        i_clk <= '1';
        wait for 10 ns;
    end process;

    stim_process: process
    begin
        i_rst <= '0';
        wait for 20 ns;
        i_rst <= '1'; 
        wait;
    end process;

end Behavioral;
