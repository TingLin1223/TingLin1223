`timescale  1ns/1ns

module  tb_sobel();

reg             sys_clk         ;
reg             sys_rst_n       ;
reg             rx              ;
reg     [7:0]   data_mem[9999:0];

wire            tx;
wire            hsync;
wire            vsync;
wire    [7:0]   rgb;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always #10 sys_clk = ~sys_clk;

initial
    $readmemh("D:/FPGA/41_sobel/sim/logo.txt",data_mem);

initial
    begin
        rx <= 1'b1;
        #200
        rx_byte();
    end
    
task    rx_byte();
    integer j;
        for(j=0; j<10000; j=j+1)
            rx_bit(data_mem[j]);
endtask

task    rx_bit
(
    input   [7:0]   data
);

    integer i;

for(i=0; i<10; i = i+1)
    begin
    case(i)
        0:rx     <=  1'b0   ;
        1:rx     <=  data[0];
        2:rx     <=  data[1];
        3:rx     <=  data[2];
        4:rx     <=  data[3];
        5:rx     <=  data[4];
        6:rx     <=  data[5];
        7:rx     <=  data[6];
        8:rx     <=  data[7];
        9:rx     <=  1'b1   ;
    endcase
    #(5*20);// i++ delay time = 5208 cnt(baurd rate) * 20 ns (sys_clk),divide by 1000
    end
endtask

defparam sobel_inst.CLK_FREQ = 50_000;

sobel   sobel_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .rx          (rx),

    .tx          (tx),
    .hsync       (hsync),
    .vsync       (vsync),
    .rgb         (rgb)
);

endmodule