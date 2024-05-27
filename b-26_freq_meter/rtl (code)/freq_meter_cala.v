module  freq_meter_cala
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            test_clk    ,
    
    output  reg    [31:0]   freq         
);
//freq give bigger bit width for tolerance

parameter   SYS_CNT_MAX     = 27'd74_999_999;//1.5sec
parameter   SYS_RISE_MAX    = 27'd12_499_999;//0.25sec
parameter   STAND_CLK_FREQ  = 27'd100_000_000;//standard clock frequence

reg     [26:0]  sys_cnt;
reg             gate_sys;
reg             gate_test;
reg     [47:0]  cnt_test; //give bigger bit width for tolerance
reg             gate_test_reg;
reg     [47:0]  data_test;//give bigger bit width for tolerance
reg     [47:0]  cnt_stand;//give bigger bit width for tolerance
reg             gate_stand;
reg     [47:0]  data_stand;//give bigger bit width for tolerance
reg             cala_flag;


wire            standard_clk;
wire            fall_test;
wire            fall_stand;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sys_cnt <= 27'd0;
    else if(sys_cnt == SYS_CNT_MAX)
        sys_cnt <= 27'd0;
    else
        sys_cnt <= sys_cnt + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_sys <= 1'b0;
    else if((sys_cnt >= SYS_RISE_MAX) && 
            (sys_cnt < (SYS_CNT_MAX - SYS_RISE_MAX - 27'd1)))
        gate_sys <= 1'b1;
    else
        gate_sys <= 1'b0;

always@(posedge test_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_test <= 1'b0;
    else 
        gate_test <= gate_sys;

always@(posedge test_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_test <= 48'd0;
    else if(gate_test == 1'b0)
        cnt_test <= 48'd0;
    else if(gate_test == 1'b1)
        cnt_test <= cnt_test + 1'b1;

always@(posedge test_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_test_reg        <= 1'b0;
    else 
        gate_test_reg <= gate_test;

assign fall_test = ((gate_test == 1'b0)&&(gate_test_reg == 1'b1))
                    ? 1'b1 : 1'b0;

always@(posedge test_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_test <= 48'd0;
    else if(fall_test == 1'b1)
        data_test <= cnt_test;

always@(posedge standard_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_stand <= 48'd0;
    else if(gate_test == 1'b0)
        cnt_stand <= 48'd0;
    else if(gate_test == 1'b1)
        cnt_stand <= cnt_stand + 1'b1;

always@(posedge standard_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        gate_stand <= 1'b0;
    else
        gate_stand <= gate_test;

assign fall_stand = ((gate_test == 1'b0)&&(gate_stand == 1'b1))
                    ? 1'b1 : 1'b0;

always@(posedge standard_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_stand <= 48'd0;
    else if(fall_stand == 1'b1)
        data_stand <= cnt_stand;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cala_flag <= 1'b0;
    else if(sys_cnt == SYS_CNT_MAX)
        cala_flag <= 1'b1;
    else
        cala_flag <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        freq <= 32'd0;
    else if(cala_flag == 1'b1)
        freq <= ((STAND_CLK_FREQ / data_stand) * data_test);// divide fist then multiply, make sure value won't over.





stand_clk   stand_clk_inst 
(
    .areset ( ~sys_rst_n),
    .inclk0 ( sys_clk   ),
    .c0     ( standard_clk )
    );


endmodule