module  top_inf_rcv
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            inf_in      ,
    
    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            stcp        ,
    output  wire            shcp        ,
    output  wire            led_ctrl
);

wire            repeat_en;
wire    [19:0]  data    ;


inf_rcv     inf_rcv_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .inf_in      (inf_in   ),

    .repeat_en   (repeat_en),
    .data        (data     )
);

led_ctrl    led_ctrl_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .repeat_en   (repeat_en),
                  
    .led_ctrl    (led_ctrl )
);

seg_595_dynamic     seg_595_dynamic_inst
(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .data       (data     ),
    .point      (6'b0),
    .sign       (1'b0),
    .seg_en     (1'b1),

    .ds    (ds  ),
    .oe    (oe  ),
    .shcp  (shcp),
    .stcp  (stcp)
);

endmodule