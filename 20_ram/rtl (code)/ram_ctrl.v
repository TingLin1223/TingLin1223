module ram_ctrl
#(
    parameter   CNT_MAX = 24'd9_999_999
)
(
    input       wire            sys_clk     ,
    input       wire            sys_rst_n   ,
    input       wire            rd_flag     ,
    input       wire            wr_flag     ,

    output      reg             rd_en       ,
    output      reg             wr_en       ,
    output      reg     [7:0]   addr        ,
    output      wire    [7:0]   wr_data     
);

reg     [23:0]      cnt_200ms;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_200ms <= 24'd0;
    else if((cnt_200ms == CNT_MAX)||(wr_flag == 1'b1)||(rd_flag ==1'b1))// 200ms or wr_button or rd_button pressed, start at 0.
        cnt_200ms <= 24'd0;
    else if(rd_en == 1'b1)
        cnt_200ms <= cnt_200ms + 1;
    else
        cnt_200ms <= 24'd0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(wr_flag == 1'b1)
        rd_en <= 1'b0;
    else if(rd_flag == 1'b1 && wr_en == 1'b0)
        rd_en <= 1'b1;
    else
        rd_en <= rd_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en <= 1'b0;
    else if(addr == 8'd255)
        wr_en <= 1'b0;
    else if(wr_flag == 1'b1)
        wr_en <= 1'b1;
    else
        wr_en <= wr_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr <= 8'd0;
    else if((addr == 8'd255 && cnt_200ms == CNT_MAX)
    ||(addr == 8'd255 && wr_en == 1'b1)||(wr_flag == 1'b1)||(rd_flag ==1'b1))
        addr <= 8'd0;
    else if(wr_en == 1'b1)
        addr <= addr + 1;
    else if ((rd_en == 1'b1) && (cnt_200ms == CNT_MAX))
        addr <= addr + 1;
    else
        addr <= addr;
        
assign wr_data = (wr_en == 1'b1) ? addr : 8'd0;


endmodule