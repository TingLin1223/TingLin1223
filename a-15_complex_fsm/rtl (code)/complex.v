module complex_fsm
(
    input       wire    sys_clk,
    input       wire    sys_rst_n,
    input       wire    pi_half,
    input       wire    pi_one,
    
    output      reg     po_cola,
    output      reg     po_money
);

wire    [1:0]   pi_money;
reg     [4:0]   STATE;

parameter   IDLE    = 5'b00001;
parameter   HALF    = 5'b00010;
parameter   ONE     = 5'b00100;
parameter   ONE_HALF= 5'b01000;
parameter   TWO     = 5'b10000;


assign pi_money = {pi_one,pi_half};
always @ (posedge sys_clk or negedge sys_rst_n)
    if( sys_rst_n == 1'b0)
        STATE <= IDLE;
    else case (STATE)
        IDLE:       if (pi_money == 2'b01)
                        STATE <= HALF;
                    else if (pi_money == 2'b10)
                        STATE <= ONE;
                    else
                        STATE <= IDLE;
        HALF:       if (pi_money == 2'b01)
                        STATE <= ONE;
                    else if (pi_money == 2'b10)
                        STATE <= ONE_HALF;
                    else
                        STATE <= HALF;
        ONE:            if (pi_money == 2'b01)
                        STATE <= ONE_HALF;
                    else if (pi_money == 2'b10)
                        STATE <= TWO;
                    else
                        STATE <= ONE;
        ONE_HALF:   if (pi_money == 2'b01)
                        STATE <= TWO;
                    else if (pi_money == 2'b10)
                        STATE <= IDLE;
                    else
                        STATE <= ONE_HALF;
        TWO:        if (pi_money == 2'b01)
                        STATE <= IDLE;
                    else if (pi_money == 2'b10)
                        STATE <= IDLE;
                    else
                        STATE <= TWO;
        default STATE <= IDLE;
    endcase

always @ (posedge sys_clk or negedge sys_rst_n)
    if (sys_rst_n == 1'b0)
        begin
            po_cola     <= 1'b0;
            po_money    <= 1'b0;
        end
    else if ((STATE == ONE_HALF) && (pi_money == 2'b10) // coke out condition
            ||(STATE == TWO) && (pi_money == 2'b01))
            begin
                po_cola     <= 1'b1;
                po_money    <= 1'b0;
            end
    else if ((STATE == TWO)&&(pi_money == 2'b10)) // coke & change condition
            begin
                po_cola <= 1'b1;
                po_money<= 1'b1;
            end
    else
            begin
            po_cola     <= 1'b0;
            po_money    <= 1'b0;
            end
endmodule