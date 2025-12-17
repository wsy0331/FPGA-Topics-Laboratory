library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE. STD_LOGIC_UNSIGNED.ALL;

entity TopLevel is
    port (
        i_clk         : IN STD_LOGIC;
        i_rst         : IN STD_LOGIC;
        i_sw_left     : IN STD_LOGIC;    
        i_sw_right    :  IN STD_LOGIC;
        o_red_sig     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_green_sig   : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_blue_sig    : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        o_h_sync_sig  : OUT STD_LOGIC;
        o_v_sync_sig  : OUT STD_LOGIC
    );
end TopLevel;

architecture Behavioral of TopLevel is
	signal ball_x_sig              : INTEGER;
	signal ball_y_sig              : INTEGER;
	signal ball_dx_sig             : INTEGER;
	signal ball_dy_sig             : INTEGER;
	signal left_paddle_x_sig       : INTEGER;
	signal left_paddle_y_sig       : INTEGER;
	signal right_paddle_x_sig      : INTEGER;
	signal right_paddle_y_sig      : INTEGER;
	signal paddle_dy_sig           : INTEGER;
	signal ball_moving_left_sig    : STD_LOGIC;
	signal ball_visible_sig        : STD_LOGIC;  -- 新增
	signal left_paddle_visible_sig :  STD_LOGIC;
	signal right_paddle_visible_sig:  STD_LOGIC;

	component Table_Tennis
		port (
			i_clk              : IN STD_LOGIC;              
			i_rst              : IN STD_LOGIC;
			i_sw_left          :  IN STD_LOGIC;    
			i_sw_right         : IN STD_LOGIC;
			o_left_paddle_x    : out INTEGER;
			o_left_paddle_y    : out INTEGER;
			o_right_paddle_x   : out INTEGER;
			o_right_paddle_y   : out INTEGER;
			o_paddle_dy        : out INTEGER;   
			o_ball_x           : out INTEGER;
			o_ball_y           : out INTEGER;
			o_ball_dx          : out INTEGER;
			o_ball_dy          : out INTEGER;
			o_ball_moving_left : out STD_LOGIC;
			o_ball_visible     : out STD_LOGIC;  -- 新增
			o_left_paddle_visible  : out STD_LOGIC;
			o_right_paddle_visible :  out STD_LOGIC
		);
	end component;

	component VGA
		generic(
			H_RES 	: INTEGER  	:= 800;
			H_FP  	: INTEGER  	:= 56;
			H_SYNC	: INTEGER  	:= 120;
			H_BP  	: INTEGER  	:= 64;
			H_POL 	: STD_LOGIC	:= '1';		
			V_RES 	:  INTEGER  	:= 600;
			V_FP  	: INTEGER  	:= 37;
			V_SYNC	: INTEGER  	:= 6;
			V_BP  	: INTEGER  	:= 23;
			V_POL 	: STD_LOGIC	:= '1'
		);
		port (
			i_clk              : IN STD_LOGIC;              
			i_rst              : IN STD_LOGIC;
			left_paddle_x      : IN INTEGER;
			left_paddle_y      : IN INTEGER;
			right_paddle_x     : IN INTEGER;
			right_paddle_y     : IN INTEGER;
			ball_x             : IN INTEGER;
			ball_y             : IN INTEGER;
			ball_moving_left   : IN STD_LOGIC;
			ball_visible       : IN STD_LOGIC;  -- 新增
			left_paddle_visible  : IN STD_LOGIC;
			right_paddle_visible :  IN STD_LOGIC;
			o_red              : OUT STD_LOGIC_VECTOR(3 downto 0);  
			o_green            : OUT STD_LOGIC_VECTOR(3 downto 0);  
			o_blue             : OUT STD_LOGIC_VECTOR(3 downto 0);  
			o_h_sync           : OUT STD_LOGIC;             
			o_v_sync           : OUT STD_LOGIC              
		);
	end component;

begin

	Table_Tennis_inst : Table_Tennis
	port map (
		i_clk              => i_clk,
		i_rst              => i_rst,
		i_sw_left          => i_sw_left,    
		i_sw_right         => i_sw_right,
		o_left_paddle_x    => left_paddle_x_sig,
		o_left_paddle_y    => left_paddle_y_sig,
		o_right_paddle_x   => right_paddle_x_sig,
		o_right_paddle_y   => right_paddle_y_sig,
		o_paddle_dy        => paddle_dy_sig,
		o_ball_x           => ball_x_sig,
		o_ball_y           => ball_y_sig,
		o_ball_dx          => ball_dx_sig,
		o_ball_dy          => ball_dy_sig,
		o_ball_moving_left => ball_moving_left_sig,
		o_ball_visible     => ball_visible_sig,  -- 新增
		o_left_paddle_visible  => left_paddle_visible_sig,
		o_right_paddle_visible => right_paddle_visible_sig
	);

	VGA_inst : VGA
	port map (
		i_clk              => i_clk,
		i_rst              => i_rst,
		left_paddle_x      => left_paddle_x_sig,
		left_paddle_y      => left_paddle_y_sig,
		right_paddle_x     => right_paddle_x_sig,
		right_paddle_y     => right_paddle_y_sig,
		ball_x             => ball_x_sig, 
		ball_y             => ball_y_sig,
		ball_moving_left   => ball_moving_left_sig,
		ball_visible       => ball_visible_sig,  -- 新增
		left_paddle_visible  => left_paddle_visible_sig,
		right_paddle_visible => right_paddle_visible_sig,
		o_red              => o_red_sig,
		o_green            => o_green_sig,
		o_blue             => o_blue_sig,
		o_h_sync           => o_h_sync_sig,
		o_v_sync           => o_v_sync_sig
	);

end Behavioral;