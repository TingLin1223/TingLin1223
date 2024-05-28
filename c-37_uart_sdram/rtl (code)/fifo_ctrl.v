module  fifo_ctrl
(
    input   wire            sys_clk         ,//100MHz, synchronize with sdram
    input   wire            sys_rst_n       ,
    //writting fifo
    input   wire            wr_fifo_wr_clk  ,//50MHz
    input   wire            wr_fifo_wr_req  ,//from upper level for wr_fifo_wr_en
    input   wire    [15:0]  wr_fifo_wr_data ,//from upper level
    input   wire    [23:0]  sdram_wr_b_addr ,//beginning address from upper level
    input   wire    [23:0]  sdram_wr_e_addr ,//ending address from upper level
    input   wire    [9:0]   wr_burst_len    ,//burst length from upper level
    input   wire            wr_rst          ,// = ~ (sys_rst_n & locked) from upper level
    //reading fifo
    input   wire            rd_fifo_rd_clk  ,//50MHz
    input   wire            rd_fifo_rd_req  ,
    input   wire    [23:0]  sdram_rd_b_addr ,//beginning address from upper level
    input   wire    [23:0]  sdram_rd_e_addr ,//ending address from upper level
    input   wire    [9:0]   rd_burst_len    ,//burst length from upper level
    input   wire            rd_rst          ,// = ~ (sys_rst_n & locked) from upper level
    output  wire    [15:0]  rd_fifo_rd_data ,//from rd_fifo
    output  wire    [9:0]   rd_fifo_num     ,//from rd_fifo
    //sdram init & sdram read_valid
    input   wire            read_valid      ,//from top module.
    input   wire            init_end        ,//from sdram_init module.
    //sdram write
    input   wire            sdram_wr_ack    ,//from sdram_write module
    output  reg             sdram_wr_req    ,//if wr_fifo have more than 10 data, send request to sdarm_arbit module.
    output  reg     [23:0]  sdram_wr_addr   ,//address
    output  wire    [15:0]  sdram_wr_data   ,//wr_fifo read out data
    //sdram read
    input   wire            sdram_rd_ack    ,//from sdram_read module, using to write data to rd_fifo
    input   wire    [15:0]  sdram_rd_data   ,//from sdram_read module, data write to rd_fifo
    output  reg             sdram_rd_req    ,//if rd_fifo stored data less than 10, send request to sdram_arbit module.
    output  reg     [23:0]  sdram_rd_addr   // reading address
);

wire    [9:0]   wr_fifo_num;
wire            wr_ack_fall;
wire            rd_ack_fall;

reg             wr_ack_dly;
reg             rd_ack_dly;

assign  wr_ack_fall = (~sdram_wr_ack & wr_ack_dly);
assign  rd_ack_fall = (~sdram_rd_ack & rd_ack_dly);

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_ack_dly <= 1'b0;
    else
        wr_ack_dly <= sdram_wr_ack;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_ack_dly <= 1'b0;
    else
        rd_ack_dly <= sdram_rd_ack;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            sdram_wr_req <= 1'b0;
            sdram_rd_req <= 1'b0;
        end
    else if(init_end == 1'b1)
        begin
            if(wr_fifo_num >= wr_burst_len)
                begin
                    sdram_wr_req <= 1'b1;
                    sdram_rd_req <= 1'b0;
                end
            else if(rd_fifo_num < rd_burst_len && read_valid == 1'b1)
                begin
                    sdram_wr_req <= 1'b0;
                    sdram_rd_req <= 1'b1;
                end
            else
                begin
                    sdram_wr_req <= 1'b0;
                    sdram_rd_req <= 1'b0;
                end
        end
    else
        begin
            sdram_wr_req <= 1'b0;
            sdram_rd_req <= 1'b0;
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sdram_wr_addr <= 24'b0;
    else if(wr_rst == 1'b1)
        sdram_wr_addr <= sdram_wr_b_addr;//give starting address
    else if(wr_ack_fall == 1'b1)
        begin
            if(sdram_wr_addr < (sdram_wr_e_addr - wr_burst_len))//assume ending address is 100, if wr_address < 100 - 10, next address is wr_address + 10
                sdram_wr_addr <= sdram_wr_addr + wr_burst_len;
            else
                sdram_wr_addr <= sdram_wr_b_addr;
        end
    
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sdram_rd_addr <= 24'b0;
    else if(rd_rst == 1'b1)
        sdram_rd_addr <= sdram_rd_b_addr;
    else if(rd_ack_fall == 1'b1)
        begin
            if(sdram_rd_addr < (sdram_rd_e_addr - rd_burst_len))
                sdram_rd_addr <= sdram_rd_addr + rd_burst_len;
            else
                sdram_rd_addr <= sdram_rd_b_addr;
        end

wr_fifo_16x1024 wr_fifo_16x1024_inst //using to trnasfer data to sdram_write module, oringinal data from rs232
(
    .aclr       ( wr_rst||~sys_rst_n),
    .data       ( wr_fifo_wr_data   ),//data from rs232
    .rdclk      ( sys_clk           ),//sdram_write module read, clock 100MHz.
    .rdreq      ( sdram_wr_ack      ),//from sdram_write
    .wrclk      ( wr_fifo_wr_clk    ),//50MHz, same as rs232
    .wrreq      ( wr_fifo_wr_req    ),//from rs232 pi flag
    .q          ( sdram_wr_data     ),//transfer out to sdram_write module
    .rdusedw    ( wr_fifo_num       ),//how many data can be read out to sdram_write module
    .wrusedw    ()
    );


wr_fifo_16x1024 rd_fifo_16x1024_inst 
(
    .aclr       ( rd_rst||~sys_rst_n),
    .data       ( sdram_rd_data     ),//data from sdram_read module
    .rdclk      ( rd_fifo_rd_clk    ),//50MHz, same as reading_fifo module
    .rdreq      ( rd_fifo_rd_req    ),//from reading_fifo module
    .wrclk      ( sys_clk           ),//100MHz, same as sdram_read module
    .wrreq      ( sdram_rd_ack      ),//from sdram_read module
    .q          ( rd_fifo_rd_data   ),//transfer out to read_fifo_module
    .rdusedw    (),
    .wrusedw    ( rd_fifo_num       )//how many data have been written to read_fifo.
    );


endmodule