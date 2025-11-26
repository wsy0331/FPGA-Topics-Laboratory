library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity pingpong is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_swL : in STD_LOGIC;
           i_swR : in STD_LOGIC;
           o_led : out STD_LOGIC_VECTOR (7 downto 0));
end pingpong;

architecture Behavioral of pingpong is
    type STATE_TYPE is (IDLE, MovingL, MovingR, Lwin, Rwin);
    signal state     : STATE_TYPE;
    signal old_state : STATE_TYPE;
    signal led_r     : STD_LOGIC_VECTOR (7 downto 0);
    signal scoreL    : STD_LOGIC_VECTOR (3 downto 0);
    signal scoreR    : STD_LOGIC_VECTOR (3 downto 0);
    signal clk_div   : STD_LOGIC_VECTOR (28 downto 0);
    signal slow_clk  : STD_LOGIC;
begin

    o_led <= led_r;
    slow_clk <= clk_div(1);  
    
    Div_clk:process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            clk_div <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            clk_div <= clk_div + 1;
        end if;
    end process;
    
    FSM:process(i_clk, i_rst)
    begin
        if i_rst='0' then
            state <= IDLE;
        elsif i_clk'event and i_clk='1' then
            case state is
                
                when IDLE =>
                    if i_swL = '1' and i_swR = '0' then 
                        state <= MovingR;
                    elsif i_swL = '0' and i_swR = '1' then  
                        state <= MovingL;
                    end if;
                when MovingR => 
                    if (led_r<"00000001") or (led_r > "00000001" and i_swR = '1') then 
                        state <= Lwin;
                    elsif led_r(0)='1' and i_swR ='1' then 
                        state <= MovingL;                     
                    end if;
                when MovingL =>
                    if (led_r="00000000") or (led_r < "10000000" and i_swL = '1') then
                        state <= Rwin;
                    elsif led_r(7)='1' and i_swL ='1' then
                        state <= MovingR;                                          
                    end if;
                when Lwin =>
                    if i_swL ='1' then
                        state <= MovingR;
                    end if;
                when Rwin =>
                    if i_swR ='1' then
                        state <= MovingL;
                    end if;
                when others => 
                    null;
            end case;
        end if;
    end process;

    Older_state: process(i_clk, i_rst)
    begin
        if i_rst='0' then
            old_state <= IDLE;
        elsif i_clk'event and i_clk='1' then
            old_state <= state;            
        end if;
    end process;
    
    LED_P:process(slow_clk, i_rst)
    begin
        if i_rst='0' then
            led_r <= "00000000";
        elsif slow_clk'event and slow_clk = '1' then
            case state is
                when IDLE =>
                    led_r <= "00000000"; 
                when MovingR =>
                   if old_state = Lwin or old_state = IDLE then
                        led_r <= "10000000"; 
                    else
                        led_r(7) <= '0';
                        led_r(6 downto 0) <= led_r(7 downto 1); 
                    end if;
                when MovingL =>
                    if old_state = Rwin or old_state = IDLE then
                        led_r <= "00000001";  
                    else
                        led_r(7 downto 1) <= led_r(6 downto 0); 
                        led_r(0) <= '0';
                    end if;
                when Lwin =>
                        led_r(7 downto 4) <= scoreL; 
                        led_r(3 downto 0) <= scoreR;
                when Rwin =>
                        led_r(7 downto 4) <= scoreL; 
                        led_r(3 downto 0) <= scoreR;
                when others => 
                    null;
            end case;    
        end if;
    end process;

    score_L_p:process(i_clk, i_rst)
    begin
        if i_rst='0' then
            scoreL <= "0000";
        elsif i_clk'event and i_clk='1' then
            if state = Lwin and old_state /= Lwin then 
                if scoreL = "1111" then 
                    scoreL <= "0000";
                else
                    scoreL <= scoreL + '1';
                end if;
            end if;
        end if;
    end process;

    score_R_p:process(i_clk, i_rst)
    begin
        if i_rst='0' then
            scoreR <= "0000";
        elsif i_clk'event and i_clk='1' then
            if state = Rwin and old_state /= Rwin then  
                if scoreR = "1111" then 
                    scoreR <= "0000";
                else
                    scoreR <= scoreR + '1';
                end if;
            end if;
        end if;
    end process;

end Behavioral;
