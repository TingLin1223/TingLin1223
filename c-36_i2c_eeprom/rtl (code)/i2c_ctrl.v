module  i2c_ctrl
#
(
    parameter   SYS_CLK_FREQ    =   'd50_000_000,
    parameter   SCL_FREQ        =   'd250_000   ,
    parameter   DEVICE_ADDR     =   7'b1010_011 
)
//SCL_FREQ is eeprom working frequency 250K Hz
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            i2c_start   ,
    input   wire            wr_en       ,
    input   wire    [15:0]  byte_addr   ,
    input   wire    [7:0]   wr_data     ,
    input   wire            rd_en       ,
    input   wire            addr_num    ,
    
    output  reg             i2c_scl     ,
    output  reg     [7:0]   rd_data     ,
    output  reg             i2c_end     ,
    output  reg             i2c_clk     ,
    inout   wire            i2c_sda     
);
// i2c_clk = 1M Hz, it's four times of eeprom working frequency 250K Hz, due to save memory and coding convenience.


parameter   CNT_CLK_MAX = (SYS_CLK_FREQ/SCL_FREQ) >> 3; // value = 25, i2c_clk is 1M Hz, using cnt_clk to generate.

parameter   IDLE            =   4'd00,  
            START_1         =   4'd01,  
            SEND_D_ADDR     =   4'd02,  
            ACK_1           =   4'd03,  
            SEND_B_ADDR_H   =   4'd04,  
            ACK_2           =   4'd05,  
            SEND_B_ADDR_L   =   4'd06,  
            ACK_3           =   4'd07,  
            WR_DATA         =   4'd08,  
            ACK_4           =   4'd09,  
            START_2         =   4'd10,  
            SEND_RD_ADDR    =   4'd11,  
            ACK_5           =   4'd12,  
            RD_DATA         =   4'd13,  
            N_ACK           =   4'd14,  
            STOP            =   4'd15;  

reg     [7:0]   cnt_clk         ;// assign bigger bit width to further re-use in the future

reg     [3:0]   state           ;
reg     [1:0]   cnt_i2c_clk     ;
reg     [2:0]   cnt_bit         ;
reg             sda_out         ;
reg     [7:0]   rd_data_reg     ;
reg             ack             ;

wire            sda_en          ;
wire            sda_in          ;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 8'd0;
    else if(cnt_clk == CNT_CLK_MAX - 1)
        cnt_clk <= 8'd0;
    else
        cnt_clk <= cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_clk <= 1'b1;
    else if(cnt_clk == CNT_CLK_MAX - 1)
        i2c_clk <= ~i2c_clk;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else case(state)
        IDLE          :
            if(i2c_start == 1'b1)
                state <= START_1;
        START_1       :
            if(cnt_i2c_clk == 2'd3)
                state <= SEND_D_ADDR;
        SEND_D_ADDR   :
            if(cnt_bit == 8'd7 && cnt_i2c_clk == 2'd3)
                state <= ACK_1;
        ACK_1         :
            if(cnt_i2c_clk == 2'd3 && ack == 1'b0)
                begin
                    if(addr_num == 1'b1)
                        state <= SEND_B_ADDR_H;
                    else
                        state <= SEND_B_ADDR_L;
                end
        SEND_B_ADDR_H :
            if(cnt_bit == 8'd7 && cnt_i2c_clk == 2'd3)
                state <= ACK_2;
        ACK_2         :
            if(cnt_i2c_clk == 2'd3 && ack == 1'b0)
                state <= SEND_B_ADDR_L;
        SEND_B_ADDR_L :
            if(cnt_bit == 8'd7 && cnt_i2c_clk == 2'd3)
                state <= ACK_3;
        ACK_3         :
            if(cnt_i2c_clk == 2'd3 && ack == 1'b0)
                begin
                    if(wr_en == 1'b1)
                        state <= WR_DATA;
                    if(rd_en == 1'b1)
                        state <= START_2;
                end
        WR_DATA       :
            if(cnt_bit == 8'd7 && cnt_i2c_clk == 2'd3)
                state <= ACK_4;
        ACK_4         :
            if(cnt_i2c_clk == 2'd3 && ack == 1'b0)
                state <= STOP;
        START_2       :
            if(cnt_i2c_clk == 2'd3)
                state <= SEND_RD_ADDR; // device number + read bit = 0101_0111
        SEND_RD_ADDR  :
            if(cnt_bit == 8'd7 && cnt_i2c_clk == 2'd3)
                state <= ACK_5;
        ACK_5         :
            if(cnt_i2c_clk == 2'd3 && ack == 1'b0)
                state <= RD_DATA;
        RD_DATA       :
            if(cnt_bit == 8'd7 && cnt_i2c_clk == 2'd3)
                state <= N_ACK;
        N_ACK         :
            if(cnt_i2c_clk == 2'd3 && i2c_sda == 1'b1)
                state <= STOP;
        STOP          :
            if(cnt_bit == 8'd3 && cnt_i2c_clk == 2'd3)
                state <= IDLE;
        default: state <= IDLE;
    endcase

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_i2c_clk <= 2'd0;
    else if(state != IDLE)
        cnt_i2c_clk <= cnt_i2c_clk + 1'b1;

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_bit <= 3'd0;
    else if (state == STOP && cnt_bit == 3'd3 && cnt_i2c_clk == 2'd3)
        cnt_bit <= 3'd0;
    else if ((state == SEND_D_ADDR || state == SEND_B_ADDR_H 
                || state == SEND_B_ADDR_L ||state == WR_DATA 
                || state == SEND_RD_ADDR || state == RD_DATA
                || state == STOP) && cnt_i2c_clk == 2'd3)
        cnt_bit <= cnt_bit + 1'b1;

always@(*)
    case(state)
        IDLE         : 
                sda_out <= 1'b1;
        START_1      : 
            if(cnt_i2c_clk <= 2'd1)//
                sda_out <= 1'b1;
            else
                sda_out <= 1'b0;
        SEND_D_ADDR  : 
            if(cnt_bit <= 3'd6)
                sda_out <= DEVICE_ADDR[6 - cnt_bit];
            else
                sda_out <= 1'b0;
        ACK_1        : 
            sda_out <= 1'b1;
        SEND_B_ADDR_H: 
            sda_out <= byte_addr[15 - cnt_bit];
        ACK_2        : 
            sda_out <= 1'b1;
        SEND_B_ADDR_L: 
            sda_out <= byte_addr[7 - cnt_bit];
        ACK_3        : 
            sda_out <= 1'b1;
        WR_DATA      : 
            sda_out <= wr_data[7 - cnt_bit];
        ACK_4        : 
            sda_out <= 1'b1;
        START_2      : 
            if(cnt_i2c_clk <= 2'd1)
                sda_out <= 1'b1;
            else
                sda_out <= 1'b0;
        SEND_RD_ADDR : 
            if(cnt_bit <= 3'd6)
                sda_out <= DEVICE_ADDR[6 - cnt_bit];
            else
                sda_out <= 1'b1;
        ACK_5        : 
            sda_out <= 1'b1;
        RD_DATA      : 
            sda_out <= 1'b1;
        N_ACK        : 
            sda_out <= 1'b1;
        STOP         : 
            if(cnt_bit == 3'd0 && cnt_i2c_clk < 2'd3)
                sda_out <= 1'b0;
            else
                sda_out <= 1'b1;
        default: 
                sda_out <= 1'b1;
    endcase

always@(*)
    case(state)
        IDLE    : 
                rd_data_reg <= 8'd0;
        RD_DATA : 
            if(cnt_i2c_clk == 2'd2)
                rd_data_reg [7 - cnt_bit] <= sda_in;
            else
                rd_data_reg <= rd_data_reg;
        default: rd_data_reg <= rd_data_reg;
    endcase

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_data <=  8'd0;
    else    if((state == RD_DATA) && (cnt_bit == 3'd7) && (cnt_i2c_clk == 2'd3))
        rd_data <=  rd_data_reg;


always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_scl <= 1'b1;
    else
        case(state)
        IDLE         : 
                i2c_scl <= 1'b1;
        START_1,SEND_D_ADDR,ACK_1,SEND_B_ADDR_H,ACK_2,SEND_B_ADDR_L,
        ACK_3,WR_DATA,ACK_4,START_2,SEND_RD_ADDR,ACK_5,RD_DATA,N_ACK:
            if(cnt_i2c_clk == 2'd0)
                i2c_scl <= 1'b1;
            else if(cnt_i2c_clk == 2'd2)
                i2c_scl <= 1'b0;
        STOP:
            if((cnt_bit == 3'd0) &&(cnt_i2c_clk == 2'd0))
                i2c_scl <=  1'b1;
        default: 
                i2c_scl <= 1'b1;
    endcase


assign  sda_en = ((state == RD_DATA) || (state == ACK_1) || (state == ACK_2)
                    || (state == ACK_3) || (state == ACK_4) || (state == ACK_5))
                    ? 1'b0 : 1'b1;

assign sda_in = i2c_sda;
assign i2c_sda = (sda_en == 1'b1) ? sda_out : 1'bz;


always@(*)
    case    (state)
        IDLE,START_1,SEND_D_ADDR,SEND_B_ADDR_H,SEND_B_ADDR_L,
        WR_DATA,START_2,SEND_RD_ADDR,RD_DATA,N_ACK:
            ack <=  1'b1;
        ACK_1,ACK_2,ACK_3,ACK_4,ACK_5:
            if(cnt_i2c_clk == 2'd0)
                ack <=  sda_in;
            else
                ack <=  ack;
        default:    ack <=  1'b1;
    endcase

always@(posedge i2c_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        i2c_end <= 1'b0;
    else if(state == STOP && cnt_i2c_clk == 2'd3 && cnt_bit == 3'd3)
        i2c_end <= 1'b1;
    else
        i2c_end <= 1'b0;


endmodule