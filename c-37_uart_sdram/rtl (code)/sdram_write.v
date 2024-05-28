module  sdram_write
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    input   wire            init_end        ,
    input   wire            wr_en           ,
    input   wire    [23:0]  wr_addr         ,
    input   wire    [15:0]  wr_data         ,
    input   wire    [9:0]   wr_burst_len    , // columns is 9 bit width = 512 data, but 9'b1_1111_1111 = 'd511 so that 'd512 needs 10 bits width.
    
    output  wire            wr_ack          , // using to fifo_ctrl, write_fifo read_en, read data from fifo, ahead command 1 clock.
    output  wire            wr_end          ,
    output  reg     [3:0]   wr_cmd          ,
    output  reg     [1:0]   wr_ba           ,
    output  reg     [12:0]  wr_sdram_addr   ,
    output  reg             sdram_en        , // control sdarm_arbit dq being output.
    output  wire    [15:0]  wr_sdram_data  // assign wr_data and transfer to sdram_arbit.
);

parameter   TRCD_CLK    =   10'd2   ,
            TRP_CLK     =   10'd2   ;
            
parameter   WR_IDLE     =   3'b000 , 
            WR_ACTIVE   =   3'b001 , 
            WR_TRCD     =   3'b011 , 
            WR_WRITE    =   3'b010 , 
            WR_DATA     =   3'b110 , 
            WR_PRE      =   3'b111 , 
            WR_TRP      =   3'b101 , 
            WR_END      =   3'b100 ; 
            
parameter   NOP         =   4'b0111 ,
            ACTIVE      =   4'b0011 ,
            WRITE       =   4'b0100 ,
            B_STOP      =   4'b0110 ,
            P_CHARGE    =   4'b0010 ;

wire            trcd_end    ;//
wire            twr_end     ;//
wire            trp_end     ;//

reg     [2:0]   wr_state    ;//
reg     [9:0]   cnt_clk     ;//
reg             cnt_clk_rst ;//

assign  trcd_end    = (wr_state == WR_TRCD && cnt_clk == TRCD_CLK) ? 1'b1 : 1'b0;
assign  twr_end     = (wr_state == WR_DATA && cnt_clk == wr_burst_len - 1'b1) ? 1'b1 : 1'b0;
assign  trp_end     = (wr_state == WR_TRP  && cnt_clk == TRP_CLK) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        cnt_clk <= 10'd0;
     else if(cnt_clk_rst == 1'b1)
        cnt_clk <= 10'd0;
     else
        cnt_clk <= cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        wr_state <= WR_IDLE;
     else
        case (wr_state)
            WR_IDLE   :
                if(init_end == 1'b1 && wr_en == 1'b1)
                    wr_state <= WR_ACTIVE;
                else
                    wr_state <= WR_IDLE;
            WR_ACTIVE :
                    wr_state <= WR_TRCD;
            WR_TRCD   :
                if(trcd_end == 1'b1)
                    wr_state <= WR_WRITE;
            WR_WRITE  :
                    wr_state <= WR_DATA;
            WR_DATA   :
                if(twr_end == 1'b1)
                    wr_state <= WR_PRE;
            WR_PRE    :
                    wr_state <= WR_TRP;
            WR_TRP    :
                if(trp_end == 1'b1)
                    wr_state <= WR_END;
            WR_END    :
                    wr_state <= WR_IDLE;
            default: wr_state <= WR_IDLE;
        endcase

always@(*)
    if(sys_rst_n == 1'b0)
        cnt_clk_rst <= 1'b1;
    else
        case(wr_state)
            WR_IDLE   : cnt_clk_rst <= 1'b1;
            WR_ACTIVE : cnt_clk_rst <= 1'b0;
            WR_TRCD   : cnt_clk_rst <= (trcd_end == 1'b1) ? 1'b1 : 1'b0;
            WR_WRITE  : cnt_clk_rst <= 1'b1;
            WR_DATA   : cnt_clk_rst <= (twr_end == 1'b1) ? 1'b1 : 1'b0;
            WR_PRE    : cnt_clk_rst <= 1'b0;
            WR_TRP    : cnt_clk_rst <= (trp_end == 1'b1) ? 1'b1 : 1'b0;
            WR_END    : cnt_clk_rst <= 1'b1;
            default:    cnt_clk_rst <= 1'b1;
        endcase

assign wr_ack = ((wr_state == WR_WRITE || wr_state == WR_DATA) 
        && (cnt_clk < wr_burst_len - 1'b1)) ? 1'b1 : 1'b0;

assign wr_end = (wr_state == WR_END) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            wr_cmd          <= NOP;
            wr_ba           <= 2'b11;
            wr_sdram_addr   <= 13'h1fff;
        end
    else
        case(wr_state)
            WR_IDLE   :
                begin
                    wr_cmd          <= NOP;
                    wr_ba           <= 2'b11;
                    wr_sdram_addr   <= 13'h1fff;
                end
            WR_ACTIVE :
                begin
                    wr_cmd          <= ACTIVE;
                    wr_ba           <= wr_addr[23:22];//bank address
                    wr_sdram_addr   <= wr_addr[21:9];//row address
                end
            WR_TRCD   :
                begin
                    wr_cmd          <= NOP;
                    wr_ba           <= 2'b11;
                    wr_sdram_addr   <= 13'h1fff;
                end
            WR_WRITE  :
                begin
                    wr_cmd          <= WRITE;
                    wr_ba           <= wr_addr[23:22];
                    wr_sdram_addr   <= {4'b0000,wr_addr[8:0]};//column address
                end
            WR_DATA   :
                if(twr_end == 1'b1)
                    wr_cmd <= B_STOP;//burst terminate
                else
                    begin
                        wr_cmd          <= NOP;
                        wr_ba           <= 2'b11;
                        wr_sdram_addr   <= 13'h1fff;
                    end
            WR_PRE    :
                begin
                    wr_cmd          <= P_CHARGE;
                    wr_ba           <= wr_addr[23:22];
                    wr_sdram_addr   <= 13'h0400; // A10 = 1'b1 to pre_charge all bank,
                end
            WR_TRP    :
                begin
                    wr_cmd          <= NOP;
                    wr_ba           <= 2'b11;
                    wr_sdram_addr   <= 13'h1fff;
                end
            WR_END    :
                begin
                    wr_cmd          <= NOP;
                    wr_ba           <= 2'b11;
                    wr_sdram_addr   <= 13'h1fff;
                end
            default:
                begin
                    wr_cmd          <= NOP;
                    wr_ba           <= 2'b11;
                    wr_sdram_addr   <= 13'h1fff;
                end
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sdram_en <=  1'b0;
    else
        sdram_en <=  wr_ack;

assign wr_sdram_data = (sdram_en == 1'b1) ? wr_data : 16'b0;

endmodule