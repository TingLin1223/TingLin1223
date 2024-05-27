module half_adder
(
	input	wire	in_1,
	input	wire	in_2,
	output	wire		sum, //output tybe using wire for use assign syntax give the carry & sum value.
	output	wire		carry
);

assign {carry,sum} = in_1 + in_2;//{carry,sum} is 2 bit width which combined the in_1 plus in_2.


endmodule