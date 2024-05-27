module breath_led
#(
    parameter   CNT_1US = 6'd49,
    parameter   CNT_1MS = 10'd999,
    parameter   CNT_1S  = 10'd999
)
(
    input       wire        sys_clk,
    input       wire        sys_rst_n,
    output      reg         led_out
);

reg     [5:0]       cnt_1us;
reg     [9:0]       cnt_1ms;
reg     [9:0]       cnt_1s;
reg                 cnt_en;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        cnt_1us <= 6'd0;
    else if (cnt_1us == CNT_1US)
        cnt_1us <= 6'd0;
    else
        cnt_1us <= cnt_1us + 6'd1;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        cnt_1ms <= 10'd0;
    else if ((cnt_1ms == CNT_1MS)&&(cnt_1us == CNT_1US))
        cnt_1ms <= 10'd0;
    else if (cnt_1us == CNT_1US)
        cnt_1ms <= cnt_1ms + 10'd1;
    else
        cnt_1ms <= cnt_1ms;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        cnt_1s <= 10'd0;
    else if ((cnt_1s == CNT_1S)&&
            (cnt_1ms == CNT_1MS)&&(cnt_1us == CNT_1US))
        cnt_1s <= 10'd0;
    else if ((cnt_1ms == CNT_1MS)&&
            (cnt_1us == CNT_1US))
        cnt_1s <= cnt_1s + 10'd1;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        cnt_en <= 1'b0;
    else if ((cnt_1s == CNT_1S)&&
            (cnt_1ms == CNT_1MS)&&(cnt_1us == CNT_1US))
        cnt_en <= ~cnt_en;
    else
        cnt_en <= cnt_en;

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        led_out <= 1'b1;
    else if ((cnt_1ms <= cnt_1s)&&(cnt_en == 1'b0)
            || (cnt_1ms >= cnt_1s) &&(cnt_en == 1'b1))
        led_out <= 1'b0;
    else
        led_out <= 1'b1;

endmodule