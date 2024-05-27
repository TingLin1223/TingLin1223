module led_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            repeat_en   ,
    
    output  reg             led_ctrl    
);

reg             repeat_en_d1;//align to clock.
reg             repeat_en_d2;//delay to find posedge
wire            repeat_en_rise;
reg     [21:0]  cnt;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
        repeat_en_d1  <= 1'b0;
        repeat_en_d2  <= 1'b0;
        end
    else
        begin
        repeat_en_d1  <= repeat_en;
        repeat_en_d2  <= repeat_en_d1;
        end

assign repeat_en_rise = (repeat_en_d1) & (~repeat_en_d2);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 22'd0;
    else if(repeat_en_rise == 1'b1)
        cnt <= 22'd2500_000;//light up 0.05 sec
    else if(cnt > 22'd0)
        cnt <= cnt - 1'b1;
    else
        cnt <= 22'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        led_ctrl <= 1'b1;
    else if(cnt > 22'd0)
        led_ctrl <= 1'b0;
    else 
        led_ctrl <= 1'b1;

endmodule