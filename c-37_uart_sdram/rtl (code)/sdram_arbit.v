module  sdram_arbit
(
    input   wire            sys_clk     ,//100MHz
    input   wire            sys_rst_n   ,
    
    input   wire    [3:0]   init_cmd    ,
    input   wire    [1:0]   init_ba     ,
    input   wire    [12:0]  init_addr   ,
    input   wire            init_end    ,
    
    input   wire            aref_req    ,
    input   wire    [3:0]   aref_cmd    ,
    input   wire    [1:0]   aref_ba     ,
    input   wire    [12:0]  aref_addr   ,
    input   wire            aref_end    ,
    
    input   wire            wr_req      ,
    input   wire    [3:0]   wr_cmd      ,
    input   wire    [1:0]   wr_ba       ,
    input   wire    [12:0]  wr_addr     ,
    input   wire    [15:0]  wr_data     ,
    input   wire            wr_sdram_en ,
    input   wire            wr_end      ,
    
    input   wire            rd_req      ,
    input   wire    [3:0]   rd_cmd      ,
    input   wire    [1:0]   rd_ba       ,
    input   wire    [12:0]  rd_addr     ,
    input   wire            rd_end      ,

    output  reg             aref_en     ,//
    output  reg             wr_en       ,//
    output  reg             rd_en       ,//
    output  wire            sdram_cke   ,//
    output  wire            sdram_cs_n  ,//
    output  wire            sdram_cas_n ,//
    output  wire            sdram_ras_n ,//
    output  wire            sdram_we_n  ,//
    output  reg     [1:0]   sdram_ba    ,//
    output  reg     [12:0]  sdram_addr  ,//
    inout   wire    [15:0]  sdram_dq     //
);

parameter   IDLE    = 3'b000,
            ARBIT   = 3'b001,
            AREF    = 3'b011,
            WRITE   = 3'b010,
            READ    = 3'b110;

parameter   NOP         = 4'b0111;

reg     [3:0]   sdram_cmd   ;
reg     [2:0]   arbit_state ;//

assign  sdram_cke   = 1'b1;
assign  sdram_dq    = (wr_sdram_en == 1'b1) ? wr_data : 16'hzzzz;
assign  {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n} = sdram_cmd;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        aref_en <= 1'b0;
    else if(aref_end == 1'b1)
        aref_en <= 1'b0;
    else if(arbit_state == ARBIT && aref_req == 1'b1)
        aref_en <= 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en <= 1'b0;
    else if(wr_end == 1'b1)
        wr_en <= 1'b0;
    else if(arbit_state == ARBIT && wr_req == 1'b1 && aref_req == 1'b0)
        wr_en <= 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(rd_end == 1'b1)
        rd_en <= 1'b0;
    else if(arbit_state == ARBIT && rd_req == 1'b1 && wr_req == 1'b0 && aref_req == 1'b0)
        rd_en <= 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        arbit_state <= IDLE;
    else
        case(arbit_state)
            IDLE  :
                if(init_end == 1'b1)
                    arbit_state <= ARBIT;
                else
                    arbit_state <= IDLE;
            ARBIT :
                if(aref_req == 1'b1)
                    arbit_state <= AREF;
                else if(wr_req == 1'b1)
                    arbit_state <= WRITE;
                else if(rd_req == 1'b1)
                    arbit_state <= READ;
            AREF  :
                if(aref_end == 1'b1)
                    arbit_state <= ARBIT;
            WRITE :
                if(wr_end == 1'b1)
                    arbit_state <= ARBIT;
            READ  :
                if(rd_end == 1'b1)
                    arbit_state <= ARBIT;
            default: arbit_state <= IDLE;
        endcase

always@(*)
    if(sys_rst_n == 1'b0)
        begin
            sdram_cmd   <= init_cmd   ;
            sdram_ba    <= init_ba    ;
            sdram_addr  <= init_addr  ;
        end
    else 
        case(arbit_state)
            IDLE  :
                begin
                    sdram_cmd   <= init_cmd   ;
                    sdram_ba    <= init_ba    ;
                    sdram_addr  <= init_addr  ;
                end
            ARBIT :
                begin
                    sdram_cmd   <= NOP        ;
                    sdram_ba    <= 2'b11      ;
                    sdram_addr  <= 13'h1fff   ;
                end
            AREF  :
                begin
                    sdram_cmd   <= aref_cmd   ;
                    sdram_ba    <= aref_ba    ;
                    sdram_addr  <= aref_addr  ;
                end
            WRITE :
                begin
                    sdram_cmd   <= wr_cmd     ;
                    sdram_ba    <= wr_ba      ;
                    sdram_addr  <= wr_addr    ;
                end
            READ  :
                begin
                    sdram_cmd   <= rd_cmd     ;
                    sdram_ba    <= rd_ba      ;
                    sdram_addr  <= rd_addr    ;
                end
            default:
                begin
                    sdram_cmd   <= NOP        ;
                    sdram_ba    <= 2'b11      ;
                    sdram_addr  <= 13'h1fff   ;
                end
        endcase



endmodule