`timescale 1ns/1ps
module font_rom_tb();

reg clk_reg;
reg [1: 0] font_num_reg;
reg [3: 0] line_num_reg;
reg [7: 0] char_num_reg;
wire [7:0] data;

always@* #5 clk_reg <= ~clk_reg;

integer char_n, line_n;

initial
begin
  clk_reg = 0;
  font_num_reg = 0;
  for(char_n = 0; char_n < 256; char_n = char_n + 1)
  begin
    char_num_reg = char_n;
    for(line_n = 0; line_n < 8; line_n = line_n + 1)
	begin
      @(posedge clk_reg) line_num_reg = line_n;
	end
  end
  //---
  font_num_reg = 1;
  for(char_n = 0; char_n < 256; char_n = char_n + 1)
  begin
    char_num_reg = char_n;
    for(line_n = 0; line_n < 14; line_n = line_n + 1)
	begin
      @(posedge clk_reg) line_num_reg = line_n;
	end
  end
  //---
  font_num_reg = 2;
  for(char_n = 0; char_n < 256; char_n = char_n + 1)
  begin
    char_num_reg = char_n;
    for(line_n = 0; line_n < 16; line_n = line_n + 1)
	begin
      @(posedge clk_reg) line_num_reg = line_n;
	end
  end
end

font_rom font_rom_i
(
  .clk(clk_reg),
  .font_num(font_num_reg),
  .line_num(line_num_reg),
  .char_num(char_num_reg),
  .data_reg(data)
);

endmodule
