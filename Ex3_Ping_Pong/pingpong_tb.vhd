library IEEE;
use IEEE.std_logic_1164.all;
 
ENTITY pingpong_tb IS
END pingpong_tb;
 
architecture Behavior of pingpong_tb is
    COMPONENT pingpong
        Port (i_clk : in STD_LOGIC;
              i_rst : in STD_LOGIC;
              i_swL : in STD_LOGIC;
              i_swR : in STD_LOGIC;
              o_led : out STD_LOGIC_VECTOR (7 downto 0));
    END COMPONENT;
    
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal swL : std_logic := '0';
    signal swR : std_logic := '0'; 
    signal led : std_logic_vector(7 downto 0);
    constant clock_period : time := 20 ns;
    
begin
 
    uut: pingpong PORT MAP (
        i_clk => clock,
        i_rst => reset, 
        i_swL => swL,
        i_swR => swR,
        o_led => led
    );    
    
    clock_process :process
    begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;
    
    stim_proc: process
    begin
        -- Reset
        reset <= '0';
        swL <= '0';
        swR <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for 100 ns;
        
        -- 1.正常對打，右方先發球
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 560 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        wait for 560 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';

        
        -- 2.左方晚打，右方得分
        wait for 600 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        
        -- 3.右方發球
        wait for 220 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        
        -- 4.左邊回擊，右邊晚打，左邊得分
        wait for 620 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        wait for 600 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';  
        
        --5.左邊發球，右邊漏接，左邊得分
        wait for 400 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        
        --6.右邊漏接，左邊得分
        wait for 1000 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        wait for 600 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 100 ns;
        
--        --左邊發球
--        wait for 360 ns;
--        swL <= '1';
--        wait for 40 ns;
--        swL <= '0';
--        wait for 100 ns;
        
        wait;
    end process;
    
end Behavior;