module  sobel_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            pi_flag     ,
    input   wire    [7:0]   pi_data     ,
    
    output  reg             po_flag     ,
    output  reg     [7:0]   po_sum      
);

parameter   CNT_COL_MAX = 8'd99,
            CNT_ROW_MAX = 8'd99,
            CNT_RD_MAX  = 8'd99;
parameter   THRESHOLD   =   8'b000_011_00   ;
parameter   BLACK       =   8'b0000_0000    ,
            WHITE       =   8'b1111_1111    ;

reg     [7:0]   cnt_row;
reg     [7:0]   cnt_col;
reg             wr_en1;
reg     [7:0]   data_in1;
reg             wr_en2;
reg     [7:0]   data_in2;
reg             rd_en;
reg             dout_flag;
//above is fifo_sum_ctrl
reg     [7:0]   cnt_rd;
reg             dout_flag_reg;
reg     [7:0]   data_out1_reg;
reg     [7:0]   data_out2_reg;
reg     [7:0]   pi_data_reg;
reg     [7:0]   a1;
reg     [7:0]   a2;
reg     [7:0]   a3;
reg     [7:0]   b1;
reg     [7:0]   b2;
reg     [7:0]   b3;
reg     [7:0]   c1;
reg     [7:0]   c2;
reg     [7:0]   c3;
reg             gx_gy_flag;
reg             gxy_flag;
reg             com_flag;
reg     [8:0]   gx; // due to highest bit gx[8] is symbol negative or passive and the pi_data max value is 7 due to pre-process. (grey process)
reg     [8:0]   gy;
reg     [7:0]  gxy;

wire    [7:0]   data_out1;
wire    [7:0]   data_out2;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd <= 8'd0;
    else if(cnt_rd == CNT_RD_MAX && rd_en == 1'b1)
        cnt_rd <= 8'd0;
    else if(rd_en == 1'b1)
        cnt_rd <= cnt_rd + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_flag_reg <= 1'b0;
    else
        dout_flag_reg <= dout_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data_out1_reg <= 8'b0;
            data_out2_reg <= 8'b0;
            pi_data_reg  <= 8'b0;
        end
    else if(dout_flag == 1'b1)
        begin
            data_out1_reg <= data_out1;
            data_out2_reg <= data_out2;
            pi_data_reg   <= pi_data ;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
        a1 <= 8'b0;
        a2 <= 8'b0;
        a3 <= 8'b0;
        b1 <= 8'b0;
        b2 <= 8'b0;
        b3 <= 8'b0;
        c1 <= 8'b0;
        c2 <= 8'b0;
        c3 <= 8'b0;
        end
    else if(dout_flag_reg == 1'b1)
        begin
        a1 <= a2;
        a2 <= a3;
        a3 <= data_out1_reg;
        b1 <= b2;
        b2 <= b3;
        b3 <= data_out2_reg;
        c1 <= c2;
        c2 <= c3;
        c3 <= pi_data_reg;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gx_gy_flag <= 1'b0;
    else if((cnt_rd < 8'd1 || cnt_rd > 8'd2)&&dout_flag_reg == 1'b1)
        gx_gy_flag <= 1'b1;
    else
        gx_gy_flag <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gxy_flag <= 1'b0;
    else
        gxy_flag <= gx_gy_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        com_flag <= 1'b0;
    else
        com_flag <= gxy_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            gx <= 9'b0;
            gy <= 9'b0;
        end
    else if(gx_gy_flag == 1'b1)
        begin
            gx <= (a3-a1) + ((b3-b1) << 1) + (c3-c1);
            gy <= (a1-c1) + ((a2-c2) << 1) + (a3-c3);
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gxy <= 8'b0;
    else if(gxy_flag == 1'b1)
        case({gx[8],gy[8]})
            2'b11 : gxy <= (~gx[7:0] + 1'b1) + (~gy[7:0] + 1'b1);// if gx,gy[8] is 1, means it's negative, need to find absolute value, find two's complement
            2'b10 : gxy <= (~gx[7:0] + 1'b1) + (gy[7:0]);
            2'b01 : gxy <= (gx[7:0]) + (~gy[7:0] + 1'b1);
            2'b00 : gxy <= (gx[7:0]) + (gy[7:0]);
        default: gxy <= gxy;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_flag <= 1'b0;
    else 
        po_flag <= com_flag;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_sum <= 8'b0;
    else if(com_flag == 1'b1 && gxy > THRESHOLD)
        po_sum <= BLACK;
    else if(com_flag == 1'b1)
        po_sum <= WHITE;

// below is fifo_sum code
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
    else if((cnt_row >= 8'd2 && cnt_row < CNT_ROW_MAX) || (cnt_row == CNT_ROW_MAX && cnt_col == 8'd0))
        wr_en1 <= dout_flag;
    else
        wr_en1 <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in1 <= 8'b0;
    else if(cnt_row == 8'd0 && pi_flag == 1'b1)
        data_in1 <= pi_data;
    else if(((cnt_row >= 8'd2 && cnt_row < CNT_ROW_MAX) || (cnt_row == CNT_ROW_MAX && cnt_col == 8'd0)) && dout_flag == 1'b1)
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