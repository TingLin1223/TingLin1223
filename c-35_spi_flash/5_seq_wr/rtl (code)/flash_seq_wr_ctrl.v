module  flash_seq_wr_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            pi_flag     ,
    input   wire    [7:0]   pi_data     ,
    
    output  reg             sck         ,
    output  reg             cs_n        ,
    output  reg             mosi        
);

/* parameter   DATA_NUM    = 'd100; */

parameter   IDLE    = 4'b0001,
            WR_EN   = 4'b0010,
            DELAY   = 4'b0100,
            PP      = 4'b1000;
            
parameter   WR_IN   = 8'b0000_0110,
            PP_IN   = 8'b0000_0010;
/*             PP_ADR1 = 8'b0000_0000,//Sector
            PP_ADR2 = 8'b0000_0000,//Page
            PP_ADR3 = 8'b0010_0101;/ *///Byte
            /* SE_ADR  = 24'b0000_0000_0000_0100_0010_0101; *///
parameter   ADDR        =   24'h00_04_d2;   //数据写入地址

reg     [4:0]   cnt_clk ;
reg     [3:0]   state   ;
reg     [15:0]  cnt_byte;
reg     [1:0]   cnt_sck ;
reg     [2:0]   cnt_bit;//[4:0]
/* reg     [7:0]   data; */
reg     [23:0]  addr;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        addr <= ADDR;
    else if(cnt_byte == 16'd10 && cnt_clk == 5'd31)
        addr <= addr + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 5'd0;
    else if(state != IDLE)
        cnt_clk <= cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31 && cnt_byte == 16'd10)
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31)
        cnt_byte <= cnt_byte + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <= 2'd0;
    else if(cnt_byte == 16'd1 || (cnt_byte >= 16'd5 && cnt_byte < 16'd10))//
        cnt_sck <= cnt_sck + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <= 3'd0;//5'd0
    else if(cnt_sck == 2'd2)
        cnt_bit <= cnt_bit + 1'b1;
        
/* always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data <= 8'd0;//5'd0
    else if(cnt_byte >= 16'd264 && cnt_clk == 5'd31) // to observe overwrite situtiation when data wirtting number bigger than 1 page range.
        data <= 8'haa;
    else if(cnt_byte >= 16'd9 && cnt_clk == 5'd31 && cnt_byte < (DATA_NUM + 8))
        data <= data + 1'b1; */

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else
        case(state)
            IDLE  : 
                    if(pi_flag == 1'b1)
                        state <= WR_EN;
            WR_EN : 
                    if(cnt_byte == 16'd2 && cnt_clk == 5'd31)
                        state <= DELAY;
            DELAY : 
                    if(cnt_byte == 16'd3 && cnt_clk == 5'd31)
                        state <= PP;
            PP    : 
                   if(cnt_byte == 16'd10 && cnt_clk == 5'd31)//
                        state <= IDLE;
            default: state <= IDLE;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cs_n <= 1'b1;
    else
        case(state)
            IDLE  :
                    if(pi_flag == 1'b1)
                        cs_n <= 1'b0;
            WR_EN :
                    if(cnt_byte == 16'd2 && cnt_clk == 5'd31)
                        cs_n <= 1'b1;
            DELAY :
                    if(cnt_byte == 16'd3 && cnt_clk == 5'd31)
                        cs_n <= 1'b0;
            PP    :
                    if(cnt_byte == 16'd10 && cnt_clk == 5'd31)//
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
                        mosi <= addr[23 - cnt_bit];
                    else if(cnt_byte == 16'd7 && cnt_sck == 2'd0)
                        mosi <= addr[15 - cnt_bit];
                    else if(cnt_byte == 16'd8 && cnt_sck == 2'd0)
                        mosi <= addr[7 - cnt_bit];
                    else if(cnt_byte == 16'd9 && cnt_sck == 2'd0)// writting data
                        mosi <= pi_data[7 - cnt_bit];
                    else if(cnt_byte == 16'd10)//
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