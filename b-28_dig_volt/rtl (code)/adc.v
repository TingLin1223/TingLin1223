module  adc
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [7:0]   ad_data     ,

    output  wire            ad_clk      ,
    output  wire    [15:0]  volt        ,
    output  reg             sign        
);

reg             cnt     ;
reg             clk_four;
reg     [10:0]  cnt_ad  ;
reg     [17:0]  data_sum;
reg             sum_en  ;
reg     [7:0]   data_median;

wire    [27:0]  data_p;
wire    [27:0]  data_n;
reg     [27:0]  volt_reg;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 1'b0;
    else
        cnt <= cnt + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_four <= 1'b0;
    else if(cnt == 1'b1)
        clk_four <= ~clk_four;

always@(posedge clk_four or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_ad <= 11'd0;
    else if(sum_en == 1'b0)
        cnt_ad <= cnt_ad + 1'b1;

always@(posedge clk_four or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sum_en <= 1'b0;
    else if(cnt_ad == 11'd1024)
        sum_en <= 1'b1;

always@(posedge clk_four or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_sum <= 18'd0;
    else if(cnt_ad >= 11'd1024)
        data_sum <= 18'd0;
    else
        data_sum <= data_sum + ad_data;

always@(posedge clk_four or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_median <= 8'd0;
    else if(cnt_ad == 11'd1024)
        data_median <= (data_sum / 1024);

assign data_p = (sum_en == 1'b1) ? (4096_0000 / (255 - data_median)) : 0;
assign data_n = (sum_en == 1'b1) ? (4096_0000 / data_median) : 0;

always@(posedge clk_four or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        volt_reg <= 28'd0;
    else if(sum_en == 1'b1)
        if(ad_data < data_median)
            volt_reg <= (data_n * (data_median - ad_data)) >> 13;
        else if(ad_data > data_median)
            volt_reg <= (data_p * (ad_data - data_median)) >> 13;
    else
        volt_reg <= 28'd0;

always@(posedge clk_four or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sign <= 1'b0;
    else if (ad_data < data_median)
        sign <= 1'b1;
    else 
        sign <= 1'b0;

assign  ad_clk = ~clk_four;
assign  volt = volt_reg;


endmodule