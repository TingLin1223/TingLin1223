`timescale 1ns/1ns

module  tb_fifo();

reg             sys_clk;
reg             sys_rst_n;
reg     [7:0]   data;
reg             rdreq;
reg             wrreq;

wire            empyt;
wire            full;
wire    [7:0]   q;
wire    [7:0]   usedw;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wrreq <= 1'b0;
    else if(rdreq == 1'b0 && usedw < 8'd255 && full == 1'b0)
        wrreq <= 1'b1;
    else
        wrreq <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data <= 8'd0;
    else if(((data == 8'd255)&&(wrreq == 1'b1))||rdreq == 1'b1)
        data <= 8'd0;
    else if(wrreq == 1'b1)
        data <= data + 1'b1;
    else
        data <= data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rdreq <= 1'b0;
    else if(full == 1'b1)
        rdreq <= 1'b1;
    else if(empyt == 1'b1)
        rdreq <= 1'b0;
    else
        rdreq <= rdreq;

fifo    fifo_inst
(
    .sys_clk    (sys_clk),
    .data       (data),
    .rdreq      (rdreq),
    .wrreq      (wrreq),
    
    .empyt      (empyt),
    .full       (full),
    .q          (q),
    .usedw      (usedw)
);



endmodule
