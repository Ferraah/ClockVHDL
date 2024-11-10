## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


# Reset signal
set_property PACKAGE_PIN R2 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

##Buttons
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports rst]
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports b1]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports b2]
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports b3]
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports b4]

#seven-segment LED display
set_property PACKAGE_PIN W7 [get_ports {segments[6]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[6]}]
set_property PACKAGE_PIN W6 [get_ports {segments[5]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[5]}]
set_property PACKAGE_PIN U8 [get_ports {segments[4]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[4]}]
set_property PACKAGE_PIN V8 [get_ports {segments[3]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[3]}]
set_property PACKAGE_PIN U5 [get_ports {segments[2]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[2]}]
set_property PACKAGE_PIN V5 [get_ports {segments[1]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[1]}]
set_property PACKAGE_PIN U7 [get_ports {segments[0]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {segments[0]}]
set_property PACKAGE_PIN U2 [get_ports {anode[0]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {anode[0]}]
set_property PACKAGE_PIN U4 [get_ports {anode[1]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {anode[1]}]
set_property PACKAGE_PIN V4 [get_ports {anode[2]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {anode[2]}]
set_property PACKAGE_PIN W4 [get_ports {anode[3]}]                    
    set_property IOSTANDARD LVCMOS33 [get_ports {anode[3]}]
    
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {alarm_led}]
