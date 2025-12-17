library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE. NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
	generic(
		H_RES 	: INTEGER  	:= 800;
		H_FP  	: INTEGER  	:= 56;
		H_SYNC	: INTEGER  	:= 120;
		H_BP  	: INTEGER  	:= 64;
		H_POL 	: STD_LOGIC	:= '1';		
		V_RES 	: INTEGER  	:= 600;
		V_FP  	: INTEGER  	:= 37;
		V_SYNC	: INTEGER  	:= 6;
		V_BP  	: INTEGER  	:= 23;
		V_POL 	: STD_LOGIC	:= '1'
	);
	port (
		i_clk              : IN STD_LOGIC;              
		i_rst              : IN STD_LOGIC;
		left_paddle_x      : IN INTEGER;
		left_paddle_y      :  IN INTEGER;
		right_paddle_x     : IN INTEGER;
		right_paddle_y     :  IN INTEGER;
		ball_x             : IN INTEGER;
		ball_y             : IN INTEGER;
		ball_moving_left   :  IN STD_LOGIC;
		ball_visible       : IN STD_LOGIC;  -- 新增：球是否可見
		left_paddle_visible  : IN STD_LOGIC;
		right_paddle_visible : IN STD_LOGIC;
		o_red              : OUT STD_LOGIC_VECTOR(3 downto 0);  
		o_green            : OUT STD_LOGIC_VECTOR(3 downto 0);  
		o_blue             : OUT STD_LOGIC_VECTOR(3 downto 0);  
		o_h_sync           : OUT STD_LOGIC;             
		o_v_sync           : OUT STD_LOGIC              
	);
end VGA;

architecture Behavior of VGA is
	constant H_TOTAL :  INTEGER := H_RES + H_FP  + H_SYNC + H_BP ;
	constant V_TOTAL :  INTEGER := V_RES + V_FP + V_SYNC + V_BP ;
	signal h_count   : INTEGER range 0 to H_TOTAL - 1 := 0;
	signal v_count   : INTEGER range 0 to V_TOTAL - 1 := 0;
    
	constant BALL_DIAMETER : INTEGER := 80;
	constant BALL_RADIUS   : INTEGER := 40;
	constant PADDLE_WIDTH  : INTEGER := 20;
	constant PADDLE_HEIGHT : INTEGER := 100;

	signal pixel_clk : std_logic;
	signal clk_div   : STD_LOGIC := '0';
	
	signal ball_color_index : INTEGER range 0 to 799 := 0;
begin

	-- 時鐘分頻
	process (i_clk, i_rst)
	begin
		if i_rst = '1' then
			clk_div <= '0';
			pixel_clk <= '0';
		elsif rising_edge(i_clk) then
			clk_div <= not clk_div;       
			pixel_clk <= clk_div;     
		end if;
	end process;

	-- h_count
	process (pixel_clk, i_rst)
	begin
		if i_rst = '1' then
			h_count <= 0;
		elsif rising_edge(pixel_clk) then
			if h_count < H_TOTAL - 1 then
				h_count <= h_count + 1;
			else
				h_count <= 0;
			end if;
		end if;
	end process;

	-- v_count
	process (pixel_clk, i_rst)
	begin
		if i_rst = '1' then
			v_count <= 0;
		elsif rising_edge(pixel_clk) then
			if h_count = H_TOTAL - 1 then 
				if v_count < V_TOTAL - 1 then
					v_count <= v_count + 1;
				else
					v_count <= 0;
				end if;
			end if;
		end if;
	end process;

	-- 水平同步信號
	process (h_count, i_rst)
	begin
		if i_rst = '1' then
			o_h_sync <= NOT H_POL;
		elsif h_count < H_RES + H_FP or h_count >= H_RES + H_FP + H_SYNC then
			o_h_sync <= NOT H_POL ;
		else
			o_h_sync <= H_POL ;
		end if;
	end process;

	-- 垂直同步信號
	process (v_count, i_rst)
	begin
		if i_rst = '1' then
			o_v_sync <= NOT V_POL;
		elsif v_count < V_RES + V_FP or v_count >= V_RES + V_FP + V_SYNC then
			o_v_sync <= NOT V_POL;
		else
			o_v_sync <= V_POL;
		end if;
	end process;

	ball_color_index <= ball_x;

	-- RGB 顏色輸出（加入球的可見性控制）
	process (h_count, v_count, i_rst, ball_x, ball_y, ball_color_index, 
	         ball_visible, left_paddle_visible, right_paddle_visible)
	    variable red_val   : STD_LOGIC_VECTOR(3 downto 0);
	    variable green_val :  STD_LOGIC_VECTOR(3 downto 0);
	    variable blue_val  : STD_LOGIC_VECTOR(3 downto 0);
	begin
		if i_rst = '1' then
			o_red   <= "0000";
			o_green <= "0000";
			o_blue  <= "0000";
		elsif h_count < H_RES and v_count < V_RES then
			-- 檢查是否為球的位置（加入 ball_visible 條件）
			if ball_visible = '1' and 
			   ((h_count - ball_x) * (h_count - ball_x) + (v_count - ball_y) * (v_count - ball_y)) <= (BALL_RADIUS * BALL_RADIUS) then
				-- 根據球的 x 位置改變顏色
				if ball_x < 200 then
					red_val   := "1111";
					green_val := std_logic_vector(to_unsigned(ball_x / 13, 4));
					blue_val  := "0000";
				elsif ball_x < 400 then
					red_val   := "1111";
					green_val := "1111";
					blue_val  := std_logic_vector(to_unsigned((ball_x - 200) / 13, 4));
				elsif ball_x < 600 then
					red_val   := std_logic_vector(to_unsigned(15 - (ball_x - 400) / 13, 4));
					green_val := "1111";
					blue_val  := std_logic_vector(to_unsigned((ball_x - 400) / 13, 4));
				else
					red_val   := "0000";
					green_val := "1111";
					blue_val  := std_logic_vector(to_unsigned((ball_x - 600) / 13, 4));
				end if;
				
				o_red   <= red_val;
				o_green <= green_val;
				o_blue  <= blue_val;
				
			-- 檢查是否為球拍的位置
			elsif (left_paddle_visible = '1' and 
			       h_count >= left_paddle_x and h_count < left_paddle_x + PADDLE_WIDTH and 
			       v_count >= left_paddle_y and v_count < left_paddle_y + PADDLE_HEIGHT) or 
			      (right_paddle_visible = '1' and
			       h_count >= right_paddle_x and h_count < right_paddle_x + PADDLE_WIDTH and 
			       v_count >= right_paddle_y and v_count < right_paddle_y + PADDLE_HEIGHT) then
				o_red   <= "0000";
				o_green <= "0000";
				o_blue  <= "1111";
			else
				-- 背景顏色
				o_red   <= "0000";
				o_green <= "1111";
				o_blue  <= "0000";
			end if;
		else
			o_red   <= "0000";
			o_green <= "0000";
			o_blue  <= "0000";
		end if;
	end process;
	
end Behavior;