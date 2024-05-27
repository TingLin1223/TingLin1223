module  dds_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [3:0]   wave_sel    ,

    output  wire    [7:0]   freq_data   
);

parameter   F_WORD = 32'd42949;//need to generate 500Hz clk_out, so F_WORD = 500Hz * 2^32 / 50MHz = 42949.
parameter   P_WORD = 12'd1024;//rom address total is 4096, meas phase shife 90 degrees.

reg     [31:0]  freq_add;
reg     [11:0]  rom_addr_reg;
reg     [13:0]  rom_addr;//4096+12288 need 14 bit width.

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        freq_add <= 32'd0;
    else
        freq_add <= freq_add + F_WORD;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr_reg <= 12'd0;
    else
        rom_addr_reg <= freq_add[31:20] + P_WORD;//due to rom_addr_reg only 12 bit width, so if value over 4095, restart from 0.

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr <= 14'd0;
    else
        case(wave_sel)
            4'b0001 : rom_addr <= rom_addr_reg;//sin wave position address
            4'b0010 : rom_addr <= rom_addr_reg + 14'd4096;//square wave address start at 4096
            4'b0100 : rom_addr <= rom_addr_reg + 14'd8192;//triangle wave address start at 8192
            4'b1000 : rom_addr <= rom_addr_reg + 14'd12288;//sawtooth wave  address start at 12288
        default:    rom_addr <= rom_addr_reg;
        endcase

rom_wave    rom_wave_inst 
(
    .address    ( rom_addr  ),
    .clock      ( sys_clk   ),
    .q          ( freq_data )
);


endmodule