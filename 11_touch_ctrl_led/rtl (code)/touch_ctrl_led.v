module touch_ctrl_led
(
        input   wire    sys_clk,
        input   wire    sys_rst_n,
        input   wire    touch_key,
        
        output  reg     led
);

reg     touch_key_1;
reg     touch_key_2;
wire    touch_flag;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        begin
            touch_key_1 <= 1'b1;
            touch_key_2 <= 1'b1;
        end
    else
        begin
            touch_key_1 <= touch_key;
            touch_key_2 <= touch_key_1;
        end 

assign touch_flag =((touch_key_1 == 1'b0) && (touch_key_2 == 1'b1));

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        led <= 1'b1;
    else if (touch_flag == 1'b1)
        led <= ~led;
    else
        led <= led;


endmodule