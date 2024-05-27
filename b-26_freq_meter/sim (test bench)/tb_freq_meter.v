`timescale  1ns/1ns

module  tb_freq_meter();

reg             sys_clk  ;
reg             sys_rst_n;
reg             test_clk ;

wire            ds       ;
wire            oe       ;
wire            shcp     ;
wire            stcp     ;
wire            clk_out  ;

initial
    begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    #200
    sys_rst_n <= 1'b1;
    test_clk = 1'b0;
    end

always #10 sys_clk = ~sys_clk;
always #20 test_clk = ~test_clk;//test_clk = 25MHz

defparam    freq_meter_inst.freq_meter_cala_inst.SYS_CNT_MAX     = 74_9;
defparam    freq_meter_inst.freq_meter_cala_inst.SYS_RISE_MAX    = 12_4;


freq_meter freq_meter_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .test_clk    (test_clk ),
    
    .ds          (ds       ),
    .oe          (oe       ),
    .shcp        (shcp     ),
    .stcp        (stcp     ),
    .clk_out     (clk_out  )
);

endmodule