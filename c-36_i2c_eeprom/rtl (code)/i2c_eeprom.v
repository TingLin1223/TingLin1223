module  i2c_eeprom
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_wr      ,
    input   wire            key_rd      ,

    output  wire            ds          ,
    output  wire            oe          ,
    output  wire            shcp        ,
    output  wire            stcp        ,
    output  wire            i2c_scl     ,
    inout   wire            i2c_sda     
);

parameter   CNT_MAX = 20'd999_999;

wire            write       ;
wire            read        ;
wire    [7:0]   fifo_data   ;
wire            i2c_start   ;
wire            wr_en       ;
wire    [15:0]  byte_addr   ;
wire    [7:0]   wr_data     ;
wire            rd_en       ;
wire    [7:0]   rd_data     ;
wire            i2c_end     ;
wire            i2c_clk     ;




key_filter
#(      .CNT_MAX(CNT_MAX)
)
key_filter_wr
(
        .sys_clk    (sys_clk    ),
        .sys_rst_n  (sys_rst_n  ),
        .key_in     (key_wr     ),
        
        .key_flag   (write      )
);

key_filter
#(      .CNT_MAX(CNT_MAX)
)
key_filter_rd
(
        .sys_clk    (sys_clk    ),
        .sys_rst_n  (sys_rst_n  ),
        .key_in     (key_rd     ),
        
        .key_flag   (read       )
);

seg_595_dynamic seg_595_dynamic_inst
(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .data        (fifo_data   ),
    .point       (),// non-use
    .sign        (),// non-use
    .seg_en      (1'b1        ),

    .ds          (ds          ),
    .oe          (oe          ),
    .shcp        (shcp        ),
    .stcp        (stcp        )
);

i2c_ctrl
#
(
    .SYS_CLK_FREQ('d50_000_000),
    .SCL_FREQ    ('d250_000   ),
    .DEVICE_ADDR (7'b1010_011 )
)
//SCL_FREQ is eeprom working frequency 250K Hz
i2c_ctrl_inst
(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .i2c_start   (i2c_start   ),
    .wr_en       (wr_en       ),
    .byte_addr   (byte_addr   ),
    .wr_data     (wr_data     ),
    .rd_en       (rd_en       ),
    .addr_num    (1'b1        ),
    
    .i2c_scl     (i2c_scl     ),
    .rd_data     (rd_data     ),
    .i2c_end     (i2c_end     ),
    .i2c_clk     (i2c_clk     ),
    .i2c_sda     (i2c_sda     )
);

i2c_rw_data i2c_rw_data_inst
(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .write       (write       ),
    .read        (read        ),
    .rd_data     (rd_data     ),
    .i2c_end     (i2c_end     ),
    .i2c_clk     (i2c_clk     ),
    
    .i2c_start   (i2c_start   ),
    .wr_en       (wr_en       ),
    .byte_addr   (byte_addr   ),
    .wr_data     (wr_data     ),
    .rd_en       (rd_en       ),
    .fifo_data   (fifo_data   )
);



endmodule