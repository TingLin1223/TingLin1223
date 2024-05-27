`timescale 1ns/1ns
module tb_led_ctrl();

reg             sys_clk;
reg             sys_rst_n;
reg             repeat_en;

wire            led_ctrl;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        repeat_en <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
        #300
        repeat_en <= 1'b1;
        #560_000
        repeat_en <= 1'b0;
        #110_000_000
        repeat_en <= 1'b1;
        #560_000
        repeat_en <= 1'b0;
    end

always #10 sys_clk = ~sys_clk;


led_ctrl    led_ctrl_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .repeat_en   (repeat_en),
                  
    .led_ctrl    (led_ctrl )
);


endmodule