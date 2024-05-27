module sobel
(
    input           sys_clk     ,
    input           sys_rst_n   ,
    input           rx          ,

    output          tx          ,
    output          hsync       ,
    output          vsync       ,
    output  [7:0]   rgb         
);

parameter CLK_FREQ = 50_000_000;

wire            clk_25MHz;
wire            clk_50MHz;
wire            locked;
wire            rst_n;
wire    [7:0]   pi_data;
wire            pi_flag;
wire            po_flag;
wire    [7:0]   po_sum;

assign  rst_n = (locked & sys_rst_n);

clk_gen clk_gen_inst 
(
    .areset ( ~sys_rst_n ),
    .inclk0 ( sys_clk    ),
    .c0     ( clk_25MHz  ),
    .c1     ( clk_50MHz  ),
    .locked ( locked     )
    );

uart_rx
#(
    .UART_BPS   ('d9600      ),
    .CLK_FREQ   (CLK_FREQ)
)
uart_rx_inst
(
    .sys_clk     (clk_50MHz),
    .sys_rst_n   (rst_n),
    .rx          (rx),
    
    .po_data     (pi_data),
    .po_flag     (pi_flag)
);

uart_tx 
#(
    .UART_BPS   ('d9600      ),
    .CLK_FREQ   (CLK_FREQ)
)
uart_tx_inst
(
    .sys_clk     (clk_50MHz),
    .sys_rst_n   (rst_n),
    .pi_data     (po_sum),
    .pi_falg     (po_flag),

    .tx          (tx)
);

vga vga_inst
(
    .clk_50MHz   (clk_50MHz),
    .sys_rst_n   (rst_n),
    .clk_25MHz   (clk_25MHz),
    .pi_data     (po_sum),
    .pi_flag     (po_flag),
    
    .hsync       (hsync),
    .vsync       (vsync),
    .rgb         (rgb)
);

sobel_ctrl  sobel_ctrl_inst
(
    .sys_clk     (clk_50MHz),
    .sys_rst_n   (rst_n),
    .pi_flag     (pi_flag),
    .pi_data     (pi_data),
    
    .po_flag     (po_flag),
    .po_sum      (po_sum)
);

endmodule