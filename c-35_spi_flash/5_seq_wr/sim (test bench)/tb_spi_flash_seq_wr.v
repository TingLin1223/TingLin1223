`timescale  1ns/1ns

module  tb_spi_flash_seq_wr();

reg     sys_clk;
reg     sys_rst_n;
reg     rx;
reg     [7:0]   data_mem[99:0];

wire    sck;
wire    cs_n;
wire    mosi;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
    end

initial
    begin
        rx <= 1'b1;
        #300
        rx_byte();
    end

initial
    $readmemh("D:/FPGA/46_spi_flash_seq_wr/sim/data_test.txt",data_mem);

task    rx_byte();
    integer     j;
        for(j=0; j<100; j=j+1)
            rx_bit(data_mem[j]);
endtask

task rx_bit
(
input  [7:0] data
);
    integer     i;

for(i=0; i<10; i=i+1)
    begin
        case(i)
            0: rx   <= 1'b0;
            1: rx   <= data[0];
            2: rx   <= data[1];
            3: rx   <= data[2];
            4: rx   <= data[3];
            5: rx   <= data[4];
            6: rx   <= data[5];
            7: rx   <= data[6];
            8: rx   <= data[7];
            9: rx   <= 1'b1;
        endcase
        #(52*20);
    end
endtask


always #10 sys_clk = ~ sys_clk;

spi_flash_seq_wr    spi_flash_seq_wr_inst
(
    .sys_clk     (sys_clk  ),
    .sys_rst_n   (sys_rst_n),
    .rx          (rx       ),
    
    .sck         (sck      ),
    .cs_n        (cs_n     ),
    .mosi        (mosi     )

);

defparam memory.mem_access.initfile = "initmemory.txt";
defparam spi_flash_seq_wr_inst.CLK_FREQ = 50_000_0;

m25p16 memory 
(
    .c          (sck    ), 
    .data_in    (mosi   ), 
    .s          (cs_n   ), 
    .w          (1'b1   ), 
    .hold       (1'b1   ), 
    .data_out   (       )
);


endmodule