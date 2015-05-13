module sync_gen_top(
  input wire pin_23,
  input wire pin_129,
  output wire pin_198,
  output wire pin_197,
  output wire pin_195, 
  output wire pin_193,
  output wire pin_192, 
  output wire pin_191, 
  output wire pin_189,
  output wire pin_188,
  //leds
  output wire pin_160, 
  output wire pin_152, 
  output wire pin_151,
  output wire pin_150
);

  wire clk_50, rst_n;
  wire hsync, vsync;
  wire [10: 0] h_data;
  wire [9: 0] v_data;
  wire data_en_reg;
  
  wire [1:0] white = ((h_data == 0) || (h_data == 639) || (v_data == 0) || (v_data == 349)) ? 2'b11: 2'b00;
  
  assign clk_50 = pin_23,
  rst_n = pin_129,
  pin_189 = hsync,
  pin_188 = vsync,
  {pin_198, pin_197} = (data_en)? h_data[4:3] | white: 0, //R
  {pin_195, pin_193} = (data_en)? (v_data / 8) | white: 0, //G
  {pin_192, pin_191} = (data_en)? h_data[6:5] | white: 0; //B
 
  assign pin_160 = 1,
  pin_152 = 1,
  pin_151 = 1,
  pin_150 = 1;

  sync_gen sync_gen_inst(
    .rst_n(rst_n), .clk(clk_50),
    .mode(2'b10),
    .h_data_reg(h_data),
    .v_data_reg(v_data),
    .data_en_reg(data_en),
    .hsync_reg(hsync),
    .vsync_reg(vsync)
  );
  
endmodule