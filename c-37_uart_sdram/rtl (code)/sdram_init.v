module  sdram_init
(
    input   wire            sys_clk     , // 100MHz clk
    input   wire            sys_rst_n   ,
    
    output  reg     [3:0]   init_cmd    ,
    output  reg     [1:0]   init_ba     ,
    output  reg     [12:0]  init_addr   ,
    output  wire            init_end    
);

parameter   T_POWER     = 15'd20_000;// set to 200 us, (200*1000 ns)/[(1*10^9 ns)/100MHz)],

parameter   NOP         = 4'b0111,
            P_CHARGE    = 4'b0010,
            AUTO_REF    = 4'b0001,
            M_REG_SET   = 4'b0000;

parameter   INIT_IDLE   = 3'b000,
            INIT_PRE    = 3'b001,
            INIT_TRP    = 3'b011,
            INIT_AR     = 3'b010,
            INIT_TRFC   = 3'b110,
            INIT_MRD    = 3'b111,
            INIT_TMRD   = 3'b101,
            INIT_END    = 3'b100;

parameter   TRP_CLK     =   3'd2        ,   //pre-charge wait,20ns
            TRFC_CLK    =   3'd7        ,   //auto-refresh wait,70ns
            TMRD_CLK    =   3'd3        ;   //mode register wait,30ns

wire            wait_end; //
wire            trp_end; //
wire            trfc_end; //
wire            tmrd_end; //

reg     [2:0]   init_state;//
reg     [14:0]  cnt_200us;//
reg     [2:0]   cnt_clk;//
reg             cnt_clk_rst; //
reg     [1:0]   cnt_aref;//

assign wait_end = (cnt_200us == (T_POWER -1)) ? 1'b1 : 1'b0;

assign trp_end = (init_state == INIT_TRP && cnt_clk == TRP_CLK)
                    ? 1'b1 : 1'b0;
assign trfc_end = (init_state == INIT_TRFC && cnt_clk == TRFC_CLK)
                    ? 1'b1 : 1'b0;
assign tmrd_end = (init_state == INIT_TMRD && cnt_clk == TMRD_CLK)
                    ? 1'b1 : 1'b0;


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
        case(init_state)
            INIT_IDLE   : cnt_clk_rst <= 1'b1;
            INIT_PRE    : cnt_clk_rst <= 1'b0;
            INIT_TRP    : cnt_clk_rst <= (trp_end == 1'b1) ? 1'b1 : 1'b0;
            INIT_AR     : cnt_clk_rst <= 1'b0;
            INIT_TRFC   : cnt_clk_rst <= (trfc_end == 1'b1) ? 1'b1 : 1'b0;
            INIT_MRD    : cnt_clk_rst <= 1'b0;
            INIT_TMRD   : cnt_clk_rst <= (tmrd_end == 1'b1) ? 1'b1 : 1'b0;
            INIT_END    : cnt_clk_rst <= 1'b1;
            default:    cnt_clk_rst <= 1'b0;
        endcase


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_200us <= 15'd0;
    else if(cnt_200us == T_POWER)
        cnt_200us <= T_POWER;
    else
        cnt_200us <= cnt_200us + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_aref <= 2'd0;
    else if(init_state == INIT_AR)
        cnt_aref <= cnt_aref + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        init_state <= INIT_IDLE;
    else
        case(init_state)
            INIT_IDLE   :
                if(wait_end == 1'b1)
                    init_state <= INIT_PRE;
            INIT_PRE    :
                    init_state <= INIT_TRP;
            INIT_TRP    :
                if(trp_end == 1'b1)
                    init_state <= INIT_AR;
            INIT_AR     :
                    init_state <= INIT_TRFC;
            INIT_TRFC   :
                if(trfc_end == 1'b1 && cnt_aref == 2'd2)
                    init_state <= INIT_MRD;
                else if(trfc_end == 1'b1 && cnt_aref == 2'd1)
                    init_state <= INIT_AR;
            INIT_MRD    :
                    init_state <= INIT_TMRD;
            INIT_TMRD   :
                if(tmrd_end == 1'b1)
                    init_state <= INIT_END;
            INIT_END    :
                    init_state <= INIT_END;
            default: init_state <= init_state;
         endcase

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            init_cmd    <= NOP;
            init_ba     <= 2'b11;
            init_addr   <= 13'h1fff;
        end
    else
        case(init_state)
            INIT_IDLE, INIT_TRP, INIT_TRFC, INIT_TMRD, INIT_END:
                begin
                    init_cmd    <= NOP;
                    init_ba     <= 2'b11;
                    init_addr   <= 13'h1fff;
                end
            INIT_PRE    :
                begin
                    init_cmd    <= P_CHARGE;
                    init_ba     <= 2'b11;
                    init_addr   <= 13'h1fff;
                end
            INIT_AR     :
                begin
                    init_cmd    <= AUTO_REF;
                    init_ba     <= 2'b11;
                    init_addr   <= 13'h1fff;
                end
            INIT_MRD    :
                begin
                    init_cmd    <= M_REG_SET;
                    init_ba     <= 2'b00;
                    init_addr   <=
                    {    
                        3'b000,     //A12-A10:Reserve
                        1'b0,       //A9=0:write & read are burst.
                        2'b00,      //{A8,A7}=00:standard mode, default.
                        3'b011,     //{A6,A5,A4}=011:CAS latency, 011 = 3 clocks.
                        1'b0,       //A3=0: burst type, 0 = sequential.
                        3'b111      //{A2,A1,A0}=111: burst length.
                                    //010:4 bytes,011:8 bytes,111:full page.
                    };
                end
            default: 
                begin
                    init_cmd    <= NOP;
                    init_ba     <= 2'b11;
                    init_addr   <= 13'h1fff;
                end
         endcase

assign init_end = (init_state == INIT_END) ? 1'b1 : 1'b0;

endmodule