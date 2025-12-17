library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD. ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Table_Tennis is
	port (
		i_clk              : in STD_LOGIC;
		i_rst              : in STD_LOGIC;
		i_sw_left          : in STD_LOGIC;
		i_sw_right         :  in STD_LOGIC;
		o_left_paddle_x    : out INTEGER;
		o_left_paddle_y    :  out INTEGER;
		o_right_paddle_x   : out INTEGER;
		o_right_paddle_y   : out INTEGER;
		o_paddle_dy        :  out INTEGER;     
		o_ball_x           : out INTEGER;
		o_ball_y           : out INTEGER;
		o_ball_dx          : out INTEGER;
		o_ball_dy          : out INTEGER;
		o_ball_moving_left : out STD_LOGIC;
		o_ball_visible     : out STD_LOGIC;
		o_left_paddle_visible  : out STD_LOGIC;
		o_right_paddle_visible : out STD_LOGIC
	);
end Table_Tennis;

architecture Behavioral of Table_Tennis is

    -- 球的狀態
    type ball_state_type is (IDLE, MOVING_RIGHT, MOVING_LEFT, WAIT_LEFT_SERVE, WAIT_RIGHT_SERVE);
    signal ball_state : ball_state_type := IDLE;
    
    -- 常數設定
    constant BALL_DIAMETER : INTEGER := 80;
    constant BALL_RADIUS   : INTEGER := 40;
    constant PADDLE_WIDTH  : INTEGER := 20;
    constant PADDLE_HEIGHT : INTEGER := 100;
    constant H_RES         : INTEGER := 800;
    constant V_RES         : INTEGER := 600;

    -- 球的位置與速度
    signal ball_x  : INTEGER range 0 to 799 := 400;
    signal ball_y  : INTEGER range 0 to 599 := 300;
    signal ball_dx : INTEGER := 3;
    signal ball_dy :  INTEGER := 0;
    signal ball_moving_left : STD_LOGIC := '0';
    signal ball_visible : STD_LOGIC := '1';
    
    -- 球拍位置（固定）
	signal left_paddle_x  : INTEGER range 0 to 799 := 0;
	signal left_paddle_y  : INTEGER range 0 to 599 := 250;
	signal right_paddle_x : INTEGER range 0 to 799 := 780;
	signal right_paddle_y : INTEGER range 0 to 599 := 250;
	signal paddle_dy :  INTEGER := 0;
	
	-- 球拍可見性（由按鈕控制）
	signal left_paddle_visible  : STD_LOGIC := '0';
	signal right_paddle_visible : STD_LOGIC := '0';
    
    -- 時鐘分頻器
    signal clk_div  : STD_LOGIC_VECTOR(25 downto 0) := (others => '0');
    signal slow_clk : STD_LOGIC;
    
    -- 按鈕邊緣檢測
    signal sw_left_prev  : STD_LOGIC := '0';
    signal sw_right_prev : STD_LOGIC := '0';
    signal left_button_pressed  : STD_LOGIC := '0';
    signal right_button_pressed : STD_LOGIC := '0';
    
    -- 碰撞檢測信號
    signal ball_in_left_zone  : STD_LOGIC := '0';
    signal ball_in_right_zone : STD_LOGIC := '0';
    signal hit_right_paddle   : STD_LOGIC := '0';
    signal hit_left_paddle    : STD_LOGIC := '0';
    signal miss_right_paddle  : STD_LOGIC := '0';
    signal miss_left_paddle   : STD_LOGIC := '0';
    signal reach_right_boundary :  STD_LOGIC := '0';
    signal reach_left_boundary  : STD_LOGIC := '0';

begin

    slow_clk         <= clk_div(20);
    o_left_paddle_x  <= left_paddle_x;
    o_left_paddle_y  <= left_paddle_y;
    o_right_paddle_x <= right_paddle_x;
    o_right_paddle_y <= right_paddle_y;	
    o_ball_x         <= ball_x;
    o_ball_y         <= ball_y;
    o_ball_dx        <= ball_dx;
    o_ball_dy        <= ball_dy;
    o_ball_moving_left <= ball_moving_left;
    o_paddle_dy      <= paddle_dy;
    o_ball_visible   <= ball_visible;
    o_left_paddle_visible  <= left_paddle_visible;
    o_right_paddle_visible <= right_paddle_visible;

    -- 時鐘分頻
    process (i_clk, i_rst)
    begin
        if i_rst = '1' then
            clk_div <= (others => '0');
        elsif rising_edge(i_clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    -- 球拍可見性控制
    process(slow_clk, i_rst)
    begin
        if i_rst = '1' then
            left_paddle_visible  <= '0';
            right_paddle_visible <= '0';
        elsif rising_edge(slow_clk) then
            left_paddle_visible  <= i_sw_left;
            right_paddle_visible <= i_sw_right;
        end if;
    end process;

    -- 按鈕邊緣檢測與按下信號
    process(slow_clk, i_rst)
    begin
        if i_rst = '1' then
            sw_left_prev  <= '0';
            sw_right_prev <= '0';
            left_button_pressed  <= '0';
            right_button_pressed <= '0';
        elsif rising_edge(slow_clk) then
            sw_left_prev  <= i_sw_left;
            sw_right_prev <= i_sw_right;
            
            -- 檢測按鈕上升沿
            if i_sw_left = '1' and sw_left_prev = '0' then
                left_button_pressed <= '1';
            else
                left_button_pressed <= '0';
            end if;
            
            if i_sw_right = '1' and sw_right_prev = '0' then
                right_button_pressed <= '1';
            else
                right_button_pressed <= '0';
            end if;
        end if;
    end process;

    -- 球是否在球拍區域內（組合邏輯）
    ball_in_right_zone <= '1' when ((ball_x + BALL_RADIUS) >= right_paddle_x and
                                    ball_y >= right_paddle_y and 
                                    ball_y <= right_paddle_y + PADDLE_HEIGHT) else '0';
                                    
    ball_in_left_zone <= '1' when ((ball_x - BALL_RADIUS) <= left_paddle_x + PADDLE_WIDTH and
                                   ball_y >= left_paddle_y and 
                                   ball_y <= left_paddle_y + PADDLE_HEIGHT) else '0';

    -- 成功擊中：球在區域內 且 按鈕按下
    hit_right_paddle <= '1' when (ball_in_right_zone = '1' and right_paddle_visible = '1') else '0';
    hit_left_paddle  <= '1' when (ball_in_left_zone = '1' and left_paddle_visible = '1') else '0';
    
    -- 失誤：按鈕按下但球不在區域內
    miss_right_paddle <= '1' when (right_button_pressed = '1' and ball_in_right_zone = '0' and ball_state = MOVING_RIGHT) else '0';
    miss_left_paddle  <= '1' when (left_button_pressed = '1' and ball_in_left_zone = '0' and ball_state = MOVING_LEFT) else '0';
    
    -- 到達邊界
    reach_right_boundary <= '1' when (ball_x + BALL_RADIUS >= H_RES) else '0';
    reach_left_boundary  <= '1' when (ball_x - BALL_RADIUS <= 0) else '0';

    -- FSM：只管理狀態轉換
    process(slow_clk, i_rst)
    begin
        if i_rst = '1' then
            ball_state <= IDLE;
        elsif rising_edge(slow_clk) then
            case ball_state is
            
                -- IDLE 狀態：等待開局
                when IDLE =>
                    if left_button_pressed = '1' then
                        ball_state <= MOVING_RIGHT;
                    elsif right_button_pressed = '1' then
                        ball_state <= MOVING_LEFT;
                    end if;

                -- 向右移動狀態
                when MOVING_RIGHT =>
                    if hit_right_paddle = '1' then
                        ball_state <= MOVING_LEFT;
                    elsif miss_right_paddle = '1' then
                        ball_state <= WAIT_LEFT_SERVE;
                    elsif reach_right_boundary = '1' then
                        ball_state <= WAIT_LEFT_SERVE;
                    end if;

                -- 向左移動狀態
                when MOVING_LEFT =>
                    if hit_left_paddle = '1' then
                        ball_state <= MOVING_RIGHT;
                    elsif miss_left_paddle = '1' then
                        ball_state <= WAIT_RIGHT_SERVE;
                    elsif reach_left_boundary = '1' then
                        ball_state <= WAIT_RIGHT_SERVE;
                    end if;

                -- 等待左邊發球
                when WAIT_LEFT_SERVE =>
                    if left_button_pressed = '1' then
                        ball_state <= MOVING_RIGHT;
                    end if;

                -- 等待右邊發球
                when WAIT_RIGHT_SERVE =>
                    if right_button_pressed = '1' then
                        ball_state <= MOVING_LEFT;
                    end if;

                when others =>
                    ball_state <= IDLE;
            end case;
        end if;
    end process;

    -- 球的位置更新
    process(slow_clk, i_rst)
    begin
        if i_rst = '1' then
            ball_x <= 400;
            ball_y <= 300;
        elsif rising_edge(slow_clk) then
            ball_y <= 300;  -- Y 座標固定
            
            case ball_state is
                when IDLE =>
                    ball_x <= 400;
                    
                when MOVING_RIGHT =>
                    ball_x <= ball_x + ball_dx;
                    
                when MOVING_LEFT =>
                    ball_x <= ball_x - ball_dx;
                    
                when WAIT_LEFT_SERVE =>
                    ball_x <= left_paddle_x + PADDLE_WIDTH + BALL_RADIUS + 5;
                    
                when WAIT_RIGHT_SERVE =>
                    ball_x <= right_paddle_x - BALL_RADIUS - 5;
                    
                when others =>
                    ball_x <= ball_x;
            end case;
        end if;
    end process;

    -- 球的可見性與移動方向控制
    process(slow_clk, i_rst)
    begin
        if i_rst = '1' then
            ball_visible <= '1';
            ball_moving_left <= '0';
        elsif rising_edge(slow_clk) then
            case ball_state is
                when IDLE =>
                    ball_visible <= '1';
                    ball_moving_left <= '0';
                    
                when MOVING_RIGHT =>
                    ball_visible <= '1';
                    ball_moving_left <= '0';
                    
                when MOVING_LEFT =>
                    ball_visible <= '1';
                    ball_moving_left <= '1';
                    
                when WAIT_LEFT_SERVE =>
                    ball_visible <= '0';
                    ball_moving_left <= '0';
                    
                when WAIT_RIGHT_SERVE =>
                    ball_visible <= '0';
                    ball_moving_left <= '1';
                    
                when others =>
                    ball_visible <= '1';
                    ball_moving_left <= '0';
            end case;
        end if;
    end process;

end Behavioral;