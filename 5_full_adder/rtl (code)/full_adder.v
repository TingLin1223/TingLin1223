module full_adder
(
    input   wire    in_1,
    input   wire    in_2,
    input   wire    cin,
    
    output  wire    sum,
    output  wire    carry
);

wire    h0_sum;
wire    h0_carry;
wire    h1_carry;

half_adder half_adder_inst0
(
    .in_1(in_1) ,
    .in_2(in_2) ,
    .sum(h0_sum)    ,
    .carry(h0_carry)    
);

half_adder half_adder_inst1
(
    .in_1(h0_sum)   ,
    .in_2(cin)  ,
    .sum(sum)   ,
    .carry(h1_carry)    
);
assign carry = (h0_carry | h1_carry);

endmodule