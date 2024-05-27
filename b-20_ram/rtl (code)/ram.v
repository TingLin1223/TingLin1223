module ram
(
    input       wire        sys_clk     ,
    input       wire        sys_rst_n   ,
    input       wire        wr_key      ,
    input       wire        rd_key      ,

    output      wire        ds          ,
    output      wire        oe          ,
    output      wire        shcp        ,
    output      wire        stcp        

);

wire            wr_flag;
wire            rd_flag;
wire            wr_en;
wire            rd_en;
wire    [7:0]   addr;
wire    [7:0]   wr_data;
wire    [7:0]   data_out;

key_filter
#(      .CNT_MAX(20'd999_999)
)
key_filter_inst_wr
(
        .sys_clk    (sys_clk),
        .sys_rst_n  (sys_rst_n),
        .key_in     (wr_key),
        
        .key_flag   (wr_flag)
);

key_filter
#(      .CNT_MAX(20'd999_999)
)
key_filter_inst_rd
(
        .sys_clk    (sys_clk),
        .sys_rst_n  (sys_rst_n),
        .key_in     (rd_key),
        
        .key_flag   (rd_flag)
);

ram_ctrl
#(
    .CNT_MAX(24'd9_999_999)
)
ram_ctrl_inst
(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .rd_flag        (rd_flag),
    .wr_flag        (wr_flag),

    .rd_en      (rd_en),
    .wr_en      (wr_en),
    .addr       (addr),
    .wr_data    (wr_data)
);

ram_8x256_one   ram_8x256_one_inst 
(
    .aclr (~sys_rst_n),
    .address (addr),
    .clock (sys_clk),
    .data (wr_data),
    .rden (rd_en),
    .wren (wr_en),
    .q (data_out)
    );

seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    .data       ({12'b0,data_out}),
    .point      (6'b000_000),
    .sign       (1'b0),
    .seg_en     (1'b1),

    .ds (ds),
    .oe (oe),
    .shcp(shcp),
    .stcp(stcp)
);

endmodule