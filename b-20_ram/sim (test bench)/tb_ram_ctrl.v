`timescale 1ns/1ns

module tb_ram_ctrl
();

reg             sys_clk;
reg             sys_rst_n;
reg             rd_flag;
reg             wr_flag;

wire            rd_en;
wire            wr_en;
wire    [7:0]   addr;
wire    [7:0]   wr_data;
wire    [7:0]   data_out;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        rd_flag <= 1'b0;
        wr_flag <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
        #10
//rd_flag
        rd_flag <= 1'b1;
        #20
        rd_flag <= 1'b0;
        #6000
//wr_flag
        wr_flag <= 1'b1;
        #20
        wr_flag <= 1'b0;
        #6000
//rd_flag
        rd_flag <= 1'b1;
        #20
        rd_flag <= 1'b0;
        #6000
//rd_flag
        rd_flag <= 1'b1;
        #20
        rd_flag <= 1'b0;
    end
    
always#10 sys_clk = ~sys_clk;

ram_ctrl
#(
    .CNT_MAX(24'd1)
)
ram_ctrl_inst
(
    .sys_clk        (sys_clk),
    .sys_rst_n      (sys_rst_n),
    .rd_flag        (rd_flag),
    .wr_flag        (wr_flag),
    
    .rd_en      (rd_en),
    .wr_en      (wr_en),
    .addr       (addr),
    .wr_data    (wr_data)
);

ram_8x256_one   ram_8x256_one_inst (
    .aclr (~sys_rst_n),
    .address (addr),
    .clock (sys_clk),
    .data (wr_data),
    .rden (rd_en),
    .wren (wr_en),
    .q (data_out)
    );



endmodule