module divider_five
(
    input       wire    sys_clk     ,
    input       wire    sys_rst_n   ,
    
    output      wire    clk_out     ,
    output      reg     clk_flag
);

reg     [2:0] cnt;
reg           clk_pos;
reg           clk_neg;


always@ (posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 3'd0;
    else if(cnt == 3'd4)
        cnt <= 3'd0;
    else
        cnt <= cnt + 3'd1;
        
always@ (posedge sys_clk or negedge sys_rst_n)// posedge sys_clk
    if(sys_rst_n == 1'b0)
        clk_pos <= 1'b0;
    else if(cnt == 3'd2)
        clk_pos <= 1'b1;
    else if(cnt == 3'd4)
        clk_pos <=1'b0;
    else
        clk_pos <= clk_pos;
        
always@ (negedge sys_clk or negedge sys_rst_n)// negedge sys_clk
    if(sys_rst_n == 1'b0)
        clk_neg <= 1'b0;
    else if(cnt == 3'd2)
        clk_neg <= 1'b1;
    else if(cnt == 3'd4)
        clk_neg <= 3'd0;
    else
        clk_neg <= clk_neg;
        
assign clk_out = (clk_pos | clk_neg);// clk_pos or clk_neg, either is 1 and the clk_out should be 1.

always@ (posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_flag <= 1'b0;
    else if(cnt == 3'd3)
        clk_flag <= 1'b1;
    else
        clk_flag <= 1'b0;
        

endmodule