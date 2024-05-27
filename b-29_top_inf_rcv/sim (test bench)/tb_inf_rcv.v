`timescale 1ns/1ns
module tb_inf_rcv();

reg             sys_clk;
reg             sys_rst_n;
reg             inf_in;

wire            repeat_en;
wire    [19:0]  data;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        inf_in  <= 1'b1;
        #30
        sys_rst_n <= 1'b1;
        #1000
// lead code
        inf_in <= 1'b0;
        #9000_000
        inf_in <= 1'b1;
        #4500_000
        inf_in <= 1'b0;
//address code (8'h57, 8'b0101_0111)
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
//address code inversed 8'b1010_1000
        inf_in <= 1'b0; 
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
//command code 8'h22, 8'b0010_0010
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
//command code inversed 8'b1101_1101
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #560_000        //0
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
        #1690_000       //1
//end position
        inf_in <= 1'b0;
        #560_000
//keep high
        inf_in <= 1'b1;
        #4200_0000
//repeat code
        inf_in <= 1'b0;
        #9000_000
        inf_in <= 1'b1;
        #2250_000
//ending position
        inf_in <= 1'b0;
        #560_000
        inf_in <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;

inf_rcv inf_rcv_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .inf_in      (inf_in),
    
    .repeat_en   (repeat_en),
    .data        (data)
);

endmodule