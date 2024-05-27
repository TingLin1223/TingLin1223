module  encoder
(
    input   wire            vga_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            hsync       ,
    input   wire            vsync       ,
    input   wire            rgb_valid   ,
    input   wire    [7:0]   data_in     ,
    
    output  reg     [9:0]   data_out    
);

wire            ctrl_1;//used to judge the data_in condition.
wire            ctrl_2;
wire            ctrl_3;
wire    [8:0]   q_m;

reg     [3:0]   data_in_n1; // because data_in 1 is 8 bit data so that maximum value of logic 1 is 8.
reg     [7:0]   data_in_reg;//delay 1 time to judge the condition.
reg     [3:0]   q_m_n1;
reg     [3:0]   q_m_n0;
reg     [4:0]   cnt;// in this case, maximum value is 8, minimun value is -8 = -8, 5 bit width enough.
reg             de_reg1;//make data delay for calculate
reg             de_reg2;//make data delay for calculate
reg             c0_reg1;    //make data delay for calculate
reg             c0_reg2;    //make data delay for calculate
reg             c1_reg1;    //make data delay for calculate
reg             c1_reg2;    //make data delay for calculate
reg     [8:0]   q_m_reg;       //make data delay for calculate

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in_n1 <= 4'd0;
    else
        data_in_n1 <= data_in[0]+ data_in[1]+ data_in[2]+ data_in[3]
                        +data_in[4]+ data_in[5]+ data_in[6]+ data_in[7]; //sequential logic, output delay 1 clock.
    
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_in_reg <= 8'b0;
    else
        data_in_reg <= data_in;

assign ctrl_1 = ((data_in_n1 > 4'd4)||((data_in_n1 == 4'd4)
                &&(data_in_reg[0] == 1'b0)))?1'b1 : 1'b0; //using data_in_n1 to judge, so data_in_reg is delay 1 clock also.

assign q_m[0] = data_in_reg[0];
assign q_m[1] = (ctrl_1 == 1'b1) ? (q_m[0] ^~ data_in_reg[1]) : (q_m[0] ^ data_in_reg[1]); // same clock data with ctrl_l.
assign q_m[2] = (ctrl_1 == 1'b1) ? (q_m[1] ^~ data_in_reg[2]) : (q_m[1] ^ data_in_reg[2]);
assign q_m[3] = (ctrl_1 == 1'b1) ? (q_m[2] ^~ data_in_reg[3]) : (q_m[2] ^ data_in_reg[3]);
assign q_m[4] = (ctrl_1 == 1'b1) ? (q_m[3] ^~ data_in_reg[4]) : (q_m[3] ^ data_in_reg[4]);
assign q_m[5] = (ctrl_1 == 1'b1) ? (q_m[4] ^~ data_in_reg[5]) : (q_m[4] ^ data_in_reg[5]);
assign q_m[6] = (ctrl_1 == 1'b1) ? (q_m[5] ^~ data_in_reg[6]) : (q_m[5] ^ data_in_reg[6]);
assign q_m[7] = (ctrl_1 == 1'b1) ? (q_m[6] ^~ data_in_reg[7]) : (q_m[6] ^ data_in_reg[7]);
assign q_m[8] = (ctrl_1 == 1'b1) ? 1'b0: 1'b1;

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            q_m_n1 <= 4'd0;
            q_m_n0 <= 4'd0;
        end
    else
        begin
            q_m_n1 <= q_m[0]+ q_m[1]+ q_m[2]+ q_m[3]
                        +q_m[4]+ q_m[5]+ q_m[6]+ q_m[7];// logic 1 number, delay 1 clock.
            q_m_n0 <= 4'd8 - (q_m[0]+ q_m[1]+ q_m[2]+ q_m[3]
                        +q_m[4]+ q_m[5]+ q_m[6]+ q_m[7]);//logic 0 number, delay 1 clock.
        end

assign ctrl_2 = ((cnt == 5'd0)||(q_m_n1 == q_m_n0));
assign ctrl_3 = (((~cnt[4] == 1'b1) && (q_m_n1 > q_m_n0))
                    || ((cnt[4] == 1'b1) && (q_m_n0 > q_m_n1))); // judge cnt is postive oe negetive, using highest bit to judge.

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            de_reg1 <=  1'b0;
            de_reg2 <=  1'b0;
            c0_reg1 <=  1'b0;
            c0_reg2 <=  1'b0;
            c1_reg1 <=  1'b0;
            c1_reg2 <=  1'b0;
            q_m_reg <=  9'b0;
        end
    else
        begin
            de_reg1 <=  rgb_valid;//rgb_valid delay 1 to de_reg1
            de_reg2 <=  de_reg1;//de_reg1 delay 1 to de_reg2, total delay 2 clocks, same as q_m_reg.
            c0_reg1 <=  hsync;
            c0_reg2 <=  c0_reg1;
            c1_reg1 <=  vsync;
            c1_reg2 <=  c1_reg1;
            q_m_reg <=  q_m; // q_m is delay 1 clock, so d_m_reg is delay 2 clocks, delay q_m for match q_m_n0 & q_m_n1 clock.
        end

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data_out <= 10'b0;
            cnt <= 5'b0;
        end
    else if(de_reg2 == 1'b1)
        begin
            if(ctrl_2 == 1'b1)
                begin
                    data_out[9]   <= ~q_m_reg[8];
                    data_out[8]   <= q_m_reg[8];
                    data_out[7:0] <= (q_m_reg[8]) ? q_m_reg[7:0] : ~q_m_reg[7:0];
                    cnt <= (q_m_reg[8] == 1'b0) ? (cnt + q_m_n0 - q_m_n1) : (cnt + q_m_n1 - q_m_n0);
                end
            else
                begin
                    if(ctrl_3 == 1'b1)
                        begin
                            data_out[9]   <= 1'b1;
                            data_out[8]   <= q_m_reg[8];
                            data_out[7:0] <= ~q_m_reg[7:0];
                            cnt <= (cnt + {q_m_reg[8],1'b0} + (q_m_n0 - q_m_n1));
                        end
                    else
                        begin
                        data_out[9]   <= 1'b0;
                        data_out[8]   <= q_m_reg[8];
                        data_out[7:0] <= q_m_reg[7:0];
                        cnt <= (cnt - {~q_m_reg[8],1'b0} + (q_m_n1 - q_m_n0)); //   2*~q_m_reg[8] = {~q_m_reg[8],1'b0}, shift 1 bit by left = *2
                        end
                end
        end
    else
        begin
            case({c1_reg2,c0_reg2})
                2'b00   : data_out <= 10'b1101_0101_00; // algorithm is [0:9], but here should be [9:0], the high and low bit is reversed
                2'b01   : data_out <= 10'b0010_1010_11;
                2'b10   : data_out <= 10'b0101_0101_00;
                default : data_out <= 10'b1010_1010_11;
            endcase
            cnt <= 5'd0;
        end

endmodule