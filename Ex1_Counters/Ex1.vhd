library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Ex1 is
    Port ( i_clk       : in STD_LOGIC;
                   i_rst        : in STD_LOGIC;
                  o_count1 : out STD_LOGIC_VECTOR (7 downto 0);
                  o_count2 : out STD_LOGIC_VECTOR (7 downto 0);
                  o_count3 : out STD_LOGIC_VECTOR (7 downto 0));
end Ex1;

architecture Behavioral of Ex1 is
    signal count1 : STD_LOGIC_VECTOR (7 downto 0);
    signal count2 : STD_LOGIC_VECTOR (7 downto 0);
    signal count3 : STD_LOGIC_VECTOR (7 downto 0);
    type FSM_state is (S0, S1, S2);
    signal state : FSM_state;
begin
    o_count1 <= count1;
    o_count2 <= count2;
    o_count3 <= count3;
    
    FSM: process(i_clk, i_rst, count1, count2, count3)
    begin
        if i_rst = '0' then
            state <= S0;
        elsif i_clk'event and i_clk = '1' then
            case state is
                when S0 =>
                    if count1 = "00001000" then
                        state <= S1;
                    end if;
                when S1 =>
                    if count2 = "01010000" then
                        state <= S2;
                    end if;
                when S2 =>
                    if count3 = "00011101" then
                        state <= S0;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process FSM;
    
    counter1: process(i_clk, i_rst, state)
    begin
        if i_rst = '0' then
            count1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            case state is
                when S0 =>
                    if count3 = "00011110" then
                        count1 <= count1;
                    elsif count1 < "00001001" then
                        count1 <= count1 + '1';
                    else 
                        count1 <= count1;
                    end if;
                when S1 =>
                    count1 <= "00000000";
                when S2 =>
                    count1 <= "00000000";
                when others =>
                    null;
            end case;
        end if;
    end process counter1;
    
    counter2: process(i_clk, i_rst, state)
    begin
        if i_rst = '0' then
            count2 <= "11111101";
        elsif i_clk'event and i_clk = '1' then
            case state is
                when S0 =>
                    count2 <= "11111101";
                when S1 =>
                    if count1 = "00001001" then
                        count2 <= count2;
                    elsif count2 > "01001111" then
                        count2 <= count2 - '1';
                    else
                        count2 <= count2;
                    end if;
                when S2 =>
                    count2 <= "11111101";
                when others =>
                    null;
            end case;
        end if;
    end process counter2;
    
    counter3: process(i_clk, i_rst, state)
    begin
        if i_rst = '0' then
            count3 <= "00001111";
        elsif i_clk'event and i_clk = '1' then
            case state is
                when S0 =>
                    count3 <= "00001111";
                when S1 =>
                    count3 <= "00001111";
                when S2 =>
                    if count2 = "01001111" then
                        count3 <= count3;
                    elsif count3 < "00011110" then
                        count3 <= count3 + '1';
                    else
                        count3 <= count3;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process counter3;
       
end Behavioral;
