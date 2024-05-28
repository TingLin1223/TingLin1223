`timescale 1ns/1ns

module tb_sdram_read();


reg             sys_clk     ; // 50MHz clk
reg             sys_rst_n   ;

wire    [3:0]   init_cmd    ;
wire    [1:0]   init_ba     ;
wire    [12:0]  init_addr   ;
wire            init_end    ;
wire            locked      ;
wire            clk_50m     ;
wire            clk_100m    ;
wire            clk_100m_p  ;//phase shifted
wire            rst_n       ;
//
wire            wr_ack          ;
wire            wr_end          ;
wire    [3:0]   wr_cmd          ;
wire    [1:0]   wr_ba           ;
wire    [12:0]  wr_sdram_addr   ;
wire            sdram_en        ;
wire    [15:0]  wr_sdram_data   ;

reg             wr_en           ;
reg     [15:0]  wr_data_in      ;
//
wire            rd_ack          ;
wire            rd_end          ;
wire    [3:0]   rd_cmd          ;
wire    [1:0]   rd_ba           ;
wire    [12:0]  rd_sdram_addr   ;
wire    [15:0]  rd_sdram_data   ;

reg             rd_en           ;
//
wire    [3:0]   w_r_cmd       ;// tb using to judge which value should transfer to sdram.
wire    [1:0]   w_r_ba        ;// tb using to judge which value should transfer to sdram.
wire    [12:0]  w_r_addr      ;// tb using to judge which value should transfer to sdram.

wire    [3:0]   sdram_cmd       ;// tb using to judge which value should transfer to sdram.
wire    [1:0]   sdram_ba        ;// tb using to judge which value should transfer to sdram.
wire    [12:0]  sdram_addr      ;// tb using to judge which value should transfer to sdram.
wire    [15:0]  sdram_data      ;// tb using to judge which value should transfer to sdram.

//
reg            wr_rd_arbit;

assign w_r_cmd    = (rd_en == 1'b1)   ?   rd_cmd : wr_cmd;
assign w_r_ba     = (rd_en == 1'b1)   ?   rd_ba : wr_ba;
assign w_r_addr   = (rd_en == 1'b1)   ?   rd_sdram_addr : wr_sdram_addr;

assign sdram_cmd  = (init_end == 1'b1) ? w_r_cmd : init_cmd;
assign sdram_ba   = (init_end == 1'b1) ? w_r_ba : init_ba;
assign sdram_addr = (init_end == 1'b1) ? w_r_addr : init_addr;
assign sdram_data = (sdram_en == 1'b1) ? wr_sdram_data : 16'hzzzz;

assign rst_n = (sys_rst_n & locked);

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
    end

defparam    sdram_model_plus_inst.addr_bits = 13;
defparam    sdram_model_plus_inst.data_bits = 16;
defparam    sdram_model_plus_inst.col_bits  = 9 ;
defparam    sdram_model_plus_inst.mem_sizes = 2*1024*1024;

always #10 sys_clk = ~sys_clk;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_en <= 1'b0;
    else if(wr_end == 1'b1)
        wr_en <= 1'b0;
    else if(init_end == 1'b1 && wr_rd_arbit == 1'b0 && rd_en == 1'b0)
        wr_en <= 1'b1;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(rd_end == 1'b1)
        rd_en <= 1'b0;
    else if(init_end == 1'b1 && wr_rd_arbit == 1'b1 && wr_en == 1'b0)
        rd_en <= 1'b1;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_data_in <= 16'd0;
    else if(wr_data_in == 16'd10)
        wr_data_in <= 16'd0;
    else if(wr_ack == 1'b1)
        wr_data_in <= wr_data_in + 1'b1;

always@(posedge clk_100m or negedge rst_n)
    if(rst_n == 1'b0)
        wr_rd_arbit <= 1'b0;
    else if(init_end == 1'b1 && wr_en == 1'b0 && rd_en == 1'b0)
        wr_rd_arbit <= ~wr_rd_arbit;

sdram_init  sdram_init_inst
(
    .sys_clk     (clk_100m  ), // 100MHz clk
    .sys_rst_n   (rst_n     ),
                  
    .init_cmd    (init_cmd  ),
    .init_ba     (init_ba   ),
    .init_addr   (init_addr ),
    .init_end    (init_end  )
);

sdram_write sdram_write_inst
(
    .sys_clk         (clk_100m  ),
    .sys_rst_n       (rst_n     ),
    .init_end        (init_end  ),
    .wr_en           (wr_en     ),
    .wr_addr         (24'h000_000),
    .wr_data         (wr_data_in),
    .wr_burst_len    (10'd10    ), // columns is 9 bit width = 512 data, but 9'b1_1111_1111 = 'd511 so that 'd512 needs 10 bits width.
    
    .wr_ack          (wr_ack       ), // using to fifo_read_en
    .wr_end          (wr_end       ),
    .wr_cmd          (wr_cmd       ),
    .wr_ba           (wr_ba        ),
    .wr_sdram_addr   (wr_sdram_addr),
    .sdram_en        (sdram_en     ), // control sdram_arbit dq being output.
    .wr_sdram_data   (wr_sdram_data) // assign wr_data and transfer to sdram_arbit.
);

sdram_read  sdram_read_inst
(
    .sys_clk         (clk_100m  ),
    .sys_rst_n       (rst_n     ),
    .init_end        (init_end  ),
    .rd_en           (rd_en     ),
    .rd_addr         (24'h000_000),
    .rd_data         (sdram_data),
    .rd_burst_len    (10'd10    ), // columns is 9 bit width = 512 data, but 9'b1_1111_1111 = 'd511 so that 'd512 needs 10 bits width.
    
    .rd_ack          (rd_ack       ), // using to fifo_wirte_en
    .rd_end          (rd_end       ),
    .rd_cmd          (rd_cmd       ),
    .rd_ba           (rd_ba        ),
    .rd_sdram_addr   (rd_sdram_addr),
    .rd_sdram_data   (rd_sdram_data)
);

sdram_model_plus    sdram_model_plus_inst
(
    .Dq      (sdram_data ), 
    .Addr    (sdram_addr ), 
    .Ba      (sdram_ba   ), 
    .Clk     (clk_100m_p ), 
    .Cke     (1'b1       ), 
    .Cs_n    (sdram_cmd[3]), 
    .Ras_n   (sdram_cmd[2]), 
    .Cas_n   (sdram_cmd[1]), 
    .We_n    (sdram_cmd[0]), 
    .Dqm     (2'b00      ),
    .Debug   (1'b1       )
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


endmodule