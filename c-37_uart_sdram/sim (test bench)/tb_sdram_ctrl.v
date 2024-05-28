`timescale 1ns/1ns

module  tb_sdram_ctrl();

reg             sys_clk;
reg             sys_rst_n;

wire            locked      ;
wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_p  ;//phase shifted
wire            rst_n       ;

wire            init_end    ;
wire            sdram_wr_ack;
wire    [15:0]  sdram_rd_data;
wire            sdram_rd_ack;
wire            sdram_cke   ;
wire            sdram_cs_n  ;
wire            sdram_cas_n ;
wire            sdram_ras_n ;
wire            sdram_we_n  ;
wire    [1:0]   sdram_ba    ;
wire    [12:0]  sdram_addr  ;
wire    [15:0]  sdram_dq    ;

reg     [15:0]  sdram_wr_data;
reg             sdram_wr_req;
reg             sdram_rd_req;

reg            wr_rd_arbit;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        sdram_wr_data <= 16'd0;
    else if(sdram_wr_data == 16'd10)
        sdram_wr_data <= 16'd0;
    else if(sdram_wr_ack == 1'b1)
        sdram_wr_data <= sdram_wr_data + 1'b1;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        sdram_wr_req <= 1'b0;
    else if(init_end == 1'b1 && wr_rd_arbit == 1'b0 && sdram_rd_req == 1'b0)
        sdram_wr_req <= 1'b1;
    else if(sdram_wr_data == 16'd10)
        sdram_wr_req <= 1'b0;
    
always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        sdram_rd_req <= 1'b0;
    else if(sdram_wr_req == 1'b0 && wr_rd_arbit == 1'b1 && init_end == 1'b1)
        sdram_rd_req <= 1'b1;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_rd_arbit <= 1'b0;
    else if(init_end == 1'b1 && sdram_wr_req == 1'b0 && sdram_rd_req == 1'b0)
        wr_rd_arbit <= ~wr_rd_arbit;


assign rst_n = (sys_rst_n & locked);

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits  = 9 ;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;
defparam    sdram_ctrl_inst.sdram_aref_inst.T_AREF = 39;

clk_gen clk_gen_inst 
(
    .areset ( ~sys_rst_n    ),
    .inclk0 ( sys_clk       ),
    .c0     ( clk_50m       ),
    .c1     ( clk_100m      ),
    .c2     ( clk_100m_p    ),
    .locked ( locked        )
    );

sdram_ctrl  sdram_ctrl_inst
(
    //clk & rst
    .sys_clk         (clk_100m  ),
    .sys_rst_n       (rst_n     ),
    //initial
    .init_end        (init_end  ),
    //write
    .sdram_wr_req    (sdram_wr_req),
    .sdram_wr_addr   (24'h000_000),
    .wr_burst_len    (10'd10    ),
    .sdram_wr_data   (sdram_wr_data),//from fifo_wirte
    .sdram_wr_ack    (sdram_wr_ack),
    //read
    .sdram_rd_req    (sdram_rd_req),
    .sdram_rd_addr   (24'h000_000),
    .rd_burst_len    (10'd10    ),
    .sdram_rd_data   (sdram_rd_data),
    .sdram_rd_ack    (sdram_rd_ack ),//transfer to fifo_read
    //arbit
    .sdram_cke       (sdram_cke    ),
    .sdram_cs_n      (sdram_cs_n   ),
    .sdram_cas_n     (sdram_cas_n  ),
    .sdram_ras_n     (sdram_ras_n  ),
    .sdram_we_n      (sdram_we_n   ),
    .sdram_ba        (sdram_ba     ),
    .sdram_addr      (sdram_addr   ),
    .sdram_dq        (sdram_dq     )
);

sdram_model_plus    sdram_model_plus_inst
(
    .Dq      (sdram_dq   ), 
    .Addr    (sdram_addr ), 
    .Ba      (sdram_ba   ), 
    .Clk     (clk_100m_p ), 
    .Cke     (sdram_cke  ), 
    .Cs_n    (sdram_cs_n ), 
    .Ras_n   (sdram_ras_n), 
    .Cas_n   (sdram_cas_n), 
    .We_n    (sdram_we_n ), 
    .Dqm     (2'b00      ),
    .Debug   (1'b1       )
    );

endmodule