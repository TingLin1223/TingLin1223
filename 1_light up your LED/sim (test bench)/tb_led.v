// timescale is ns.
`timescale  1ns/1ns


module  tb_led();

//wire  define
wire    led_out ;

//reg   define
reg     key_in  ;


initial key_in <= 1'b1;
// every 10 ns generate the random number and divided by 2, 
// get 0 -> low-level voltage and  1 -> high-level voltage and assign to key_in.
always #10 key_in <= {$random} % 2; 

//------------- led_inst -------------
led led_inst
(
    .key_in (key_in ),  //input     key_in

    .led_out(led_out)   //output    led_out
);

endmodule
