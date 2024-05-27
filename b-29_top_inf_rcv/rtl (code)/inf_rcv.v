module  inf_rcv
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            inf_in      ,

    output  reg             repeat_en   ,
    output  reg     [19:0]  data        
);

parameter   IDLE    = 5'b00_001,
            T_9MS   = 5'b00_010,
            JUDGE   = 5'b00_100,
            DATA    = 5'b01_000,
            REPEAT  = 5'b10_000;

parameter   CNT_0_56MS_L    =   19'd20_000,
            CNT_0_56MS_H    =   19'd35_000,
            CNT_1_69MS_L    =   19'd80_000,
            CNT_1_69MS_H    =   19'd90_000,
            CNT_2_25MS_L    =   19'd100_000,
            CNT_2_25MS_H    =   19'd125_000,
            CNT_4_5MS_L     =   19'd175_000,
            CNT_4_5MS_H     =   19'd275_000,
            CNT_9MS_L       =   19'd400_000,
            CNT_9MS_H       =   19'd500_000;

reg             inf_in_reg1;
reg             inf_in_reg2;
reg     [4:0]   STATE;
reg     [18:0]  cnt;
reg             flag_0_56ms;
reg             flag_1_69ms;
reg             flag_2_25ms;
reg             flag_4_5ms;
reg             flag_9ms;
reg     [5:0]   data_cnt;
reg     [31:0]  data_reg;

wire            inf_in_fall;
wire            inf_in_rise;

assign inf_in_fall = (inf_in_reg1 == 1'b0)&&(inf_in_reg2 == 1'b1);
assign inf_in_rise = (inf_in_reg1 == 1'b1)&&(inf_in_reg2 == 1'b0);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            inf_in_reg1 <= 1'b1;
            inf_in_reg2 <= 1'b1;
        end
    else
        begin
            inf_in_reg1 <= inf_in;
            inf_in_reg2 <= inf_in_reg1;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        STATE <= IDLE;
    else 
        case(STATE)
            IDLE : 
                if(inf_in_fall == 1'b1)
                    STATE <= T_9MS;
                else
                    STATE <= IDLE;
            T_9MS :
                if((inf_in_rise == 1'b1) && (flag_9ms == 1'b1))
                    STATE <= JUDGE;
                else if((inf_in_rise == 1'b1)&&(flag_9ms == 1'b0))
                    STATE <= IDLE;
                else
                    STATE <= T_9MS;
            JUDGE : 
                if((inf_in_fall == 1'b1)&&(flag_4_5ms == 1'b1))
                    STATE <= DATA;
                else if((inf_in_fall == 1'b1)&&(flag_2_25ms == 1'b1))
                    STATE <= REPEAT;
                else if((inf_in_fall == 1'b1)&&(flag_2_25ms == 1'b0)&&(flag_4_5ms == 1'b0))
                    STATE <= IDLE;
                else
                    STATE <= JUDGE;
            DATA : 
                if((data_cnt == 6'd32)&&(inf_in_rise == 1'b1))
                    STATE <= IDLE;
                else if((inf_in_rise == 1'b1)&&(flag_0_56ms == 1'b0))
                    STATE <= IDLE;
                else if((inf_in_fall == 1'b1)&&(flag_1_69ms == 1'b0)&&(flag_0_56ms == 1'b0))
                    STATE <= IDLE;
                else
                    STATE <= DATA;
            REPEAT :
                if(inf_in_rise == 1'b1)
                    STATE <= IDLE;
                else
                    STATE <= REPEAT;
        default : STATE <= IDLE;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <= 19'd0;
    else
        case(STATE)
            IDLE    : cnt <= 19'd0;
            T_9MS   : if((inf_in_rise == 1'b1)&&(flag_9ms == 1'b1))
                            cnt <= 19'd0;
                      else
                            cnt <= cnt + 1'b1;
            JUDGE   : if((inf_in_fall == 1'b1)&&(flag_4_5ms == 1'b1||flag_2_25ms == 1'b1))
                            cnt <= 19'd0;
                      else
                            cnt <= cnt + 1'b1;
            DATA    : if((inf_in_rise == 1'b1)&&(flag_0_56ms == 1'b1))
                            cnt <= 19'd0;
                      else if((inf_in_fall == 1'b1)&&(flag_1_69ms == 1'b1 || flag_0_56ms == 1'b1))
                            cnt <= 19'd0;
                      else
                            cnt <= cnt + 1'b1;
         default: cnt <= 19'd0;
         endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_0_56ms <= 1'b0;
    else if((STATE == DATA)&&(cnt >= CNT_0_56MS_L)&&(cnt <= CNT_0_56MS_H))
        flag_0_56ms <= 1'b1;
    else
        flag_0_56ms <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_1_69ms <= 1'b0;
    else if((STATE == DATA)&&(cnt >= CNT_1_69MS_L)&&(cnt <= CNT_1_69MS_H))
        flag_1_69ms <= 1'b1;
    else
        flag_1_69ms <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_2_25ms <= 1'b0;
    else if((STATE == JUDGE)&&(cnt >= CNT_2_25MS_L)&&(cnt <= CNT_2_25MS_H))
        flag_2_25ms <= 1'b1;
    else
        flag_2_25ms <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_4_5ms <= 1'b0;
    else if((STATE == JUDGE)&&(cnt >= CNT_4_5MS_L)&&(cnt <= CNT_4_5MS_H))
        flag_4_5ms <= 1'b1;
    else
        flag_4_5ms <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_9ms <= 1'b0;
    else if((STATE == T_9MS)&&(cnt >= CNT_9MS_L)&&(cnt <= CNT_9MS_H))
        flag_9ms <= 1'b1;
    else
        flag_9ms <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_cnt <= 6'd0;
    else if((data_cnt == 6'd32)&&(inf_in_rise == 1'b1))
        data_cnt <= 6'd0;
    else if((STATE == DATA)&&(inf_in_fall == 1'b1))
        data_cnt <= data_cnt + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_reg <= 32'b0;
    else if((STATE == DATA)&&(inf_in_fall == 1'b1)&&(flag_1_69ms == 1'b1))
        data_reg[data_cnt] <= 1'b1;
    else if((STATE == DATA)&&(inf_in_fall == 1'b1)&&(flag_0_56ms == 1'b1))
        data_reg[data_cnt] <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data <= 20'b0;
    else if((data_cnt == 6'd32)&&(data_reg[7:0] == ~data_reg [15:8])&&(data_reg[23:16] == ~ data_reg[31:24]))
        data <= {12'b0,data_reg[23:16]};

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        repeat_en <= 1'b0;
    else if((STATE == REPEAT)&&(data_reg[23:16] == ~ data_reg[31:24]))//during repeat state, send the repeat_en signal out
        repeat_en <= 1'b1;
    else
        repeat_en <= 1'b0;
        // only check command and command inversed, due to repeat state is transfer command only.
        
endmodule