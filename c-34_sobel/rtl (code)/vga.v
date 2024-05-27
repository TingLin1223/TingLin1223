module  vga
(
    input   wire            clk_50MHz   ,
    input   wire            sys_rst_n   ,
    input   wire            clk_25MHz   ,
    input   wire    [7:0]   pi_data    ,
    input   wire            pi_flag     ,
    
    output  wire            hsync       ,
    output  wire            vsync       ,
    output  wire    [7:0]   rgb         
);

wire    [9:0]   pix_x;
wire    [9:0]   pix_y;
wire    [7:0]   pix_data;

vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (clk_25MHz),
    .sys_rst_n   (sys_rst_n),
    .pix_data    (pix_data),

    .hsync       (hsync),
    .vsync       (vsync),
    .pix_x       (pix_x),
    .pix_y       (pix_y),
    .rgb         (rgb  )

);

vga_pic     vga_pic_inst
(
    .sys_clk     (clk_25MHz),
    .sys_rst_n   (sys_rst_n),
    .pix_x       (pix_x),
    .pix_y       (pix_y),
    .clk_50MHz   (clk_50MHz),
    .pi_data     (pi_data),
    .pi_flag     (pi_flag),
    
    
    .pix_data    (pix_data)
);

endmodule