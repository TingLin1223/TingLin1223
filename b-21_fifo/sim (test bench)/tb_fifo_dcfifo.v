`timescale 1ns/1ns

module  tb_fifo_dcfifo();

reg     [7:0]   wr_data     ;
reg             rd_clk      ;
reg             rd_req      ;
reg             wr_clk      ;
reg             wr_req      ;
reg             sys_rst_n   ;
reg             wr_full_reg0;//delay input signal 1 clock, for signal stable, clock domian crossing process.
reg             wr_full_reg1;//delay input signal 2 clock, for signal stable, clock domian crossing process.

wire    [15:0]  rd_data     ;
wire            rd_empty    ;
wire            rd_full     ;
wire    [7:0]   rd_usedw    ;
wire            wr_empty    ;
wire            wr_full     ;
wire    [8:0]   wr_usedw    ;

initial
    begin
        wr_clk = 1'b1;
        rd_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always #10 wr_clk = ~wr_clk;
always #20 rd_clk = ~rd_clk;


always@(posedge wr_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_req <= 1'b0;
    else if(rdreq == 1'b0 && usedw < 8'd255 && full == 1'b0)
        wr_req <= 1'b1;
    else
        wr_req <= 1'b0;

always@(posedge wr_clk or negedge sys_rst_n)//wr_clk
    if(sys_rst_n == 1'b0)
        wr_data <= 8'd0;
    else if(((wr_data == 8'd255)&&(wr_req == 1'b1))||rd_req == 1'b1)
        wr_data <= 8'd0;
    else if(wr_req == 1'b1)
        wr_data <= wr_data + 1'b1;
    else
        wr_data <= wr_data;

always@(posedge rd_clk or negedge sys_rst_n)//rd_clk
    if(sys_rst_n == 1'b0)
        begin
            wr_full_reg0 <= 1'b0;
            wr_full_reg1 <= 1'b0;
        end
    else
        begin
        wr_full_reg0 <= wr_full;
        wr_full_reg1 <= wr_full_reg0;//delay input signal 2 clock, for signal stable, clock domian crossing process.
        end

always@(posedge rd_clk or negedge sys_rst_n)//rd_clk
    if(sys_rst_n == 1'b0)
        rd_req <= 1'b0;
    else if(rd_empty == 1'b1)
        rd_req <= 1'b0;
    else if(wr_full_reg1 == 1'b1)// wr & rd clock is asynchronous, need to clock domain crossing process.
        rd_req <= 1'b1;
    else
        rd_req <= rd_req;


fifo_dcfifo     fifo_dcfifo_inst
(
    .wr_data     (wr_data),
    .rd_clk      (rd_clk ),
    .rd_req      (rd_req ),
    .wr_clk      (wr_clk ),
    .wr_req      (wr_req ),
    
    .rd_data     (rd_data ),
    .rd_empty    (rd_empty),
    .rd_full     (rd_full ),
    .rd_usedw    (rd_usedw),
    .wr_empty    (wr_empty),
    .wr_full     (wr_full ),
    .wr_usedw    (wr_usedw)
);

endmodule