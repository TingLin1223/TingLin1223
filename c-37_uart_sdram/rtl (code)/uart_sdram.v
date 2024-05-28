module  uart_sdram
(
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    input   wire            rx              ,
    
    output  wire            tx              ,
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

parameter CLK_FREQ = 'd50_000_000   ;
parameter UART_BPS = 'd9600         ;
parameter DATA_NUM = 'd10           ;

wire            locked      ;
wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_p  ;//phase shifted
wire            rst_n       ;

wire    [7:0]   rx_data;
wire            rx_flag;
wire            po_flag;

wire    [16:0]  rd_fifo_rd_data ;
wire    [9:0]   rd_fifo_num     ;
reg             read_valid      ;
reg     [15:0]  cnt_wait        ;
reg     [9:0]   data_num        ;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_wait <= 16'd0;
    else if(cnt_wait == 16'd750)
        cnt_wait <= 16'd0;
    else if(data_num == DATA_NUM)
        cnt_wait <= cnt_wait + 1'b1;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        data_num <= 9'd0;
    else if(read_valid == 1'b1)
        data_num <= 9'd0;
    else if(rx_flag == 1'b1) //rx module transfered 1 data, data_num + 1
        data_num <= data_num + 1'b1;

always@(posedge clk_50m or negedge rst_n)
    if(rst_n == 1'b0)
        read_valid <= 1'b0;
    else if(cnt_wait == 16'd750)
        read_valid <= 1'b1;
    else if(rd_fifo_num == DATA_NUM)
        read_valid <= 1'b0;

wire            rd_en;//from reading_fifo to sdram_top.fifo_ctrl
wire    [7:0]   tx_data;
wire            tx_flag;

assign rst_n = (sys_rst_n & locked);

sdram_top   sdram_top_inst
(
    .sys_clk         (clk_100m      ),//100MHz, synchronize with sdram
    .sys_rst_n       (rst_n         ),
    .clk_out         (clk_100m_p    ),//from clk_gen ip_cope, will using for sdram_clk out.
    //writting fifo
    .wr_fifo_wr_clk  (clk_50m       ),//50MHz
    .wr_fifo_wr_req  (rx_flag       ),//from upper level for wr_fifo_wr_en
    .wr_fifo_wr_data ({8'b0,rx_data}),//from upper level
    .sdram_wr_b_addr (0             ),//beginning address
    .sdram_wr_e_addr (DATA_NUM      ),//ending address
    .wr_burst_len    (DATA_NUM      ),//burst length
    .wr_rst          (~rst_n),

    .rd_fifo_rd_clk  (clk_50m       ),//50MHz
    .rd_fifo_rd_req  (rd_en         ),
    .sdram_rd_b_addr (0             ),
    .sdram_rd_e_addr (DATA_NUM      ),
    .rd_burst_len    (DATA_NUM      ),
    .rd_rst          (~rst_n),
    .read_valid      (read_valid    ),
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

reading_fifo    reading_fifo_inst
(
    .sys_clk         (clk_50m       ),
    .sys_rst_n       (rst_n         ),
    .rd_fifo_num     (rd_fifo_num   ),
    .rd_fifo_rd_data (rd_fifo_rd_data),//uart using 8 bit width data.
    .burst_num       (DATA_NUM      ),
    
    .rd_en           (rd_en),
    .tx_data         (tx_data),
    .tx_flag         (tx_flag)
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


uart_rx
#(
    .UART_BPS   (UART_BPS),
    .CLK_FREQ   (CLK_FREQ)
)
uart_rx_inst
(
    .sys_clk     (clk_50m),
    .sys_rst_n   (rst_n),
    .rx          (rx),
    
    .po_data     (rx_data),
    .po_flag     (rx_flag)
);

uart_tx 
#(
    .UART_BPS   (UART_BPS),
    .CLK_FREQ   (CLK_FREQ)
)
uart_tx_inst
(
    .sys_clk     (clk_50m),
    .sys_rst_n   (rst_n),
    .pi_data     (tx_data),
    .pi_flag     (tx_flag),

    .tx          (tx)
);

endmodule