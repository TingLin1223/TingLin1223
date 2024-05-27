module  fifo_sum
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            rx          ,
    
    output  wire            tx
);

parameter   CLK_FREQ = 50_000_000;

wire  [7:0] rx_data;
wire        rx_falg;
wire        po_flag;
wire  [7:0] po_sum ;

uart_rx
#(
    .UART_BPS(9600      ),
    .CLK_FREQ(CLK_FREQ)
)
uart_rx_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .rx          (rx       ),
    
    .po_data     (rx_data  ),
    .po_flag     (rx_falg  )
);

fifo_sum_ctrl   fifo_sum_ctrl_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .pi_flag     (rx_falg  ),
    .pi_data     (rx_data  ),
    
    .po_flag     (po_flag  ),
    .po_sum      (po_sum   )
);

uart_tx
#(
    .UART_BPS(9600      ),
    .CLK_FREQ(CLK_FREQ)
)
uart_tx_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .pi_data     (po_sum   ),
    .pi_falg     (po_flag  ),
    
    .tx          (tx       )
);
endmodule