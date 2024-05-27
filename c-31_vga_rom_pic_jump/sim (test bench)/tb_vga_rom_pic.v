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

defparam vga_rom_pic_inst.vga_pic_inst.H_VALID =   10'd60;
defparam vga_rom_pic_inst.vga_pic_inst.V_VALID =   10'd50;
defparam vga_rom_pic_inst.vga_pic_inst.H_PIC   =   10'd10;
defparam vga_rom_pic_inst.vga_pic_inst.V_PIC   =   10'd10;
defparam vga_rom_pic_inst.vga_pic_inst.ADR_MAX =   14'd100;
defparam vga_rom_pic_inst.vga_pic_inst.X_MAX   =   10'd59;
defparam vga_rom_pic_inst.vga_pic_inst.Y_MAX   =   10'd49;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_SYNC    =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_BACK    =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_LEFT    =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_VALID   =   10'd60;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_RIGHT   =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_FRONT   =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.H_TOTAL   =   10'd70;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_SYNC    =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_BACK    =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_TOP     =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_VALID   =   10'd50;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_BOTTOM  =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_FRONT   =   10'd2 ;
defparam vga_rom_pic_inst.vga_ctrl_inst.V_TOTAL   =   10'd60;

//if not define this parameter, it 1 cycle needs H_total 800 * V_total 525 = 420,000 clocks, now just need 70*60 = 4200 clocks.

vga_rom_pic     vga_rom_pic_inst
(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .rgb        (rgb      ),
    .hsync      (hsync    ),
    .vsync      (vsync    )
    
);

endmodule