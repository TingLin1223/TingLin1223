module  hdmi_colorbar
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    
    output  wire            hdmi_r_p    ,
    output  wire            hdmi_r_n    ,
    output  wire            hdmi_g_p    ,
    output  wire            hdmi_g_n    ,
    output  wire            hdmi_b_p    ,
    output  wire            hdmi_b_n    ,
    output  wire            hdmi_clk_p  ,
    output  wire            hdmi_clk_n  ,
    output  wire            ddc_scl     ,// i2c , if not want to read the information which storage at rom, just set to high-level
    output  wire            ddc_sga      // i2c , if not want to read the information which storage at rom, just set to high-level
);

wire            clk_25MHz;
wire            clk_125MHz;
wire            locked;
wire            rst_n;
wire            hsync;
wire            vsync;
wire    [9:0]   pix_x;
wire    [9:0]   pix_y;
wire    [15:0]  rgb;
wire    [15:0]  pix_data;
wire            rgb_valid;
wire    [7:0]   rgb_red  ;
wire    [7:0]   rgb_green;
wire    [7:0]   rgb_blue ;

assign  rst_n       = (locked & sys_rst_n);
assign  rgb_red     = {rgb[15:11],3'b0};//vga is rgb 565, means red is high 5 bit, change to rgb 888, catch high 5 bit and other give 0.
assign  rgb_green   = {rgb[10:5],2'b0};
assign  rgb_blue    = {rgb[4:0],3'b0};
assign  ddc_scl     = 1'b1;
assign  ddc_sga     = 1'b1;

clk_gen clk_gen_inst 
(
    .areset ( ~sys_rst_n ),
    .inclk0 ( sys_clk    ),
    .c0     ( clk_25MHz  ),
    .c1     ( clk_125MHz ),
    .locked ( locked     )
);

vga_ctrl    vga_ctrl_inst
(
    .vga_clk     (clk_25MHz ),
    .sys_rst_n   (rst_n     ),
    .pix_data    (pix_data  ),

    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .pix_x       (pix_x     ),
    .pix_y       (pix_y     ),
    .rgb         (rgb       ),
    .rgb_valid   (rgb_valid )
);

vga_pic vga_pic_inst
(
    . vga_clk     (clk_25MHz),
    . sys_rst_n   (rst_n    ),
    . pix_x       (pix_x    ),
    . pix_y       (pix_y    ),
    
    . pix_data    (pix_data )
);

hdmi_ctrl   hdmi_ctrl_inst
(
    .vga_clk     (clk_25MHz ),
    .clk_5x      (clk_125MHz),
    .sys_rst_n   (rst_n     ),
    .hsync       (hsync     ),
    .vsync       (vsync     ),
    .rgb_valid   (rgb_valid ),
    .rgb_red     (rgb_red   ),
    .rgb_green   (rgb_green ),
    .rgb_blue    (rgb_blue  ),

    .hdmi_r_p    (hdmi_r_p  ),
    .hdmi_r_n    (hdmi_r_n  ),
    .hdmi_g_p    (hdmi_g_p  ),
    .hdmi_g_n    (hdmi_g_n  ),
    .hdmi_b_p    (hdmi_b_p  ),
    .hdmi_b_n    (hdmi_b_n  ),
    .hdmi_clk_p  (hdmi_clk_p),
    .hdmi_clk_n  (hdmi_clk_n)
);

endmodule