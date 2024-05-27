`timescale 1ns/1ns

module tb_simple_fsm ();

reg     sys_clk;
reg     sys_rst_n;
reg     pi_money;

wire    out_cola;
wire    [2:0]   STATE = simple_fsm_inst.STATE; // instance_name.variable, using to connect the sub-module.

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always #10 sys_clk = ~sys_clk;
always @ (posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_money <= 1'b0;
    else
        pi_money <= {$random} % 2;
        

simple_fsm simple_fsm_inst
(
        .sys_clk    (sys_clk),
        .sys_rst_n  (sys_rst_n),
        .pi_money   (pi_money),
        
        .out_cola   (out_cola)
);

endmodule