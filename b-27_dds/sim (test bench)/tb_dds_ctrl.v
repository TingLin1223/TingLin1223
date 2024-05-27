`timescale  1ns/1ns

module tb_dds_ctrl();

reg             sys_clk  ;
reg             sys_rst_n;
reg     [3:0]   wave_sel ;

wire    [7:0]   freq_data;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <=    1'b0;
        wave_sel <=     4'b0000;
        #200
        sys_rst_n <= 1'b1;
        #10000
        wave_sel <=     4'b0001;
        #7000000
        wave_sel <=     4'b0010;
        #7000000
        wave_sel <=     4'b0100;
        #7000000
        wave_sel <=     4'b1000;
        #7000000
        wave_sel <=     4'b0000;
    end

always #10 sys_clk = ~ sys_clk;

dds_ctrl dds_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .wave_sel    (wave_sel),
    
    .freq_data   (freq_data)
);

endmodule