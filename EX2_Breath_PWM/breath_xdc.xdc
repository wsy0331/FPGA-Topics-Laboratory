set_property IOSTANDARD LVCMOS25 [get_ports i_clk]
set_property PACKAGE_PIN Y9 [get_ports i_clk]

set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS25} [get_ports {i_rst}]

set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS25} [get_ports {o_led1}]
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS25} [get_ports {o_led2}]
