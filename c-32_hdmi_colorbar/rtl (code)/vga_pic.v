module  vga_pic
(
    input       wire            vga_clk     ,
    input       wire            sys_rst_n   ,
    input       wire   [9:0]    pix_x       ,
    input       wire   [9:0]    pix_y       ,
    
    output      reg    [15:0]   pix_data
);

parameter   H_VALID =   10'd640 ,
            V_VALID =   10'd480 ;

parameter   RED     =   16'hF800,
            ORANGE  =   16'hFC00,
            YELLOW  =   16'hFFE0,
            GREEN   =   16'h07E0,
            CYAN    =   16'h07FF,
            BLUE    =   16'h001F,
            PURPPLE =   16'hF81F,
            BLACK   =   16'h0000,
            WHITE   =   16'hFFFF,
            GRAY    =   16'hD69A;

always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pix_data <= BLACK;
    else
        case (pix_x)
        10'd0   :   pix_data <= RED;
        10'd63  :   pix_data <= ORANGE  ;
        10'd127 :   pix_data <= YELLOW  ;
        10'd191 :   pix_data <= GREEN   ;
        10'd255 :   pix_data <= CYAN    ;
        10'd319 :   pix_data <= BLUE    ;
        10'd383 :   pix_data <= PURPPLE ;
        10'd447 :   pix_data <= BLACK   ;
        10'd511 :   pix_data <= WHITE   ;
        10'd575 :   pix_data <= GRAY    ;
        10'h3ff :   pix_data <= BLACK   ;
        default :   pix_data <= pix_data   ;
        endcase
    
    
    

endmodule