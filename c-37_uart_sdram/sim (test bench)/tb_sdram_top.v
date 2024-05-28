`timescale 1ns/1ns

module  tb_sdram_top
();

reg             sys_clk         ;//100MHz, synchronize with sdram
reg             sys_rst_n       ;


reg             wr_fifo_wr_req  ;//from upper level for wr_fifo_wr_en
reg    [15:0]   wr_fifo_wr_data ;//from upper level
reg    [2:0]    wr_gen_cnt      ;
reg             wr_en           ;

reg             rd_fifo_rd_req  ;

reg             read_valid      ;

wire    [15:0]  rd_fifo_rd_data ;
wire    [9:0]   rd_fifo_num     ;

wire            sdram_clk       ;
wire            sdram_cke       ;
wire            sdram_cs_n      ;
wire            sdram_cas_n     ;
wire            sdram_ras_n     ;
wire            sdram_we_n      ;
wire    [1:0]   sdram_ba        ;
wire    [12:0]  sdram_addr      ;
wire    [1:0]   sdram_dqm       ;
wire    [15:0]  sdram_dq        ;


wire            locked      ;
wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_p  ;//phase shifted
wire            rst_n       ;

assign rst_n = (sys_rst_n & locked);

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_gen_cnt <= 3'd0;
    else if(wr_en == 1'b1)
        wr_gen_cnt <= wr_gen_cnt + 1'b1;
    else
        wr_gen_cnt <= 3'd0;
        
always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_fifo_wr_req <= 1'b0;
    else if(wr_gen_cnt == 3'd7)
        wr_fifo_wr_req <= 1'b1;
    else
        wr_fifo_wr_req <= 1'b0;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_fifo_wr_data <= 16'd0;
    else if(wr_gen_cnt == 3'd7)
        wr_fifo_wr_data <= wr_fifo_wr_data + 1'b1;
    else
        wr_fifo_wr_data <= wr_fifo_wr_data;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_en <= 1'b1;
    else if(wr_fifo_wr_data == 16'd10)
        wr_en <= 1'b0;
    else wr_en <= wr_en;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        rd_fifo_rd_req <= 1'b0;
    else if(wr_en == 1'b0 && rd_fifo_num == 10'd10)
        rd_fifo_rd_req <= 1'b1;
    else if(rd_fifo_num <= 10'd1)
        rd_fifo_rd_req <= 1'b0;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        read_valid <= 1'b1;
    else if(rd_fifo_num == 10'd10)
        read_valid <= 1'b0;
        

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits  = 9 ;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;
defparam    sdram_top_inst.sdram_ctrl_inst.sdram_aref_inst.T_AREF = 39;

sdram_top   sdram_top_inst
(
    .sys_clk         (clk_100m),//100MHz, synchronize with sdram
    .sys_rst_n       (rst_n),
    .clk_out         (clk_100m_p),//from clk_gen ip_cope, will using for sdram_clk out.
    //writting fifo
    .wr_fifo_wr_clk  (clk_50m),//50MHz
    .wr_fifo_wr_req  (wr_fifo_wr_req  ),//from upper level for wr_fifo_wr_en
    .wr_fifo_wr_data (wr_fifo_wr_data ),//from upper level
    .sdram_wr_b_addr (24'h000_000),//beginning address
    .sdram_wr_e_addr (24'h000_00a),//ending address
    .wr_burst_len    (10'd10),//burst length
    .wr_rst          (~rst_n),

    .rd_fifo_rd_clk  (clk_50m),//50MHz
    .rd_fifo_rd_req  (rd_fifo_rd_req),
    .sdram_rd_b_addr (24'h000_000),
    .sdram_rd_e_addr (24'h000_00a),
    .rd_burst_len    (10'd10),
    .rd_rst          (~rst_n),
    .read_valid      (read_valid),
    //fifo_ctrl out
    .rd_fifo_rd_data (rd_fifo_rd_data ),
    .rd_fifo_num     (rd_fifo_num     ),
    //sdram_ctrl out
    .sdram_clk       (sdram_clk   ),
    .sdram_cke       (sdram_cke   ),
    .sdram_cs_n      (sdram_cs_n  ),
    .sdram_cas_n     (sdram_cas_n ),
    .sdram_ras_n     (sdram_ras_n ),
    .sdram_we_n      (sdram_we_n  ),
    .sdram_ba        (sdram_ba    ),
    .sdram_addr      (sdram_addr  ),
    .sdram_dqm       (sdram_dqm   ),
    .sdram_dq        (sdram_dq    )
);

clk_gen clk_gen_inst 
(
    .areset ( ~sys_rst_n    ),
    .inclk0 ( sys_clk       ),
    .c0     ( clk_50m       ),
    .c1     ( clk_100m      ),
    .c2     ( clk_100m_p    ),
    .locked ( locked        )
    );

sdram_model_plus    sdram_model_plus_inst
(
    .Dq      (sdram_dq   ), 
    .Addr    (sdram_addr ), 
    .Ba      (sdram_ba   ), 
    .Clk     (sdram_clk  ), 
    .Cke     (sdram_cke  ), 
    .Cs_n    (sdram_cs_n ), 
    .Ras_n   (sdram_ras_n), 
    .Cas_n   (sdram_cas_n), 
    .We_n    (sdram_we_n ), 
    .Dqm     (sdram_dqm  ),
    .Debug   (1'b1       )
    );

endmodule