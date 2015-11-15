//-----------------------------------------------
//this module has been rewritten for the DE2-115
//-----------------------------------------------
module sync_gen_top(
  input wire pin_y2,    // clock_50
  input wire pin_m23,   //rst_n (button0)
  output wire pin_e12,   //R0
  output wire pin_e11,  //R1
  output wire pin_d10,  //R2
  output wire pin_f12,  //R3
  output wire pin_g10,  //R4
  output wire pin_j12,  //R5
  output wire pin_h8,   //R6
  output wire pin_h10,  //R7
  output wire pin_g8,   //G0
  output wire pin_g11,  //G1
  output wire pin_f8,   //G2
  output wire pin_h12,  //G3
  output wire pin_c8,   //G4
  output wire pin_b8,   //G5
  output wire pin_f10,  //G6
  output wire pin_c9,   //G7
  output wire pin_b10,  //B0
  output wire pin_a10,  //B1
  output wire pin_c11,  //B2
  output wire pin_b11,  //B3
  output wire pin_a11,  //B4
  output wire pin_c12,  //B5
  output wire pin_d11,  //B6
  output wire pin_d12,  //B7
  output wire pin_f11,  //VGA_BLANK_N
  output wire pin_c10,  //VGA_SYNC_N
  output wire pin_a12,  //VGA_CLK
  output wire pin_g13,  //VGA_HS
  output wire pin_c13  //VGA_VS
);

  wire clk_50, rst_n;
  wire hsync, vsync;
  wire [10: 0] h_data;
  wire [9: 0] v_data;
  wire data_en;
  
  wire [6:0] white = ((h_data == 0) || (h_data == 639) || (v_data == 0) || (v_data == 479)) ? 7'h7f: 7'h00;

  wire [5:0] color = (h_data >> 3) + (v_data >> 4) * 80;
  
  assign clk_50 = pin_y2,
  rst_n = pin_m23,
  pin_g13 = hsync,
  pin_c13 = vsync,
  pin_f11 = data_en,
  pin_c10 = 1'b1, //data_en,
  pin_a12 = ~clk_50,
  {pin_h10, pin_h8, pin_j12, pin_g10, pin_f12, pin_d10, pin_e11} = color[5:4] * 85  | white, //R
  pin_e12 = 0, //R
  {pin_c9, pin_f10, pin_b8, pin_c8, pin_h12, pin_f8, pin_g11} = color[3:2] * 85 | white, //G
  pin_g8 = 0, //G
  {pin_d12, pin_d11, pin_c12, pin_a11, pin_b11, pin_c11, pin_a10} = color[1:0] * 85 | white, //B
  pin_b10 = 0;

  sync_gen sync_gen_inst(
    .rst_n(rst_n), .clk(clk_50),
    .mode(2'b00),
    .h_data_reg(h_data),
    .v_data_reg(v_data),
    .data_en_reg(data_en),
    .hsync_reg(hsync),
    .vsync_reg(vsync)
  );
  
endmodule
