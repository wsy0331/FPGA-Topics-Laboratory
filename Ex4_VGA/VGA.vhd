library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA is
    generic(
        H_RES   : INTEGER  := 800;
        H_FP    : INTEGER  := 56;
        H_SYNC  : INTEGER  := 120;
        H_BP    : INTEGER  := 64;
        H_POL   : STD_LOGIC := '1';
        V_RES   : INTEGER  := 600;
        V_FP    : INTEGER  := 37;
        V_SYNC  : INTEGER  := 6;
        V_BP    : INTEGER  := 23;
        V_POL   : STD_LOGIC := '1'
    );
    port (
        i_clk     : IN STD_LOGIC;              
        i_rst     : IN STD_LOGIC; 
        i_sw2     : IN STD_LOGIC;
        i_sw3     : IN STD_LOGIC;
        i_sw4     : IN STD_LOGIC;
        o_red     : OUT STD_LOGIC_VECTOR(3 downto 0); 
        o_green   : OUT STD_LOGIC_VECTOR(3 downto 0); 
        o_blue    : OUT STD_LOGIC_VECTOR(3 downto 0); 
        o_h_sync  : OUT STD_LOGIC;           
        o_v_sync  : OUT STD_LOGIC             
    );
end VGA;

architecture Behavior of VGA is
    constant H_TOTAL : INTEGER := H_RES + H_FP  + H_SYNC + H_BP ;
    constant V_TOTAL : INTEGER := V_RES + V_FP + V_SYNC + V_BP ;
    signal h_count : INTEGER range 0 to H_TOTAL - 1 := 0;
    signal v_count : INTEGER range 0 to V_TOTAL - 1 := 0;
    signal pixel_clk : STD_LOGIC := '0';   
    signal clk_div : STD_LOGIC := '0';    
begin

    -- 100MHz->50MHz
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

    process (h_count)
    begin
        if i_rst = '1' then
            o_h_sync <= NOT H_POL;
        elsif h_count < H_RES + H_FP or h_count >= H_RES + H_FP + H_SYNC then
            o_h_sync <= NOT H_POL ;
        else
            o_h_sync <= H_POL ;
        end if;
    end process;

    process (v_count)
    begin
        if i_rst = '1' then
            o_v_sync <= NOT V_POL;
        elsif v_count < V_RES + V_FP or v_count >= V_RES + V_FP + V_SYNC then
            o_v_sync <= NOT V_POL;
        else
            o_v_sync <= V_POL;
        end if;
    end process;

    -- VGA繪圖部分：根據不同的開關顯示不同形狀
    process (h_count, v_count, i_sw2, i_sw3, i_sw4) -- 加入 i_sw4
    -- 設置形狀座標與大小
    constant SQUARE_SIZE : INTEGER := 120;
    constant TRI_HEIGHT  : INTEGER := 80;
    constant SMOKE_WIDTH : INTEGER := 20;
    constant SMOKE_HEIGHT: INTEGER := 40;

    -- 以畫面中央做基準
    constant SQUARE_X0 : INTEGER := (H_RES/2) - (SQUARE_SIZE/2);
    constant SQUARE_X1 : INTEGER := SQUARE_X0 + SQUARE_SIZE;
    constant SQUARE_Y0 : INTEGER := (V_RES/2) - (SQUARE_SIZE/2);
    constant SQUARE_Y1 : INTEGER := SQUARE_Y0 + SQUARE_SIZE;

    -- 圓形窗戶參數（中央）
    constant win_radius : INTEGER := 30;
    constant win_cx : INTEGER := (SQUARE_X0 + SQUARE_X1) / 2;
    constant win_cy : INTEGER := (SQUARE_Y0 + SQUARE_Y1) / 2;
    constant line_thick : INTEGER := 2;

    -- 三角形頂點: 在正方形上方
    constant TRI_X0 : INTEGER := SQUARE_X0;
    constant TRI_X1 : INTEGER := SQUARE_X1;
    constant TRI_Y0 : INTEGER := SQUARE_Y0;
    constant TRI_Y1 : INTEGER := SQUARE_Y0 - TRI_HEIGHT;

    -- ?囪: 在房子（正方形）右上方
    constant SMOKE_X0 : INTEGER := SQUARE_X1 - SMOKE_WIDTH;
    constant SMOKE_X1 : INTEGER := SQUARE_X1;
    constant SMOKE_Y0 : INTEGER := SQUARE_Y0 - SMOKE_HEIGHT;
    constant SMOKE_Y1 : INTEGER := SQUARE_Y0;
begin
    if i_rst = '1' then
        o_red   <= "0000";
        o_green <= "0000";
        o_blue  <= "0000";
    elsif h_count < H_RES and v_count < V_RES then

        -- 正方形
        if (h_count >= SQUARE_X0 and h_count < SQUARE_X1 and
            v_count >= SQUARE_Y0 and v_count < SQUARE_Y1) then

            -- 預設紅色
            o_red   <= "1111";  
            o_green <= "0000";
            o_blue  <= "0000";

            -- 圓形窗戶 (i_sw4 控制)
            if i_sw4 = '1' then
                -- 是否在窗戶圓內
                if ((h_count - win_cx) * (h_count - win_cx) +
                     (v_count - win_cy) * (v_count - win_cy) <= win_radius * win_radius) then
                    -- 預設圓形窗戶顏色: 淺藍
                    o_red   <= "0000";
                    o_green <= "1111";
                    o_blue  <= "1111";

                    -- 十字分割 (白色)
                    if (abs(h_count - win_cx) <= line_thick or abs(v_count - win_cy) <= line_thick) then
                        o_red   <= "1111";
                        o_green <= "1111";
                        o_blue  <= "1111";
                    end if;
                end if;
            end if;

        -- 三角形(i_sw2)
        elsif (i_sw2 = '1') and
              (v_count <= TRI_Y0 and v_count >= TRI_Y1) and
              (h_count >= SQUARE_X0 and h_count <= SQUARE_X1) and
              ((v_count - TRI_Y1) * (SQUARE_X1 - SQUARE_X0) >=
                abs(h_count - (SQUARE_X0 + SQUARE_X1)/2) * TRI_HEIGHT * 2)
        then
            o_green <= "1111";
            o_red   <= "0000";
            o_blue  <= "0000";

        -- ?囪(i_sw3)
        elsif (i_sw3 = '1') and
              (h_count >= SMOKE_X0 and h_count < SMOKE_X1 and
               v_count >= SMOKE_Y0 and v_count < SMOKE_Y1)
        then
            o_red <= "1010";
            o_green <= "1010";
            o_blue <= "1010";

        -- 背景
        else
            o_red <= "0000";
            o_green <= "0000";
            o_blue <= "0000";
        end if;

    else
        -- 邊界外黑色
        o_red   <= "0000";
        o_green <= "0000";
        o_blue  <= "0000";
    end if;
end process;

end Behavior;