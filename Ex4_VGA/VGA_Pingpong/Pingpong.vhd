library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pingpong is
    Port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;  -- active-low
        i_btL : in STD_LOGIC;  
        i_btR : in STD_LOGIC;  
        i_swL : in STD_LOGIC;  
        i_swR : in STD_LOGIC;  
        o_led : out STD_LOGIC_VECTOR (7 downto 0)
    );
end pingpong;

architecture Behavioral of pingpong is
    type STATE_TYPE is (MovingL, MovingR, Lwin, Rwin);
    signal state      : STATE_TYPE := MovingR;
    signal prev_state : STATE_TYPE := MovingR;
    signal led_r  : STD_LOGIC_VECTOR (7 downto 0) := "10000000";
    signal scoreL : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal scoreR : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal clk_div : unsigned(23 downto 0) := (others => '0');
    signal ball : std_logic := '1';
    
    -- Button sync signals
    signal btL_meta, btL_sync, btL_prev, btL_rise : std_logic := '0';
    signal btR_meta, btR_sync, btR_prev, btR_rise : std_logic := '0';
    signal swL_meta, swL_sync : std_logic := '0';
    signal swR_meta, swR_sync : std_logic := '0';
    
    signal ball_tick      : std_logic;
    signal ball_tick_edge : std_logic := '0';
    constant FAST_BIT : integer := 22;  
    constant SLOW_BIT : integer := 23;
    signal at_left_end  : std_logic;
    signal at_right_end : std_logic;

begin
    o_led <= led_r;
    at_left_end  <= '1' when led_r = "10000000" else '0';
    at_right_end <= '1' when led_r = "00000001" else '0';

    -- Clock Divider
    process(i_clk, i_rst)
    begin
        if i_rst = '0' then
            clk_div <= (others => '0');
        elsif rising_edge(i_clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    ball_tick <= std_logic(clk_div(FAST_BIT)) when ball='0' else std_logic(clk_div(SLOW_BIT));

    -- Edge detection for ball tick
    ball_tic: process(i_clk, i_rst)
        variable prev : std_logic := '0';
    begin
        if i_rst='0' then
            ball_tick_edge <= '0';
            prev := '0';
        elsif rising_edge(i_clk) then
            if ball_tick='1' and prev='0' then
                ball_tick_edge <= '1';
            else
                ball_tick_edge <= '0';
            end if;
            prev := ball_tick;
        end if;
    end process;

    -- Button L Sync
    process(i_clk, i_rst)
    begin
        if i_rst='0' then btL_meta <= '0'; btL_sync <= '0'; btL_prev <= '0';
        elsif rising_edge(i_clk) then
            btL_meta <= i_btL;
            btL_sync <= btL_meta;
            btL_prev <= btL_sync;
        end if;
    end process;
    btL_rise <= '1' when (btL_sync='1' and btL_prev='0') else '0';

    -- Button R Sync
    process(i_clk, i_rst)
    begin
        if i_rst='0' then btR_meta <= '0'; btR_sync <= '0'; btR_prev <= '0';
        elsif rising_edge(i_clk) then
            btR_meta <= i_btR;
            btR_sync <= btR_meta;
            btR_prev <= btR_sync;
        end if;
    end process;
    btR_rise <= '1' when (btR_sync='1' and btR_prev='0') else '0';

    -- Switches Sync
    process(i_clk, i_rst)
    begin
        if i_rst='0' then swL_meta <= '0'; swL_sync <= '0';
        elsif rising_edge(i_clk) then
            swL_meta <= i_swL; swL_sync <= swL_meta;
        end if;
    end process;

    process(i_clk, i_rst)
    begin
        if i_rst='0' then swR_meta <= '0'; swR_sync <= '0';
        elsif rising_edge(i_clk) then
            swR_meta <= i_swR; swR_sync <= swR_meta;
        end if;
    end process;

    -- Main State Machine (Logic Fix Here)
    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            state <= MovingR;
        elsif rising_edge(i_clk) then
            case state is
                when MovingR =>
                    -- 提早按（還沒到終點就按鈕）-> 左邊贏
                    if at_right_end = '0' and btR_sync = '1' then
                        state <= Lwin;
                    -- 球移動事件
                    elsif ball_tick_edge='1' and at_right_end='1' then
                        if btR_sync='1' then
                            state <= MovingL;          -- 成功回擊
                        else
                            state <= Lwin;             -- 沒按按鈕，漏接
                        end if;
                    end if;

                when MovingL =>
                    -- 提早按（還沒到終點就按鈕）-> 右邊贏
                    if at_left_end = '0' and btL_sync = '1' then
                        state <= Rwin;
                    -- 球移動事件
                    elsif ball_tick_edge='1' and at_left_end='1' then
                        if btL_sync='1' then
                            state <= MovingR;          -- 成功回擊
                        else
                            state <= Rwin;             -- 沒按按鈕，漏接
                        end if;
                    end if;

                when Lwin =>
                    if btL_rise='1' then             
                        state <= MovingR;
                    end if;

                when Rwin =>
                    if btR_rise='1' then
                        state <= MovingL;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    -- prev_state 記錄狀態歷史
    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            prev_state <= MovingR;
        elsif rising_edge(i_clk) then
            prev_state <= state;
        end if;
    end process;

    -- Ball Speed Control
    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            ball <= '1';
        elsif rising_edge(i_clk) then
            if (prev_state = MovingR and state = MovingL) or
               (prev_state = Rwin    and state = MovingL) then
                if swR_sync='1' then ball <= '0'; else ball <= '1'; end if;
            end if;

            if (prev_state = MovingL and state = MovingR) or
               (prev_state = Lwin    and state = MovingR) then
                if swL_sync='1' then ball <= '0'; else ball <= '1'; end if;
            end if;
        end if;
    end process;

    -- LED / Game Display Logic
    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            led_r <= "10000000";
        elsif rising_edge(i_clk) then
            if state = Lwin then
                led_r <= scoreL & "0000";
            elsif state = Rwin then
                led_r <= "0000" & scoreR;
            else
                if (prev_state = Lwin and state = MovingR) then
                    led_r <= "10000000";     -- Reset ball to Left
                elsif (prev_state = Rwin and state = MovingL) then
                    led_r <= "00000001";     -- Reset ball to Right
                else
                    if ball_tick_edge='1' then
                        if state = MovingR and at_right_end='0' then
                            led_r <= '0' & led_r(7 downto 1);         -- Shift Right
                        elsif state = MovingL and at_left_end='0' then
                            led_r <= led_r(6 downto 0) & '0';         -- Shift Left
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Score Counters (改為進入新狀態時加分，無論是正常miss或提早打)
    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            scoreL <= "0000";
        elsif rising_edge(i_clk) then
            if state = Lwin and prev_state /= Lwin then
                scoreL <= std_logic_vector(unsigned(scoreL) + 1);
            end if;
        end if;
    end process;

    process(i_clk, i_rst)
    begin
        if i_rst='0' then
            scoreR <= "0000";
        elsif rising_edge(i_clk) then
            if state = Rwin and prev_state /= Rwin then
                scoreR <= std_logic_vector(unsigned(scoreR) + 1);
            end if;
        end if;
    end process;

end Behavioral;
