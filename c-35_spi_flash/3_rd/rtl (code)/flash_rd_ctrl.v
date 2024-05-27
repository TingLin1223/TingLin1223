module  flash_rd_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            key_flag    ,
    input   wire            miso        ,
    
    output  reg             sck         ,
    output  reg             cs_n        ,
    output  reg             mosi        ,
    output  wire    [7:0]   pi_data    ,
    output  reg             pi_flag     
);

parameter   DATA_NUM = 8'd100;

parameter   WAIT_MAX = 16'd600_00;

parameter   IDLE    = 3'b001,
            READ    = 3'b010,
            SEND    = 3'b100;
/*             SE      = 4'b1000; */
            
parameter   RD_IN   = 8'b0000_0011,
            /* SE_IN   = 8'b1101_1000, */
            RD_ADR1 = 8'b0000_0000,//sector address
            RD_ADR2 = 8'b0000_0000,//page address
            RD_ADR3 = 8'b0000_0000;//byte address
            /* SE_ADR  = 24'b0000_0000_0000_0100_0010_0101; *///

reg     [4:0]   cnt_clk ;
reg     [2:0]   state   ;
reg     [15:0]   cnt_byte;
reg     [1:0]   cnt_sck ;
reg     [2:0]   cnt_bit;
// below are new variables for read command
wire    [7:0]   fifo_num;

reg             miso_flag;
reg     [7:0]   data;
reg     [7:0]   data_reg;
reg             flag_reg;
reg             wr_en;
reg             rd_en;
reg     [15:0]  cnt_wait;
reg     [7:0]   rd_num;
reg             valid;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 5'd0;
    else if(state == READ)
        cnt_clk <= cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31 && cnt_byte == DATA_NUM + 3)//9
        cnt_byte <= 16'd0;
    else if(cnt_clk == 5'd31)
        cnt_byte <= cnt_byte + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_sck <= 2'd0;
    else if(state == READ)//5678
        cnt_sck <= cnt_sck + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <= 3'd0;//5'd0
    else if(cnt_sck == 2'd2)
        cnt_bit <= cnt_bit + 1'b1;
// read variables
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        miso_flag <= 1'b0;
    else if(cnt_byte >= 16'd4 && cnt_sck == 2'd1)
        miso_flag <= 1'b1;
    else
        miso_flag <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data <= 8'b0;
    else if(miso_flag == 1'b1)
        data <= {data[6:0],miso};

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_reg <= 1'b0;
    else if(miso_flag == 1'b1 && cnt_bit == 3'd7)
        flag_reg <= 1'b1;
    else
        flag_reg <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg <= 8'b0;
    else if(flag_reg == 1'b1)
        data_reg <= data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en <= 1'b0;
    else
        wr_en <= flag_reg;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        valid <= 1'b0;
    else if(rd_num == DATA_NUM && cnt_wait == WAIT_MAX - 1'b1)
        valid <= 1'b0;
    else if(fifo_num == DATA_NUM)
        valid <= 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_wait <= 16'd0;
    else if(cnt_wait == WAIT_MAX -1)
        cnt_wait <= 16'd0;
    else if(valid == 1'b1)
        cnt_wait <= cnt_wait + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(rd_num < DATA_NUM && cnt_wait == WAIT_MAX - 1'b1)
        rd_en <= 1'b1;
    else
        rd_en <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_num <= 8'd0;
    else if(valid == 1'b0)
        rd_num <= 8'd0;
    else if(rd_en == 1'b1)
        rd_num <= rd_num + 1'b1;


//

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else
        case(state)
            IDLE  : 
                    if(key_flag == 1'b1)
                        state <= READ;
            READ : 
                    if((cnt_byte == DATA_NUM + 3) && cnt_clk == 5'd31)
                        state <= SEND;
            SEND : 
                    if(rd_num == DATA_NUM && cnt_wait == WAIT_MAX - 1)
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
            READ :
                    if((cnt_byte == DATA_NUM + 3) && cnt_clk == 5'd31)
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
            READ    :
                    if(cnt_byte == 16'd0 && cnt_sck == 2'd0)
                        mosi <= RD_IN[7 - cnt_bit];
                    else if(cnt_byte == 16'd1 && cnt_sck == 2'd0)
                        mosi <= RD_ADR1[7 - cnt_bit];
                    else if(cnt_byte == 16'd2 && cnt_sck == 2'd0)
                        mosi <= RD_ADR2[7 - cnt_bit];
                    else if(cnt_byte == 16'd3 && cnt_sck == 2'd0)
                        mosi <= RD_ADR3[7 - cnt_bit];
                    else if(cnt_byte == 16'd4)
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

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_flag <= 1'b0;
    else
        pi_flag <= rd_en;

fifo    fifo_inst 
(
    .clock  ( sys_clk    ),
    .data   ( data_reg   ),
    .rdreq  ( rd_en      ),
    .wrreq  ( wr_en      ),
    .q      ( pi_data    ),
    .usedw  ( fifo_num   )
    );


endmodule