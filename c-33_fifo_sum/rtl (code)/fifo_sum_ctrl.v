module  fifo_sum_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            pi_flag     ,
    input   wire    [7:0]   pi_data     ,
    
    output  reg             po_flag     ,
    output  reg     [7:0]   po_sum      
);

parameter   CNT_COL_MAX = 8'd3,
            CNT_ROW_MAX = 8'd4;

reg     [7:0]   cnt_row;
reg     [7:0]   cnt_col;
reg             wr_en1;
reg     [7:0]   data_in1;
reg             wr_en2;
reg     [7:0]   data_in2;
reg             rd_en;
reg             dout_flag;

wire    [7:0]   data_out1;
wire    [7:0]   data_out2;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_col <= 8'd0;
    else if(cnt_col == CNT_COL_MAX && pi_flag == 1'b1)
        cnt_col <= 8'd0;
    else if(pi_flag == 1'b1)
        cnt_col <= cnt_col + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_row <= 8'd0;
    else if(cnt_row == CNT_ROW_MAX && pi_flag == 1'b1 && cnt_col == CNT_COL_MAX)
        cnt_row <= 8'd0;
    else if(cnt_col == CNT_COL_MAX && pi_flag == 1'b1)
        cnt_row <= cnt_row + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en1 <= 1'b0;
    else if(cnt_row == 8'd0)
        wr_en1 <= pi_flag;
    else if(cnt_row == 8'd2 || cnt_row == 8'd3 || (cnt_row == 8'd4 && cnt_col == 8'd0))
        wr_en1 <= dout_flag;
    else
        wr_en1 <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in1 <= 8'b0;
    else if(cnt_row == 8'd0 && pi_flag == 1'b1)
        data_in1 <= pi_data;
    else if((cnt_row == 8'd2 || cnt_row == 8'd3 || (cnt_row == 8'd4 && cnt_col == 8'd0)) && dout_flag == 1'b1)
        data_in1 <= data_out2;
    
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en2 <= 1'b0;
    else if(cnt_row >= 8'd1 && cnt_row < CNT_ROW_MAX)
        wr_en2 <= pi_flag;
    else
        wr_en2 <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in2 <= 8'b0;
    else if(cnt_row >= 8'd1 && cnt_row < CNT_ROW_MAX && pi_flag == 1'b1)
        data_in2 <= pi_data;
    
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(cnt_row >= 8'd2 && pi_flag == 1'b1)
        rd_en <= 1'b1;
    else
        rd_en <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_flag <= 1'b0;
    else
        dout_flag <= rd_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <= 1'b0;
    else 
        po_flag <= dout_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_sum <= 8'b0;
    else if(dout_flag == 1'b1)
        po_sum <= (data_out1 + data_out2 + pi_data);

fifo    fifo_inst_1 
(
    .clock  ( sys_clk   ),
    .data   ( data_in1  ),
    .rdreq  ( rd_en     ),
    .wrreq  ( wr_en1    ),
    .q      ( data_out1 )
    );

fifo    fifo_inst_2
(
    .clock  ( sys_clk   ),
    .data   ( data_in2  ),
    .rdreq  ( rd_en     ),
    .wrreq  ( wr_en2    ),
    .q      ( data_out2 )
    );


endmodule