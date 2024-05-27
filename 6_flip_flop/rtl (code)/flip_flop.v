module flip_flop
(
    input   wire    sys_clk,
    input   wire    sys_rst_n,//low-level voltage valid.
    input   wire    key_in,
    
    output  reg     led_out//using reg type for always syntax to given value.
);

always@ (posedge sys_clk or negedge sys_rst_n)//detect posedge (rise) sys_clk or negedge (fall) sys_rst_n will implement below code.
    if (sys_rst_n == 1'b0)
        led_out <= 1'b0;
    else
        led_out <= key_in;

endmodule