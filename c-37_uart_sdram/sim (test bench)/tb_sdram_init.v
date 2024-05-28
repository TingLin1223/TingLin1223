`timescale 1ns/1ns

module tb_sdram_init();


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

sdram_init  sdram_init_inst
(
    .sys_clk     (clk_100m  ), // 100MHz clk
    .sys_rst_n   (rst_n     ),
                  
    .init_cmd    (init_cmd  ),
    .init_ba     (init_ba   ),
    .init_addr   (init_addr ),
    .init_end    (init_end  )
);

sdram_model_plus    sdram_model_plus_inst
(
    .Dq      (           ), 
    .Addr    (init_addr  ), 
    .Ba      (init_ba    ), 
    .Clk     (clk_100m_p ), 
    .Cke     (1'b1       ), 
    .Cs_n    (init_cmd[3]), 
    .Ras_n   (init_cmd[2]), 
    .Cas_n   (init_cmd[1]), 
    .We_n    (init_cmd[0]), 
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