module fifo
(
    input           sys_clk     ,
    input   [7:0]   data        ,
    input           rdreq       ,
    input           wrreq       ,
    
    output          empyt       ,
    output          full        ,
    output  [7:0]   q           ,
    output  [7:0]   usedw       
);

scfifo_256x8    scfifo_256x8_inst (
    .clock  (sys_clk    ),
    .data   (data   ),
    .rdreq  (rdreq  ),
    .wrreq  (wrreq  ),
    .empty  (empyt  ),
    .full   (full   ),
    .q      (q      ),
    .usedw  (usedw  )
    );


endmodule