`timescale  1ns/1ns

module  tb_rs232();

reg             sys_clk;
reg             sys_rst_n;
reg             rx;
wire            tx;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n   <= 1'b0;
        rx          <= 1'b1;
        #20
        sys_rst_n   <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;

initial
    begin
        #200
        rx_byte();
    end

task    rx_byte(); //create task function, make rx_bit input data from 0 to 7, and task rx_bit will implement 7 times. (0 to 7)
    integer j;
        for(j=0; j<8; j=j+1)
            rx_bit(j);
endtask

task    rx_bit//create rx_bit task, input data from task rx_byte
(
    input   [7:0]   data
);

    integer i;

for(i=0; i<10; i = i+1)// implement from i = 0 to i =9, 10 times, each time delay 5208 * 20 ns.
    begin
    case(i)
        0:rx     <=  1'b0   ;//simulate start.
        1:rx     <=  data[0];//data[0]
        2:rx     <=  data[1];
        3:rx     <=  data[2];
        4:rx     <=  data[3];
        5:rx     <=  data[4];
        6:rx     <=  data[5];
        7:rx     <=  data[6];
        8:rx     <=  data[7];
        9:rx     <=  1'b1   ;//stop
    endcase
    #(5208*20); // i++ delay time = 5208 cnt(baurd rate) * 20 ns (sys_clk)
    end
endtask



rs232   rs232_inst
(
    .sys_clk    (sys_clk  ),
    .sys_rst_n  (sys_rst_n),
    .rx         (rx       ),
                 
    .tx         (tx       )

);

endmodule