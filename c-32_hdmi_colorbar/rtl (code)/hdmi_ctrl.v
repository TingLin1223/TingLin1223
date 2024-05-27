module  hdmi_ctrl
(
    input   wire            vga_clk     ,
    input   wire            clk_5x      ,
    input   wire            sys_rst_n   ,
    input   wire            hsync       ,
    input   wire            vsync       ,
    input   wire            rgb_valid   ,
    input   wire    [7:0]   rgb_red     ,
    input   wire    [7:0]   rgb_green   ,
    input   wire    [7:0]   rgb_blue    ,

    output  wire            hdmi_r_p    ,
    output  wire            hdmi_r_n    ,
    output  wire            hdmi_g_p    ,
    output  wire            hdmi_g_n    ,
    output  wire            hdmi_b_p    ,
    output  wire            hdmi_b_n    ,
    output  wire            hdmi_clk_p  ,
    output  wire            hdmi_clk_n  
);

wire    [9:0]   data_out_r;
wire    [9:0]   data_out_g;
wire    [9:0]   data_out_b;


encoder encoder_inst_red
(
    .vga_clk     (vga_clk),
    .sys_rst_n   (sys_rst_n),
    .hsync       (hsync),
    .vsync       (vsync),
    .rgb_valid   (rgb_valid),
    .data_in     (rgb_red),
    
    .data_out    (data_out_r)
);

encoder encoder_inst_green
(
    .vga_clk     (vga_clk),
    .sys_rst_n   (sys_rst_n),
    .hsync       (hsync),
    .vsync       (vsync),
    .rgb_valid   (rgb_valid),
    .data_in     (rgb_green),
    
    .data_out    (data_out_g)
);

encoder encoder_inst_blue
(
    .vga_clk     (vga_clk),
    .sys_rst_n   (sys_rst_n),
    .hsync       (hsync),
    .vsync       (vsync),
    .rgb_valid   (rgb_valid),
    .data_in     (rgb_blue),
    
    .data_out    (data_out_b)
);

par_to_ser  par_to_ser_inst_red
(
    .clk_5x  (clk_5x),
    .data_in (data_out_r),
    
    .ser_p   (hdmi_r_p),
    .ser_n   (hdmi_r_n)
);

par_to_ser  par_to_ser_inst_green
(
    .clk_5x  (clk_5x),
    .data_in (data_out_g),
    
    .ser_p   (hdmi_g_p),
    .ser_n   (hdmi_g_n)
);

par_to_ser  par_to_ser_inst_blue
(
    .clk_5x  (clk_5x),
    .data_in (data_out_b),
    
    .ser_p   (hdmi_b_p),
    .ser_n   (hdmi_b_n)
);

par_to_ser  par_to_ser_inst_clk
(
    .clk_5x  (clk_5x),
    .data_in (10'b1111_0000),
    
    .ser_p   (hdmi_clk_p),
    .ser_n   (hdmi_clk_n)
);


endmodule