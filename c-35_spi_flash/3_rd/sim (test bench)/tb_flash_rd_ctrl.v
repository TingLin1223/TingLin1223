`timescale  1ns/1ns

module  tb_flash_rd_ctrl();

reg             sys_clk;
reg             sys_rst_n;
reg             key_flag;
        
wire            sck;
wire            cs_n;
wire            mosi;
wire            miso;
wire    [7:0]   pi_data;
wire            pi_flag;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        key_flag <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
        #1000
        key_flag <= 1'b1;
        #20
        key_flag <= 1'b0;
    end

always #10 sys_clk = ~ sys_clk;

flash_rd_ctrl   flash_rd_ctrl_inst
(
    .sys_clk     (sys_clk   ),
    .sys_rst_n   (sys_rst_n ),
    .key_flag    (key_flag  ),
    .miso        (miso      ),
    
    .sck         (sck       ),
    .cs_n        (cs_n      ),
    .mosi        (mosi      ),
    .pi_data     (pi_data   ),
    .pi_flag     (pi_flag   )
);

defparam memory.mem_access.initfile = "initmemory.txt";
defparam flash_rd_ctrl_inst.WAIT_MAX = 100;

m25p16 memory 
(
    .c          (sck    ), 
    .data_in    (mosi   ), 
    .s          (cs_n   ), 
    .w          (1'b1   ), 
    .hold       (1'b1   ), 
    .data_out   (miso   )
);


endmodule