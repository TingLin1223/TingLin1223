module  flash_pp_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_flag    ,
    
    output  reg             sck         ,
    output  reg             cs_n        ,
    output  reg             mosi        
);

parameter   DATA_NUM    = 'd100;

parameter   IDLE    = 4'b0001,
            WR_EN   = 4'b0010,
            DELAY   = 4'b0100,
            PP      = 4'b1000;
            
parameter   WR_IN   = 8'b0000_0110,
            PP_IN   = 8'b0000_0010,
            PP_ADR1 = 8'b0000_0000,//Sector
            PP_ADR2 = 8'b0000_0100,//Page
            PP_ADR3 = 8'b0010_0101;//Byte


reg     [4:0]   cnt_clk ;
reg     [3:0]   state   ;
reg     [15:0]  cnt_byte;
reg     [1:0]   cnt_sck ;
reg     [2:0]   cnt_bit;
reg     [7:0]   data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 5'd0;
    else if(state != IDLE)
        cnt_clk <= cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31 && cnt_byte == (DATA_NUM + 9))
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31)
        cnt_byte <= cnt_byte + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <= 2'd0;
    else if(cnt_byte == 16'd1 || (cnt_byte >= 16'd5 && cnt_byte < (DATA_NUM +9)))//5678
        cnt_sck <= cnt_sck + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <= 3'd0;
    else if(cnt_sck == 2'd2)
        cnt_bit <= cnt_bit + 1'b1;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data <= 8'd0;
    else if(cnt_byte >= 16'd9 && cnt_clk == 5'd31 && cnt_byte < (DATA_NUM + 8))
        data <= data + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else
        case(state)
            IDLE  : 
                    if(key_flag == 1'b1)
                        state <= WR_EN;
            WR_EN : 
                    if(cnt_byte == 16'd2 && cnt_clk == 5'd31)
                        state <= DELAY;
            DELAY : 
                    if(cnt_byte == 16'd3 && cnt_clk == 5'd31)
                        state <= PP;
            PP    : 
                   if(cnt_byte == (DATA_NUM + 9) && cnt_clk == 5'd31)//9
                        state <= IDLE;
            default: state <= IDLE;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n <= 1'b1;
    else
        case(state)
            IDLE  :
                    if(key_flag == 1'b1)
                        cs_n <= 1'b0;
            WR_EN :
                    if(cnt_byte == 16'd2 && cnt_clk == 5'd31)
                        cs_n <= 1'b1;
            DELAY :
                    if(cnt_byte == 16'd3 && cnt_clk == 5'd31)
                        cs_n <= 1'b0;
            PP    :
                    if(cnt_byte == (DATA_NUM + 9) && cnt_clk == 5'd31)//9
                        cs_n <= 1'b1;
            default: cs_n <= 1'b1;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mosi <= 1'b0;
    else 
        case(state)
            IDLE  :
                        mosi <= 1'b0;
            WR_EN :
                    if(cnt_byte == 16'd1 && cnt_sck == 2'd0)
                        mosi <= WR_IN[7 - cnt_bit];
                    else if(cnt_byte == 16'd2)
                        mosi <= 1'b0;
            DELAY :
                        mosi <= 1'b0;
            PP    :
                    if(cnt_byte == 16'd5 && cnt_sck == 2'd0)//678 = address
                        mosi <= PP_IN[7 - cnt_bit];
                    else if(cnt_byte == 16'd6 && cnt_sck == 2'd0)
                        mosi <= PP_ADR1[7 - cnt_bit];
                    else if(cnt_byte == 16'd7 && cnt_sck == 2'd0)
                        mosi <= PP_ADR2[7 - cnt_bit];
                    else if(cnt_byte == 16'd8 && cnt_sck == 2'd0)
                        mosi <= PP_ADR3[7 - cnt_bit];
                    else if(cnt_byte >= 16'd9 && cnt_byte < (DATA_NUM + 9) && cnt_sck == 2'd0)
                        mosi <= data[7 - cnt_bit];
                    else if(cnt_byte == (DATA_NUM + 9))//9
                        mosi <= 1'b0;
            default: mosi <= 1'b0;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sck <= 1'b0;
    else if(cnt_sck == 2'd0)
        sck <= 1'b0;
    else if(cnt_sck == 2'd2)
        sck <= 1'b1;
        
endmodule