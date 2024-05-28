module  sdram_top
(
    input   wire            sys_clk         ,//100MHz, synchronize with sdram
    input   wire            sys_rst_n       ,
    input   wire            clk_out         ,//from clk_gen ip_cope, will using for sdram_clk out.
    //writting fifo
    input   wire            wr_fifo_wr_clk  ,//50MHz
    input   wire            wr_fifo_wr_req  ,//from upper level for wr_fifo_wr_en
    input   wire    [15:0]  wr_fifo_wr_data ,//from upper level
    input   wire    [23:0]  sdram_wr_b_addr ,//beginning address
    input   wire    [23:0]  sdram_wr_e_addr ,//ending address
    input   wire    [9:0]   wr_burst_len    ,//burst length
    input   wire            wr_rst          ,

    input   wire            rd_fifo_rd_clk  ,//50MHz
    input   wire            rd_fifo_rd_req  ,
    input   wire    [23:0]  sdram_rd_b_addr ,
    input   wire    [23:0]  sdram_rd_e_addr ,
    input   wire    [9:0]   rd_burst_len    ,
    input   wire            rd_rst          ,
    input   wire            read_valid      ,
    //fifo_ctrl out
    output  wire    [15:0]  rd_fifo_rd_data ,
    output  wire    [9:0]   rd_fifo_num     ,
    //sdram_ctrl out
    output  wire            sdram_clk       ,
    output  wire            sdram_cke       ,
    output  wire            sdram_cs_n      ,
    output  wire            sdram_cas_n     ,
    output  wire            sdram_ras_n     ,
    output  wire            sdram_we_n      ,
    output  wire    [1:0]   sdram_ba        ,
    output  wire    [12:0]  sdram_addr      ,
    output  wire    [1:0]   sdram_dqm       ,
    inout   wire    [15:0]  sdram_dq        
);


wire            init_end       ;
wire            sdram_wr_ack   ;
wire    [15:0]  sdram_rd_data  ;
wire            sdram_rd_ack   ;

wire            sdram_wr_req   ;
wire    [23:0]  sdram_wr_addr  ;
wire    [15:0]  sdram_wr_data  ;

wire            sdram_rd_req   ;
wire    [23:0]  sdram_rd_addr  ;

assign  sdram_dqm = 2'b00;
assign  sdram_clk = clk_out;

sdram_ctrl  sdram_ctrl_inst
(
    //clk & rst
    .sys_clk         (sys_clk  ),
    .sys_rst_n       (sys_rst_n),
    //initial
    .init_end        (init_end ),
    //write
    .sdram_wr_req    (sdram_wr_req ),
    .sdram_wr_addr   (sdram_wr_addr),
    .wr_burst_len    (wr_burst_len ),
    .sdram_wr_data   (sdram_wr_data),//from fifo_wirte
    .sdram_wr_ack    (sdram_wr_ack ),
    //read
    .sdram_rd_req    (sdram_rd_req ),
    .sdram_rd_addr   (sdram_rd_addr),
    .rd_burst_len    (rd_burst_len ),
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


fifo_ctrl   fifo_ctrl_inst
(
    .sys_clk         (sys_clk   ),//100MHz, synchronize with sdram
    .sys_rst_n       (sys_rst_n ),
    //writting fifo
    .wr_fifo_wr_clk  (wr_fifo_wr_clk  ),//50MHz
    .wr_fifo_wr_req  (wr_fifo_wr_req  ),//from upper level for wr_fifo_wr_en
    .wr_fifo_wr_data (wr_fifo_wr_data ),//from upper level
    .sdram_wr_b_addr (sdram_wr_b_addr ),//beginning address
    .sdram_wr_e_addr (sdram_wr_e_addr ),//ending address
    .wr_burst_len    (wr_burst_len    ),//burst length
    .wr_rst          (wr_rst          ),
    //reading fifo
    .rd_fifo_rd_clk  (rd_fifo_rd_clk  ),//50MHz
    .rd_fifo_rd_req  (rd_fifo_rd_req  ),
    .sdram_rd_b_addr (sdram_rd_b_addr ),
    .sdram_rd_e_addr (sdram_rd_e_addr ),
    .rd_burst_len    (rd_burst_len    ),
    .rd_rst          (rd_rst          ),
    .rd_fifo_rd_data (rd_fifo_rd_data ),//from fifo
    .rd_fifo_num     (rd_fifo_num     ),//from fifo
    //sdram init & sdram read_valid
    .read_valid      (read_valid      ),
    .init_end        (init_end        ),
    //sdram write
    .sdram_wr_ack    (sdram_wr_ack    ),
    .sdram_wr_req    (sdram_wr_req    ),
    .sdram_wr_addr   (sdram_wr_addr   ),
    .sdram_wr_data   (sdram_wr_data   ),
    //sdram read     
    .sdram_rd_ack    (sdram_rd_ack    ),
    .sdram_rd_data   (sdram_rd_data   ),
    .sdram_rd_req    (sdram_rd_req    ),
    .sdram_rd_addr   (sdram_rd_addr   )
);


endmodule