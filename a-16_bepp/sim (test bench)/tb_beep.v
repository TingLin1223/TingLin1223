`timescale 1ns/1ns

module tb_beep();

reg     sys_clk;
reg     sys_rst_n;

wire    beep;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always #10 sys_clk = ~sys_clk;

beep
#(
    .CNT_MAX(25'd 24_999_99), // re-define for easy to observe.
    .DO     (18'd 190_83),
    .RE     (18'd 170_06),
    .MI     (18'd 151_51),
    .FA     (18'd 143_26),
    .SO     (18'd 127_55),
    .LA     (18'd 113_63),
    .SI     (18'd 101_21)
)
beep_inst
(
    .sys_clk    (sys_clk),
    .sys_rst_n  (sys_rst_n),
    
    .beep       (beep)
);

endmodule