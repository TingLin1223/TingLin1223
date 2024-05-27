module  key_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [3:0]   key         ,

    output  reg     [3:0]   wave_sel    
);

wire        key0;
wire        key1;
wire        key2;
wire        key3;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wave_sel <= 4'b0000;
    else if(key3 == 1'b1)
        wave_sel <= 4'b1000;
    else if(key2 == 1'b1)
        wave_sel <= 4'b0100;
    else if(key1 == 1'b1)
        wave_sel <= 4'b0010;
    else if(key0 == 1'b1)
        wave_sel <= 4'b0001;

key_filter
#(      .CNT_MAX(999_999)
)
key_filter_inst_0
(
        .sys_clk     (sys_clk   ),
        .sys_rst_n   (sys_rst_n ),
        .key_in      (key[0]    ),
        
        .key_flag    (key0      )
);

key_filter
#(      .CNT_MAX(999_999)
)
key_filter_inst_1
(
        .sys_clk     (sys_clk   ),
        .sys_rst_n   (sys_rst_n ),
        .key_in      (key[1]    ),
        
        .key_flag    (key1      )
);

key_filter
#(      .CNT_MAX(999_999)
)
key_filter_inst_2
(
        .sys_clk     (sys_clk   ),
        .sys_rst_n   (sys_rst_n ),
        .key_in      (key[2]    ),
        
        .key_flag    (key2      )
);

key_filter
#(      .CNT_MAX(999_999)
)
key_filter_inst_3
(
        .sys_clk     (sys_clk   ),
        .sys_rst_n   (sys_rst_n ),
        .key_in      (key[3]    ),
        
        .key_flag    (key3      )
);

endmodule