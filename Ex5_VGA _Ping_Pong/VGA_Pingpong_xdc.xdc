set_property IOSTANDARD LVCMOS25 [get_ports i_clk]
set_property PACKAGE_PIN Y9 [get_ports i_clk]

set_property -dict {PACKAGE_PIN F22  IOSTANDARD LVCMOS25}  [get_ports {i_rst}]

set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS25} [get_ports {i_sw_left}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS25} [get_ports {i_sw_right}]

set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS25}  [get_ports {o_h_sync_sig}]  
set_property -dict {PACKAGE_PIN AB9  IOSTANDARD LVCMOS25}  [get_ports {o_v_sync_sig}]
 
set_property -dict {PACKAGE_PIN AA6  IOSTANDARD LVCMOS25}  [get_ports {o_red_sig[0]}] 
set_property -dict {PACKAGE_PIN Y11  IOSTANDARD LVCMOS25}  [get_ports {o_red_sig[1]}]  
set_property -dict {PACKAGE_PIN Y10  IOSTANDARD LVCMOS25}  [get_ports {o_red_sig[2]}]
set_property -dict {PACKAGE_PIN AB6  IOSTANDARD LVCMOS25}  [get_ports {o_red_sig[3]}]
 
set_property -dict {PACKAGE_PIN Y4   IOSTANDARD LVCMOS25}  [get_ports {o_green_sig[0]}] 
set_property -dict {PACKAGE_PIN AA4  IOSTANDARD LVCMOS25}  [get_ports {o_green_sig[1]}] 
set_property -dict {PACKAGE_PIN R6   IOSTANDARD LVCMOS25}  [get_ports {o_green_sig[2]}] 
set_property -dict {PACKAGE_PIN T6   IOSTANDARD LVCMOS25}  [get_ports {o_green_sig[3]}]

set_property -dict {PACKAGE_PIN U4   IOSTANDARD LVCMOS25}  [get_ports {o_blue_sig[0]}]  
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS25}  [get_ports {o_blue_sig[1]}]  
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS25}  [get_ports {o_blue_sig[2]}]  
set_property -dict {PACKAGE_PIN AA7  IOSTANDARD LVCMOS25}  [get_ports {o_blue_sig[3]}]