module  vga_pic
(
    input       wire            sys_clk     ,
    input       wire            sys_rst_n   ,
    input       wire   [9:0]    pix_x       ,
    input       wire   [9:0]    pix_y       ,
    
    output      wire   [15:0]   pix_data
);

parameter   H_VALID =   10'd640 ,   //vertical valid datas
            V_VALID =   10'd480 ;   //horizontal valid data

parameter   H_PIC   =   10'd100,
            V_PIC   =   10'd100,
            ADR_MAX =   14'd9999;

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
            
wire            rd_en;
wire    [15:0]  pic_data;

reg     [15:0]  data_pix;
reg             pic_valid;
reg     [13:0]  rom_addr;

assign pix_data = (pic_valid == 1'b1) ? pic_data : data_pix;

// range -1'b1 for ahead 1 clock to catch rom data.
assign rd_en = ((pix_x >=(((H_VALID - H_PIC)/2) - 1'b1)) && 
                (pix_x <((H_VALID - H_PIC)/2 + H_PIC) - 1'b1) &&
                (pix_y >=((V_VALID - V_PIC)/2)) && 
                (pix_y <(V_VALID - V_PIC)/2 + H_PIC));

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pic_valid <= 1'b0;
    else
        pic_valid <= rd_en;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rom_addr <= 14'b0;
    else if(rom_addr == ADR_MAX)
        rom_addr <= 14'b0;
    else if(rd_en == 1'b1)
        rom_addr <= rom_addr + 1'b1;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_pix <= BLACK;
    else
        case (pix_x)
        10'd0   :   data_pix <= RED;
        10'd63  :   data_pix <= ORANGE  ;
        10'd127 :   data_pix <= YELLOW  ;
        10'd191 :   data_pix <= GREEN   ;
        10'd255 :   data_pix <= CYAN    ;
        10'd319 :   data_pix <= BLUE    ;
        10'd383 :   data_pix <= PURPPLE ;
        10'd447 :   data_pix <= BLACK   ;
        10'd511 :   data_pix <= WHITE   ;
        10'd575 :   data_pix <= GRAY    ;
        10'h3ff :   data_pix <= BLACK   ;
        default :   data_pix <= data_pix   ;
        endcase
    
rom_pic rom_pic_inst 
(
    .address(rom_addr),
    .clock  (sys_clk),
    .rden   (rd_en),
    .q      (pic_data)
    );


endmodule