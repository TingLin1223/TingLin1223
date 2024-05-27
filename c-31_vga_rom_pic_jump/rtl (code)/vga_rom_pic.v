module  vga_rom_pic
(
    input        wire           sys_clk,
    input        wire           sys_rst_n,
    
    output       wire    [15:0] rgb,
    output       wire           hsync,
    output       wire           vsync
    
);

wire            vga_clk ;
wire            locked  ;
wire            rst_n   ;

wire  [15:0]    pix_data ;
wire  [9:0]     pix_x   ;
wire  [9:0]     pix_y   ;

assign rst_n = (sys_rst_n && locked);

clk_gen	clk_gen_inst 
(
	.areset (~sys_rst_n ),
	.inclk0 (sys_clk    ),
	.c0     (vga_clk    ),
	.locked (locked     )
	);



vga_ctrl vga_ctrl_inst
(
     .vga_clk     (vga_clk  ),
     .sys_rst_n   (rst_n    ),
     .pix_data    (pix_data),
     
     .hsync       (hsync),
     .vsync       (vsync),
     .pix_x       (pix_x),
     .pix_y       (pix_y),
     .rgb         (rgb)
);

vga_pic vga_pic_inst
(
    .sys_clk     (vga_clk),
    .sys_rst_n   (rst_n),
    .pix_x       (pix_x),
    .pix_y       (pix_y),
    
    .pix_data    (pix_data)
);

endmodule