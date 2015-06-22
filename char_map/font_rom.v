module font_rom
#(
  parameter FONT_NUM_WIDTH = 2,
  LINE_NUM_WIDTH = 4,
  CHAR_NUM_WIDTH = 8,
  DATA_WIDTH = 8
)
(
  input wire clk,
  input wire [FONT_NUM_WIDTH - 1: 0] font_num,
  input wire [LINE_NUM_WIDTH - 1: 0] line_num,
  input wire [CHAR_NUM_WIDTH - 1: 0] char_num,
  output reg [DATA_WIDTH - 1: 0] data_reg
);

  localparam LINE_NUM_8BIT_WIDTH = 3;
  
  wire [LINE_NUM_8BIT_WIDTH + CHAR_NUM_WIDTH - 1: 0] addr_8;
  wire [LINE_NUM_WIDTH + CHAR_NUM_WIDTH - 1: 0] addr_14, addr_16;
  reg [DATA_WIDTH - 1: 0] out8, out14, out16;
  
  assign addr_8 = (font_num == 0)? {char_num, line_num[LINE_NUM_8BIT_WIDTH - 1: 0]}: 0;
  
  always@* data_reg = (font_num == 0)? out8:
    (font_num == 1)? out14:
	(font_num == 2)? out16: 0;
	
  always@(posedge clk)
  begin
    case(addr_8)
      `include "fonts/008.inc"
    endcase
  end

  assign addr_14 = (font_num == 1)? {char_num, line_num}: 0;
	
  always@(posedge clk)
  begin
    case(addr_14)
      `include "fonts/014.inc"
    endcase
  end
  
  assign addr_16 = (font_num == 2)? {char_num, line_num}: 0;
  
  always@(posedge clk)
  begin
    case(addr_16)
      `include "fonts/016.inc"
    endcase
  end

endmodule
