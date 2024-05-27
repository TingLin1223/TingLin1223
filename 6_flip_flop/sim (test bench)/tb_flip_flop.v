`timescale 1ns/1ns

module tb_flip_flop();


reg     sys_clk; 
reg     sys_rst_n;
reg     key_in;

wire    led_out;

initial
    begin
        sys_clk      = 1'b1;// give the first value to sys_clk.
        sys_rst_n   <= 1'b0;// give the first value to sys_rst_n.
        key_in      <= 1'b0;// give the first value to key_in.
        #20
        sys_rst_n   <= 1'b1;// delay 20ns and make sys_rst_n to high-level voltage.
        #210
        sys_rst_n   <= 1'b0;// delay 210ns and make sys_rst_n to low-level voltage.
        #40
        sys_rst_n   <= 1'b1;// delay 40ns and make sys_rst_n to high-level voltage.
    end

always #10 sys_clk       = ~sys_clk;
always #20 key_in       <= {$random} % 2;
//every 10ns reverse the sys_clk signal, we can get the clock which cycle is 20ns, Hz is 50MHz.
//and the data key_in should suit setup time and hold time, so it cycling need bigger than sys_clk.

flip_flop flip_flop_inst// instance & instance name
(
    .sys_clk(sys_clk)       , // connect to instance input
    .sys_rst_n(sys_rst_n)   , // connect to instance input
    .key_in(key_in)         , // connect to instance input
    
    .led_out(led_out)         // connect to instance output
);


endmodule