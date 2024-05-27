module rom_ctrl
#(  parameter   CNT_200MAX = 24'd9_999_999
)
(
    input       wire        sys_clk,
    input       wire        sys_rst_n,
    input       wire        key1_flag,
    input       wire        key2_flag,
    
    output      reg [7:0]   addr
);

reg     [23:0]  cnt_200ms;
reg             key1_en;
reg             key2_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_200ms <= 24'd0;
    else if((cnt_200ms == CNT_200MAX)||(key1_en == 1'b1) || (key2_en == 1'b1))
        cnt_200ms <= 24'd0;
    else
        cnt_200ms <= cnt_200ms + 24'd1;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key1_en <= 1'b0;
    else if(key2_flag == 1'b1)
        key1_en <= 1'b0;
    else if(key1_flag == 1'b1)
        key1_en <= ~key1_en;
    else
        key1_en <= key1_en;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        key2_en <= 1'b0;
    else if(key1_flag == 1'b1)
        key2_en <= 1'b0;
    else if(key2_flag == 1'b1)
        key2_en <= ~key2_en;
    else
        key2_en <= key2_en;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr <= 8'd0;
    else if((addr == 8'd255)&&(cnt_200ms == CNT_200MAX))
        addr <= 8'd0;
    else if(key1_en == 1'b1)
        addr <= 8'd99;
    else if(key2_en == 1'b1)
        addr <= 8'd199;
    else if(cnt_200ms == CNT_200MAX)
        addr <= addr+8'd1;
    else
        addr <= addr;
endmodule