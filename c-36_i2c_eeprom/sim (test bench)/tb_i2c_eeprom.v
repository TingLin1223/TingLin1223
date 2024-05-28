`timescale 1ns/1ns

module  tb_i2c_eeprom();

reg            sys_clk   ;
reg            sys_rst_n ;
reg            key_wr    ;
reg            key_rd    ;


wire            ds      ;
wire            oe      ;
wire            shcp    ;
wire            stcp    ;
wire            i2c_scl ;
wire            i2c_sda ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        key_wr <= 1'b1;
        key_rd <= 1'b1;
        #200
        sys_rst_n <= 1'b1;
        #1000
        key_wr <= 1'b0;
        key_rd <= 1'b1;
        #400
        key_wr <= 1'b1;
        key_rd <= 1'b1;
        #55_000_000
        key_wr <= 1'b1;
        key_rd <= 1'b0;
        #400
        key_wr <= 1'b1;
        key_rd <= 1'b1;
    end


always #10 sys_clk = ~sys_clk;

defparam i2c_eeprom_inst.CNT_MAX = 5;
defparam i2c_eeprom_inst.i2c_rw_data_inst.CNT_WAIT_MAX = 1000;

i2c_eeprom  i2c_eeprom_inst
(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .key_wr      (key_wr      ),
    .key_rd      (key_rd      ),

    .ds          (ds          ),
    .oe          (oe          ),
    .shcp        (shcp        ),
    .stcp        (stcp        ),
    .i2c_scl     (i2c_scl     ),
    .i2c_sda     (i2c_sda     )
);

M24LC64     M24LC64_inst
(
    .A0         (1'b1), 
    .A1         (1'b1), 
    .A2         (1'b0), 
    .WP         (1'b0), 
    .SDA        (i2c_sda), 
    .SCL        (i2c_scl), 
    .RESET      (~sys_rst_n)
);


endmodule