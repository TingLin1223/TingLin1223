module water_led
#(      parameter       CNT_MAX = 25'd24_999_999
)
(
        input   wire            sys_clk,
        input   wire            sys_rst_n,
        output  reg     [3:0]   led_out
);

reg [24:0]  cnt;
reg     cnt_flag;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        cnt <= 24'd0;
    else if (cnt == CNT_MAX)
        cnt <= 24'd0;
    else
        cnt <= cnt + 24'd1;
        
always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        cnt_flag <= 1'b0;
    else if (cnt == (CNT_MAX - 25'd1))
        cnt_flag <= 1'b1;
    else
        cnt_flag <= 1'b0;
        
always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        led_out <= 4'b1110;
    else if ((led_out == 4'b0111) && (cnt_flag == 1'b1))
        led_out <= 4'b1110;
    else if (cnt_flag == 1'b1)
        led_out <= ((led_out << 1)+4'b1);// if cnt_flag = high-level, led_out array shfit left 1 bit and add 1'b1 to make singal correct.
    else                                 // for example, 4'b1110 shfit left 1 bit --> 4'b1100, so need to add 1 bit --> 4'b1101
        led_out <= led_out;


endmodule