module  spi_flash_se
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_in      ,
    
    output  wire            sck         ,
    output  wire            cs_n        ,
    output  wire            mosi        

);

wire    key_flag;

flash_se_ctrl   flash_se_ctrl_inst
(
    . sys_clk     (sys_clk  ),
    . sys_rst_n   (sys_rst_n),
    . key_flag    (key_flag ),
    
    . sck         (sck      ),
    . cs_n        (cs_n     ),
    . mosi        (mosi     )
);

key_filter
#(      .CNT_MAX(20'd999_999)
)
key_filter_inst
(
        .sys_clk     (sys_clk  ),
        .sys_rst_n   (sys_rst_n),
        .key_in      (key_in   ),
        
        .key_flag    (key_flag )
);


endmodule
