`timescale 1ns/1ns

module tb_uart_tx();

reg            sys_clk     ;
reg            sys_rst_n   ;
reg    [7:0]   pi_data     ;
reg            pi_falg     ;

wire           tx          ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1;
    end

always#10 sys_clk = ~sys_clk;

initial
    begin
        pi_data <=  8'd0;
        pi_falg <=  1'b0;
        #200
        pi_data <=  8'd0;//0
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd1;//1
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd2;//2
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd3;//3
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd4;//4
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd5;//5
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd6;//6
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
        #(5208*10*20)
        pi_data <=  8'd7;//7
        pi_falg <=  1'b1;
        #20
        pi_falg <=  1'b0;
    end


uart_tx
#(
    .UART_BPS(9600      ),
    .CLK_FREQ(50_000_000)
)
uart_tx_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .pi_data     (pi_data  ),
    .pi_falg     (pi_falg  ),
    
    .tx          (tx       )
);

endmodule