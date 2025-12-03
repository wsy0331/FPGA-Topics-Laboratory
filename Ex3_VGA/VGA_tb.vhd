library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA_tb is
end VGA_tb;

architecture Behavioral of VGA_tb is

    constant CLK_PERIOD : time := 20 ns; -- 50MHz ????
    
    signal i_clk    : std_logic := '0';
    signal i_rst    : std_logic := '1';
    signal o_red    : std_logic_vector(3 downto 0);
    signal o_green  : std_logic_vector(3 downto 0);
    signal o_blue   : std_logic_vector(3 downto 0);
    signal o_h_sync : std_logic;
    signal o_v_sync : std_logic;

    -- Instantiate the VGA driver module
    component VGA
        Port (
            i_clk    : IN STD_LOGIC;
            i_rst    : IN STD_LOGIC;
            o_red    : OUT STD_LOGIC_VECTOR(3 downto 0);
            o_green  : OUT STD_LOGIC_VECTOR(3 downto 0);
            o_blue   : OUT STD_LOGIC_VECTOR(3 downto 0);
            o_h_sync : OUT STD_LOGIC;
            o_v_sync : OUT STD_LOGIC
        );
    end component;

begin
    
    -- Instantiate VGA Driver
    uut: VGA
        port map (
            i_clk    => i_clk,
            i_rst    => i_rst,
            o_red    => o_red,
            o_green  => o_green,
            o_blue   => o_blue,
            o_h_sync => o_h_sync,
            o_v_sync => o_v_sync
        );

    -- Clock Process
    process
    begin
        while now < 100 ms loop  -- Run simulation for 10ms
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;
    
    -- Reset Process
    process
    begin
        i_rst <= '1';
        wait for 100 ns;
        i_rst <= '0';
        wait;
    end process;
    
end Behavioral;