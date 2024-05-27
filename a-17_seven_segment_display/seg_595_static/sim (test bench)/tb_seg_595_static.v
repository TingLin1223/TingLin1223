`timescale 1ns/1ns

module tb_seg_595_static();

reg             sys_clk;
reg             sys_rst_n;

wire            ds;
wire            shcp;
wire            stcp;
wire            oe;


initial
    begin
        sys_clk      = 1'b1;
        sys_rst_n   <= 1'b0;
        #10
        sys_rst_n   <= 1'b1;
    end

always #10 sys_clk = ~sys_clk;

defparam seg_595_static_inst.CNT_MAX = 24_99; // divide by 10000;

seg_595_static seg_595_static_inst
(
    .sys_clk    (sys_clk)   ,
    .sys_rst_n  (sys_rst_n) ,

    .ds         (ds)        ,
    .shcp       (shcp)      ,
    .stcp       (stcp)      ,
    .oe         (oe)
);

endmodule