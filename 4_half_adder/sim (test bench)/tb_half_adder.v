`timescale 1ns/1ns
module tb_half_adder ();

reg     in_1;
reg     in_2;

wire    sum;
wire    carry;

initial
    begin
        in_1    <= 1'b0;
        in_2    <= 1'b0;
    end


always #10 in_1 <= {$random} % 2;
always #10 in_2 <= {$random} % 2;


half_adder half_adder_inst
(
    .in_1   (in_1),
    .in_2   (in_2),
    .sum    (sum),
    .carry  (carry)
);
endmodule











