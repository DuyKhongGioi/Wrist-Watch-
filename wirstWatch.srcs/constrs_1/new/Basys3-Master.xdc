# --- Clock 100MHz ---
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports sysclk_100mhz]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports sysclk_100mhz]

# --- Switches (Gạt Switch V17 bên phải ngoài cùng để Reset) ---
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports pb_reset]

# --- Buttons (Nút giữa là B1, Nút phải là B2, Nút trên là B3) ---
set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports pb_b1]
set_property -dict { PACKAGE_PIN T17  IOSTANDARD LVCMOS33 } [get_ports pb_b2]
set_property -dict { PACKAGE_PIN T18  IOSTANDARD LVCMOS33 } [get_ports pb_b3]

# --- LED báo cờ trạng thái Alarm Set (LED 15 ngoài cùng bên trái) ---
set_property -dict { PACKAGE_PIN L1   IOSTANDARD LVCMOS33 } [get_ports {leds_out[15]}]

# --- Hệ thống 6 LED đơn hiển thị GIÂY (Mút từ LED 14 xuống LED 9) ---
set_property -dict { PACKAGE_PIN P1   IOSTANDARD LVCMOS33 } [get_ports {leds_out[14]}]
set_property -dict { PACKAGE_PIN N3   IOSTANDARD LVCMOS33 } [get_ports {leds_out[13]}]
set_property -dict { PACKAGE_PIN P3   IOSTANDARD LVCMOS33 } [get_ports {leds_out[12]}]
set_property -dict { PACKAGE_PIN U3   IOSTANDARD LVCMOS33 } [get_ports {leds_out[11]}]
set_property -dict { PACKAGE_PIN W3   IOSTANDARD LVCMOS33 } [get_ports {leds_out[10]}]
set_property -dict { PACKAGE_PIN V3   IOSTANDARD LVCMOS33 } [get_ports {leds_out[9]}]

set_property -dict { PACKAGE_PIN V13  IOSTANDARD LVCMOS33 } [get_ports {leds_out[8]}]
set_property -dict { PACKAGE_PIN V14  IOSTANDARD LVCMOS33 } [get_ports {leds_out[7]}]
set_property -dict { PACKAGE_PIN U14  IOSTANDARD LVCMOS33 } [get_ports {leds_out[6]}]
set_property -dict { PACKAGE_PIN U15  IOSTANDARD LVCMOS33 } [get_ports {leds_out[5]}]
set_property -dict { PACKAGE_PIN W18  IOSTANDARD LVCMOS33 } [get_ports {leds_out[4]}]
set_property -dict { PACKAGE_PIN V19  IOSTANDARD LVCMOS33 } [get_ports {leds_out[3]}]
set_property -dict { PACKAGE_PIN U19  IOSTANDARD LVCMOS33 } [get_ports {leds_out[2]}]
set_property -dict { PACKAGE_PIN E19  IOSTANDARD LVCMOS33 } [get_ports {leds_out[1]}]
set_property -dict { PACKAGE_PIN U16  IOSTANDARD LVCMOS33 } [get_ports {leds_out[0]}]

# --- 7 Segment Display Cathodes (Các thanh LED g,f,e,d,c,b,a) ---
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]; # ca
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]; # cb
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]; # cc
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]; # cd
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]; # ce
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]; # cf
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]; # cg

# --- 7 Segment Display Anodes (Chân chọn đèn LED kích hoạt sáng) ---
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]; # Cột đơn vị Phút
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]; # Cột chục Phút
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]; # Cột đơn vị Giờ
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]; # Cột chục Giờ

# --- Còi Buzzer hoặc LED ngoài báo hiệu chuông (Cắm ở hàng Pmod JB chân số 1) ---
set_property -dict { PACKAGE_PIN A14  IOSTANDARD LVCMOS33 } [get_ports buzzer_ring]

# --- Thao tác cấu hình hệ thống ---
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]