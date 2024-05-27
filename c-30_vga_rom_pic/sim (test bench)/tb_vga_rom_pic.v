`timescale 1ns/1ns
module tb_vga_rom_pic();

reg            sys_clk;
reg            sys_rst_n;

wire    [15:0] rgb;
wire           hsync;
wire           vsync;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;

vga_rom_pic     vga_rom_pic_inst
(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .rgb        (rgb      ),
    .hsync      (hsync    ),
    .vsync      (vsync    )
    
);

endmodule