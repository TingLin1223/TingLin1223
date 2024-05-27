module  freq_meter
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            test_clk    ,
    
    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            shcp        ,
    output  wire            stcp        ,
    output  wire            clk_out     
);

wire    [31:0]  freq;

freq_meter_cala freq_meter_cala_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .test_clk    (test_clk ),
    
    .freq        (freq)
);

seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .data        (freq/1000),
    .point       (6'b001_000),
    .sign        (1'b0      ),
    .seg_en      (1'b1      ),

    .ds          (ds  ),
    .oe          (oe  ),
    .shcp        (shcp),
    .stcp        (stcp)
);

test_clk    test_clk_inst 
(
    .areset ( ~sys_rst_n ),
    .inclk0 ( sys_clk ),
    .c0     ( clk_out )
    );

endmodule