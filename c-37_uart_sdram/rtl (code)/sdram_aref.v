module  sdram_aref
(
    input   wire            sys_clk     , // 100MHz clk
    input   wire            sys_rst_n   ,
    input   wire            init_end    ,
    input   wire            aref_en     ,
    
    output  reg             aref_req    ,
    output  reg     [3:0]   aref_cmd    ,
    output  reg     [1:0]   aref_ba     ,
    output  reg     [12:0]  aref_addr   ,
    output  wire            aref_end    


);

parameter   T_AREF     = 10'd749;// 64ms / 8192 cycle = 7.812us, using 7.5us for refresh 1 cycles.

parameter   NOP         = 4'b0111,
            P_CHARGE    = 4'b0010,
            AUTO_REF    = 4'b0001;

parameter   AREF_IDLE   = 3'b000,
            AREF_PRE    = 3'b001,
            AREF_TRP    = 3'b011,
            AREF_AR     = 3'b010,
            AREF_TRFC   = 3'b110,
            AREF_END    = 3'b111;

parameter   TRP_CLK     =   3'd2,   //pre-charge wait,20ns
            TRFC_CLK    =   3'd7;   //auto-refresh wait,70ns

wire            trp_end; //
wire            trfc_end; //
wire            aref_ack;//

reg     [2:0]   aref_state;
reg     [9:0]   cnt_ref;//
reg     [2:0]   cnt_clk;//
reg             cnt_clk_rst; //
reg     [1:0]   cnt_aref;//

assign aref_ack = (aref_state == AREF_PRE) ? 1'b1 : 1'b0;
assign aref_end = (aref_state == AREF_END) ? 1'b1 : 1'b0;

assign trp_end = (aref_state == AREF_TRP && cnt_clk == TRP_CLK)
                    ? 1'b1 : 1'b0;
assign trfc_end = (aref_state == AREF_TRFC && cnt_clk == TRFC_CLK)
                    ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_ref <= 10'd0;
    else if(cnt_ref == T_AREF)
        cnt_ref <= 10'd0;
    else if(init_end == 1'b1)
        cnt_ref <= cnt_ref + 1'b1;
    
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        aref_req <= 1'b0;
    else if(cnt_ref == T_AREF - 1'b1)
        aref_req <= 1'b1;
    else if(aref_ack == 1'b1)
        aref_req <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_clk <= 3'd0;
    else if(cnt_clk_rst == 1'b1)
        cnt_clk <= 3'd0;
    else
        cnt_clk <= cnt_clk + 1'b1;


always@(*)
    if(sys_rst_n == 1'b0)
        cnt_clk_rst <= 1'b0;
    else
        case(aref_state)
            AREF_IDLE   : cnt_clk_rst <= 1'b1;
            AREF_TRP    : cnt_clk_rst <= (trp_end == 1'b1) ? 1'b1 : 1'b0;
            AREF_TRFC   : cnt_clk_rst <= (trfc_end == 1'b1) ? 1'b1 : 1'b0;
            AREF_END    : cnt_clk_rst <= 1'b1;
            default:    cnt_clk_rst <= 1'b0;
        endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_aref <= 2'd0;
    else if(aref_state == AREF_IDLE)
        cnt_aref <= 2'd0;
    else if(aref_state == AREF_AR)
        cnt_aref <= cnt_aref + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        aref_state <= AREF_IDLE;
    else
        case(aref_state)
            AREF_IDLE :
                if((aref_en == 1'b1) && (init_end == 1'b1))
                    aref_state <= AREF_PRE;
            AREF_PRE  :
                    aref_state <= AREF_TRP;
            AREF_TRP  :
                if(trp_end == 1'b1)
                    aref_state <= AREF_AR;
            AREF_AR   :
                    aref_state <= AREF_TRFC;
            AREF_TRFC :
                if(trfc_end == 1'b1 && cnt_aref == 2'd2)
                    aref_state <= AREF_END;
                else if(trfc_end == 1'b1 && cnt_aref == 2'd1)
                    aref_state <= AREF_AR;
            AREF_END  :
                    aref_state <= AREF_IDLE;
            default: aref_state <= aref_state;
         endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            aref_cmd    <=  NOP;
            aref_ba     <=  2'b11;
            aref_addr   <=  13'h1fff;
        end
    else
        case(aref_state)
            AREF_IDLE,AREF_TRP,AREF_TRFC:    //NOP
                begin
                    aref_cmd    <=  NOP;
                    aref_ba     <=  2'b11;
                    aref_addr   <=  13'h1fff;
                end
            AREF_PRE:  //PRE CHARGE
                begin
                    aref_cmd    <=  P_CHARGE;
                    aref_ba     <=  2'b11;
                    aref_addr   <=  13'h1fff;
                end 
            AREF_AR:   //AUTO REFRESH
                begin
                    aref_cmd    <=  AUTO_REF;
                    aref_ba     <=  2'b11;
                    aref_addr   <=  13'h1fff;
                end
            AREF_END:   //AUTO REFRESH END
                begin
                    aref_cmd    <=  NOP;
                    aref_ba     <=  2'b11;
                    aref_addr   <=  13'h1fff;
                end    
            default:
                begin
                    aref_cmd    <=  NOP;
                    aref_ba     <=  2'b11;
                    aref_addr   <=  13'h1fff;
                end    
        endcase

endmodule