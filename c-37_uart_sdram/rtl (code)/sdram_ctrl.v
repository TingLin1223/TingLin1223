module sdram_ctrl
(
    //clk & rst
    input   wire            sys_clk         ,
    input   wire            sys_rst_n       ,
    //initial
    output  wire            init_end        ,
    //write
    input   wire            sdram_wr_req    ,
    input   wire    [23:0]  sdram_wr_addr   ,
    input   wire    [9:0]   wr_burst_len    ,
    input   wire    [15:0]  sdram_wr_data   ,//from fifo_wirte
    output  wire            sdram_wr_ack    ,
    //read
    input   wire            sdram_rd_req    ,
    input   wire    [23:0]  sdram_rd_addr   ,
    input   wire    [9:0]   rd_burst_len    ,
    output  wire    [15:0]  sdram_rd_data   ,
    output  wire            sdram_rd_ack    ,//transfer to fifo_read
    //arbit
    output  wire            sdram_cke       ,
    output  wire            sdram_cs_n      ,
    output  wire            sdram_cas_n     ,
    output  wire            sdram_ras_n     ,
    output  wire            sdram_we_n      ,
    output  wire    [1:0]   sdram_ba        ,
    output  wire    [12:0]  sdram_addr      ,
    inout   wire    [15:0]  sdram_dq        
);

//init
wire    [3:0]   init_cmd    ;
wire    [1:0]   init_ba     ;
wire    [12:0]  init_addr   ;
//aref
wire            aref_req    ;
wire    [3:0]   aref_cmd    ;
wire    [1:0]   aref_ba     ;
wire    [12:0]  aref_addr   ;
wire            aref_end    ;
//write
wire            wr_end          ;
wire    [3:0]   wr_cmd          ;
wire    [1:0]   wr_ba           ;
wire    [12:0]  wr_sdram_addr   ;
wire            sdram_en        ;
wire    [15:0]  wr_sdram_data   ;
//read
wire            rd_end          ;
wire    [3:0]   rd_cmd          ;
wire    [1:0]   rd_ba           ;
wire    [12:0]  rd_sdram_addr   ;
wire    [15:0]  rd_sdram_data   ;
//arbit
wire            aref_en         ;
wire            wr_en           ;
wire            rd_en           ;


sdram_init  sdram_init_inst
(
    .sys_clk     (sys_clk   ), // 100MHz clk
    .sys_rst_n   (sys_rst_n ),
                  
    .init_cmd    (init_cmd  ),
    .init_ba     (init_ba   ),
    .init_addr   (init_addr ),
    .init_end    (init_end  )
);

sdram_aref  sdram_aref_inst
(
    .sys_clk     (sys_clk   ), // 100MHz clk
    .sys_rst_n   (sys_rst_n ),
    .init_end    (init_end  ),
    .aref_en     (aref_en   ),
    
    .aref_req    (aref_req  ),
    .aref_cmd    (aref_cmd  ),
    .aref_ba     (aref_ba   ),
    .aref_addr   (aref_addr ),
    .aref_end    (aref_end  )
);

sdram_write sdram_write_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .init_end        (init_end  ),
    .wr_en           (wr_en     ),
    .wr_addr         (sdram_wr_addr),
    .wr_data         (sdram_wr_data),
    .wr_burst_len    (wr_burst_len ), // columns is 9 bit width = 512 data, but 9'b1_1111_1111 = 'd511 so that 'd512 needs 10 bits width.
    
    .wr_ack          (sdram_wr_ack ), // using to fifo_read_en
    .wr_end          (wr_end       ),
    .wr_cmd          (wr_cmd       ),
    .wr_ba           (wr_ba        ),
    .wr_sdram_addr   (wr_sdram_addr),
    .sdram_en        (sdram_en     ), // control sdarm_arbit dq being output.
    .wr_sdram_data   (wr_sdram_data) // assign wr_data and transfer to sdram_arbit.
);

sdram_read  sdram_read_inst
(
    .sys_clk         (sys_clk   ),
    .sys_rst_n       (sys_rst_n ),
    .init_end        (init_end  ),
    .rd_en           (rd_en     ),
    .rd_addr         (sdram_rd_addr),
    .rd_data         (sdram_dq  ),
    .rd_burst_len    (rd_burst_len ), // columns is 9 bit width = 512 data, but 9'b1_1111_1111 = 'd511 so that 'd512 needs 10 bits width.
    
    .rd_ack          (sdram_rd_ack ), // using for fifo_read module write_en
    .rd_end          (rd_end       ),
    .rd_cmd          (rd_cmd       ),
    .rd_ba           (rd_ba        ),
    .rd_sdram_addr   (rd_sdram_addr),
    .rd_sdram_data   (sdram_rd_data)
);

sdram_arbit sdram_arbit_inst
(
    .sys_clk     (sys_clk   ),//100MHz
    .sys_rst_n   (sys_rst_n ),
    
    .init_cmd    (init_cmd  ),
    .init_ba     (init_ba   ),
    .init_addr   (init_addr ),
    .init_end    (init_end  ),
    
    .aref_req    (aref_req  ),
    .aref_cmd    (aref_cmd  ),
    .aref_ba     (aref_ba   ),
    .aref_addr   (aref_addr ),
    .aref_end    (aref_end  ),
    
    .wr_req      (sdram_wr_req  ),
    .wr_cmd      (wr_cmd        ),
    .wr_ba       (wr_ba         ),
    .wr_addr     (wr_sdram_addr ),
    .wr_data     (wr_sdram_data ),
    .wr_sdram_en (sdram_en      ),
    .wr_end      (wr_end        ),
    
    .rd_req      (sdram_rd_req  ),
    .rd_cmd      (rd_cmd    ),
    .rd_ba       (rd_ba     ),
    .rd_addr     (rd_sdram_addr ),
    .rd_end      (rd_end    ),
    
    .aref_en     (aref_en    ),
    .wr_en       (wr_en      ),
    .rd_en       (rd_en      ),
    .sdram_cke   (sdram_cke  ),
    .sdram_cs_n  (sdram_cs_n ),
    .sdram_cas_n (sdram_cas_n),
    .sdram_ras_n (sdram_ras_n),
    .sdram_we_n  (sdram_we_n ),
    .sdram_ba    (sdram_ba   ),
    .sdram_addr  (sdram_addr ),
    .sdram_dq    (sdram_dq   ) 
);

endmodule