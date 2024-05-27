module  vga_pic
(
    input       wire            sys_clk     ,
    input       wire            sys_rst_n   ,
    input       wire   [9:0]    pix_x       ,
    input       wire   [9:0]    pix_y       ,
    input       wire            clk_50MHz   ,//same clock frequency as rs232 rx module
    input       wire   [7:0]    pi_data     ,
    input       wire            pi_flag     ,
    
    
    output      wire   [7:0]    pix_data     
);

parameter   H_VALID =   10'd640 ,
            V_VALID =   10'd480 ;

parameter   H_PIC   =   10'd98,//after sobel process, row and column will minus 2. 100x100 => 98x98, due to 3 adjacent rows and columns added
            V_PIC   =   10'd98,
            ADR_MAX =   14'd9603;// 98*98 - 1
            
parameter   X_MAX   =   10'd639,
            Y_MAX   =   10'd479;


parameter   RED     =   8'b111_000_00,
            GREEN   =   8'b000_111_00,
            BLUE    =   8'b000_000_11,
            WHITE   =   8'b111_111_11,
            BLACK   =   8'b000_000_00;

wire            rd_en;
wire    [7:0]   pic_data;

reg     [13:0]   wr_addr;//
reg     [7:0]   data_pix;
reg             pic_valid;
reg     [13:0]  rd_addr;//

reg     [9:0]   cnt_x;
reg     [9:0]   cnt_y;
reg             flag_x;
reg             flag_y;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_x <= 10'b0;
    else if(pix_y == Y_MAX && pix_x == X_MAX && flag_x == 1'b0)
        cnt_x <= cnt_x + 1'b1;
    else if(pix_y == Y_MAX && pix_x == X_MAX && flag_x == 1'b1)
        cnt_x <= cnt_x - 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_y <= 10'b0;
    else if(pix_y == Y_MAX && pix_x == X_MAX && flag_y == 1'b0)
        cnt_y <= cnt_y + 1'b1;
    else if(pix_y == Y_MAX && pix_x == X_MAX && flag_y == 1'b1)
        cnt_y <= cnt_y - 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_x <= 1'b1;
    else if(((cnt_x == 10'd0)||(cnt_x == H_VALID - H_PIC)) && pix_y == Y_MAX && (pix_x == X_MAX - 1'b1))
        flag_x <= ~flag_x;
    
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        flag_y <= 1'b1;
    else if(((cnt_y == 10'd0)||(cnt_y == V_VALID - V_PIC)) && pix_y == Y_MAX && (pix_x == X_MAX - 1'b1))
        flag_y <= ~flag_y;

assign rd_en = ((pix_x >= cnt_x && pix_x < cnt_x + H_PIC) 
                && (pix_y >= cnt_y && pix_y < cnt_y + V_PIC));
                
assign pix_data = (pic_valid == 1'b1) ? pic_data : data_pix;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pic_valid <= 1'b0;
    else
        pic_valid <= rd_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_addr <= 14'b0;
    else if(rd_addr == ADR_MAX)
        rd_addr <= 14'b0;
    else if(rd_en == 1'b1)
        rd_addr <= rd_addr + 1'b1;

always@(posedge clk_50MHz or negedge sys_rst_n) // ram needs wr_address & wr_en
    if(sys_rst_n == 1'b0)
        wr_addr <= 14'd0;
    else if(wr_addr == ADR_MAX && pi_flag == 1'b1)
        wr_addr <= 14'd0;
    else if(pi_flag == 1'b1)
        wr_addr <= wr_addr + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_pix <= BLACK;
    else
        case (pix_x)
        10'd0   :   data_pix <= RED     ;
        10'd63  :   data_pix <= GREEN   ;
        10'd127 :   data_pix <= BLUE    ;
        10'd191 :   data_pix <= WHITE   ;
        10'd255 :   data_pix <= BLACK   ;
        10'd319 :   data_pix <= RED     ;
        10'd383 :   data_pix <= GREEN   ;
        10'd447 :   data_pix <= BLUE    ;
        10'd511 :   data_pix <= WHITE   ;
        10'd575 :   data_pix <= BLACK   ;
        10'h3ff :   data_pix <= BLACK   ;
        default :   data_pix <= data_pix   ;
        endcase
    
ram_pic ram_pic_inst 
(
    .data       ( pi_data       ),
    .inclock    ( clk_50MHz     ),//same clock frequency as rs232 rx module
    .outclock   ( sys_clk       ),//data out clock should as same as vga clk
    .rdaddress  ( rd_addr       ),
    .wraddress  ( wr_addr       ),
    .wren       ( pi_flag       ),
    .q          ( pic_data      )
    );




endmodule