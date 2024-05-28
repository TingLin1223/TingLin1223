module  sdram_read
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    input   wire            init_end        ,
    input   wire            rd_en           ,
    input   wire    [23:0]  rd_addr         ,
    input   wire    [15:0]  rd_data         ,
    input   wire    [9:0]   rd_burst_len    , // columns is 9 bit width = 512 data, but 9'b1_1111_1111 = 'd511 so that 'd512 needs 10 bits width.
    
    output  wire            rd_ack          , // using to fifo_ctrl, read_fifo wirte_en
    output  wire            rd_end          ,
    output  reg     [3:0]   rd_cmd          ,
    output  reg     [1:0]   rd_ba           ,
    output  reg     [12:0]  rd_sdram_addr   ,
    output  wire    [15:0]  rd_sdram_data   
);

parameter   TRCD_CLK    =   10'd2   , 
            TRP_CLK     =   10'd2   ; 
            
parameter   RD_IDLE     =   3'b000 ,  
            RD_ACTIVE   =   3'b001 ,  
            RD_TRCD     =   3'b011 ,  
            RD_READ     =   3'b010 ,  
            RD_DATA     =   3'b110 ,  
            RD_PRE      =   3'b111 ,  
            RD_TRP      =   3'b101 ,  
            RD_END      =   3'b100 ;  
            
parameter   NOP         =   4'b0111 , 
            ACTIVE      =   4'b0011 , 
            READ        =   4'b0101 , 
            B_STOP      =   4'b0110 , 
            P_CHARGE    =   4'b0010 ; 

parameter   BURST_L     =   10'd3;//cas latency

wire            trcd_end    ;//
wire            trd_end     ;//
wire            trp_end     ;//
wire            tcl_end     ;
wire            rd_b_end    ;

reg     [2:0]   rd_state    ;//
reg     [9:0]   cnt_clk     ;//
reg             cnt_clk_rst ;//
reg     [15:0]  rd_data_reg ;

assign  trcd_end    = (rd_state == RD_TRCD && cnt_clk == TRCD_CLK) ? 1'b1 : 1'b0;
assign  trd_end     = (rd_state == RD_DATA && cnt_clk == rd_burst_len + 10'd2) ? 1'b1 : 1'b0;
assign  trp_end     = (rd_state == RD_TRP  && cnt_clk == TRP_CLK) ? 1'b1 : 1'b0;
assign  tcl_end     = (rd_state == RD_READ && cnt_clk == BURST_L) ? 1'b1 : 1'b0;
assign  rd_b_end    = (rd_state == RD_DATA && cnt_clk == rd_burst_len - BURST_L - 1'b1 ) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        cnt_clk <= 10'd0;
     else if(cnt_clk_rst == 1'b1)
        cnt_clk <= 10'd0;
     else
        cnt_clk <= cnt_clk + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        rd_data_reg <= 16'b0;
     else 
        rd_data_reg <= rd_data;

always@(posedge sys_clk or negedge sys_rst_n)
     if(sys_rst_n == 1'b0)
        rd_state <= RD_IDLE;
     else
        case (rd_state)
            RD_IDLE   :
                if(init_end == 1'b1 && rd_en == 1'b1)
                    rd_state <= RD_ACTIVE;
                else
                    rd_state <= RD_IDLE;
            RD_ACTIVE :
                    rd_state <= RD_TRCD;
            RD_TRCD   :
                if(trcd_end == 1'b1)
                    rd_state <= RD_READ;
            RD_READ  :
                if(tcl_end == 1'b1)
                    rd_state <= RD_DATA; 
            RD_DATA   :
                if(trd_end == 1'b1)
                    rd_state <= RD_PRE;
            RD_PRE    :
                    rd_state <= RD_TRP;
            RD_TRP    :
              if(trp_end == 1'b1)
                    rd_state <= RD_END;
            RD_END    :
                    rd_state <= RD_IDLE;
            default: rd_state <= RD_IDLE;
        endcase

always@(*)
    if(sys_rst_n == 1'b0)
        cnt_clk_rst <= 1'b1;
    else
        case(rd_state)
            RD_IDLE   : cnt_clk_rst <= 1'b1;
            RD_ACTIVE : cnt_clk_rst <= 1'b0;
            RD_TRCD   : cnt_clk_rst <= (trcd_end == 1'b1) ? 1'b1 : 1'b0;
            RD_READ   : cnt_clk_rst <= (tcl_end == 1'b1) ? 1'b1 : 1'b0;
            RD_DATA   : cnt_clk_rst <= (trd_end == 1'b1) ? 1'b1 : 1'b0;
            RD_PRE    : cnt_clk_rst <= 1'b0;
            RD_TRP    : cnt_clk_rst <= (trp_end == 1'b1) ? 1'b1 : 1'b0;
            RD_END    : cnt_clk_rst <= 1'b1;
            default:    cnt_clk_rst <= 1'b1;
        endcase

assign rd_ack = ((rd_state == RD_DATA) && (cnt_clk <= rd_burst_len ) && (cnt_clk >= 10'd1)) ? 1'b1 : 1'b0;

assign rd_end = (rd_state == RD_END) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            rd_cmd          <= NOP;
            rd_ba           <= 2'b11;
            rd_sdram_addr   <= 13'h1fff;
        end
    else
        case(rd_state)
            RD_IDLE   :
                begin
                    rd_cmd          <= NOP;
                    rd_ba           <= 2'b11;
                    rd_sdram_addr   <= 13'h1fff;
                end
            RD_ACTIVE :
                begin
                    rd_cmd          <= ACTIVE;
                    rd_ba           <= rd_addr[23:22];
                    rd_sdram_addr   <= rd_addr[21:9];
                end
            RD_TRCD   :
                begin
                    rd_cmd          <= NOP;
                    rd_ba           <= 2'b11;
                    rd_sdram_addr   <= 13'h1fff;
                end
            RD_READ  :
                if(cnt_clk == 10'd0)
                    begin
                        rd_cmd          <= READ;
                        rd_ba           <= rd_addr[23:22];
                        rd_sdram_addr   <= {4'b0000,rd_addr[8:0]};
                    end
                else
                    begin
                        rd_cmd          <= NOP;
                        rd_ba           <= 2'b11;
                        rd_sdram_addr   <= 13'h1fff;
                    end
            RD_DATA   :
                if(rd_b_end == 1'b1)
                    rd_cmd <= B_STOP;
                else
                    begin
                        rd_cmd          <= NOP;
                        rd_ba           <= 2'b11;
                        rd_sdram_addr   <= 13'h1fff;
                    end
            RD_PRE    :
                begin
                    rd_cmd          <= P_CHARGE;
                    rd_ba           <= rd_addr[23:22];
                    rd_sdram_addr   <= 13'h0400; // A10 = 1'b1 to pre_charge all bank,
                end
            RD_TRP    :
                begin
                    rd_cmd          <= NOP;
                    rd_ba           <= 2'b11;
                    rd_sdram_addr   <= 13'h1fff;
                end
            RD_END    :
                begin
                    rd_cmd          <= NOP;
                    rd_ba           <= 2'b11;
                    rd_sdram_addr   <= 13'h1fff;
                end
            default:
                begin
                    rd_cmd          <= NOP;
                    rd_ba           <= 2'b11;
                    rd_sdram_addr   <= 13'h1fff;
                end
        endcase

assign rd_sdram_data = (rd_ack == 1'b1) ? rd_data_reg : 16'b0;

endmodule