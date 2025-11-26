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
        -- 初始化 Reset
        reset <= '0';
        swL <= '0';
        swR <= '0';
        wait for 100 ns;
        reset <= '1';
        wait for 100 ns;
        
        -- Test 1: 右方發球
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 100 ns;
        
        -- Test 2: 正常對打 - 左方正常回擊
        wait for 460 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        wait for 100 ns;
        
        -- Test 3: 左邊沒打到右邊得分
        wait for 460 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 100 ns;
        
        -- Test 4: 右方提前打 正在右移，且左邊沒打到右邊得分
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 100 ns;
        
        -- Test 5: 右方發球
        wait for 580 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 100 ns;
        
        -- Test 6: 右邊沒打到左邊得分
        wait for 860 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        wait for 100 ns;   
        
--        --左邊提前打
--        swL <= '1';
--        wait for 40 ns;
--        swL <= '0';
--        wait for 100 ns;
        
--        --左邊發球
--        wait for 460 ns;
--        swL <= '1';
--        wait for 40 ns;
--        swL <= '0';
--        wait for 100 ns;
        
        --右邊提早打
        wait for 150 ns;
        swR <= '1';
        wait for 40 ns;
        swR <= '0';
        wait for 100 ns;
        
        --左邊發球
        wait for 360 ns;
        swL <= '1';
        wait for 40 ns;
        swL <= '0';
        wait for 100 ns;
        
        wait;
    end process;
    
end Behavior;