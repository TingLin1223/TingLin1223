module  spi_flash_seq_wr
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            rx          ,
    
    output  wire            sck         ,
    output  wire            cs_n        ,
    output  wire            mosi        

);

parameter   UART_BPS = 9600,
            CLK_FREQ = 50_000_0;//00;

wire            pi_flag;
wire    [7:0]   pi_data;

uart_rx
#(
    .UART_BPS(UART_BPS),
    .CLK_FREQ(CLK_FREQ)
)
uart_rx_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .rx          (rx       ),
    
    .po_data     (pi_data),
    .po_flag     (pi_flag)
);

flash_seq_wr_ctrl   flash_seq_wr_ctrl_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .pi_flag     (pi_flag  ),
    .pi_data     (pi_data  ),
    
    .sck         (sck      ),
    .cs_n        (cs_n     ),
    .mosi        (mosi     )
);





endmodule
