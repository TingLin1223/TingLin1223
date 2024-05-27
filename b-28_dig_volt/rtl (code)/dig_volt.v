module  dig_volt
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [7:0]   ad_data     ,

    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            shcp        ,
    output  wire            stcp        ,
    output  wire            ad_clk      
);

wire    [15:0]  volt;
wire            sign;


adc  adc_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .ad_data     (ad_data),

    .ad_clk      (ad_clk),
    .volt        (volt  ),
    .sign        (sign  )
);

seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .data       ({4'b0,volt}),
    .point      (6'b001_000),
    .sign       (sign),
    .seg_en     (1'b1),

    .ds     (ds  ),
    .oe     (oe  ),
    .shcp   (shcp),
    .stcp   (stcp)
);


endmodule