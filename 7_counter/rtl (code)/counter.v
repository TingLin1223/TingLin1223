module counter
#(
    parameter   CNT_MAX = 25'd24_999_999 //define this parameter, up-level code can re-define this parameter.
)
(
    input   wire    sys_clk,
    input   wire    sys_rst_n,
    
    output  reg led_out 
);


reg     [24:0]      count;
// because the sys_clk frequency is 50MHz, it's 1 cycle is 20ns, so 25_000_000 cycles = 0.5ms
// and the 25_000_000 present in binary is 1_0111_1101_0111_1000_0100_0000, 25 bit width.
// the counter starts at count[0], so it interval with count[24_999_999] is 25_000_000 cycles.

//when counter reach count_max value, it become zero and restart to counting.
always@ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        count <= 25'd0;
    else if (count == CNT_MAX)
        count <= 25'd0;
    else
        count <= count + 25'd1;

always@ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        led_out <= 1'b0;
    else if (count == CNT_MAX)
        led_out <= ~led_out;
    else
        led_out <= led_out;


endmodule