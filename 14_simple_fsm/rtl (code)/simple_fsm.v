module simple_fsm
(
        input       wire        sys_clk,
        input       wire        sys_rst_n,
        input       wire        pi_money,
        
        output      reg         out_cola
);

parameter       IDLE = 3'b001; // one-hot encoding
parameter       ONE  = 3'b010; // one-hot encoding
parameter       TWO  = 3'b100; // one-hot encoding

reg     [2:0]   STATE; // because we using the one-hot encoding, so how many states needs how many bit width.

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        STATE <= IDLE;
    else case (STATE) // using STATE to be case condition, if state condition is met durin each state, the state change to next, if not, keeping state.
        IDLE:   if (pi_money == 1'b1)
                    STATE <= ONE;
                else
                    STATE <= IDLE;
        ONE:    if (pi_money == 1'b1)
                    STATE <= TWO;
                else
                    STATE <= ONE;
        TWO:    if (pi_money == 1'b1)
                    STATE <= IDLE;
                else
                    STATE <= TWO;
    default STATE <= IDLE;
    endcase
    
always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        out_cola <= 1'b0;
    else if ((STATE == TWO) && (pi_money == 1'b1))// when 2 coins are inserted already then inserting 1 coin to machine, coke will be out.
        out_cola <= 1'b1;
    else
        out_cola <= 1'b0;
endmodule