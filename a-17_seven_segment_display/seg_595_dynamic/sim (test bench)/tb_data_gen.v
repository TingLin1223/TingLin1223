`timescale 1ns/1ns

module tb_data_gen ();

reg     sys_clk;
reg     sys_rst_n;

wire    [19:0]  data;
wire    [5:0]   point;
wire            sign;
wire            seg_en;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
    end
    
always #10 sys_clk = ~sys_clk;
data_gen
#(
    .CNT_100MS  (23'd9),
    .DATA_MAX   (20'd9)
)
tb_data_gen
(
        .sys_clk    (sys_clk),
        .sys_rst_n  (sys_rst_n),
        
        .data       (data),
        .point      (point),
        .sign       (sign),
        .seg_en     (seg_en)
);
endmodule