`timescale 1ns/1ns

module sync_gen_tb();
  
  reg clk, rst_n;
  always #10 clk = ~clk;
  
  initial
  begin
    clk = 0;
    rst_n = 1'b0;
	#110 rst_n = 1'b1;
  end

  localparam H_DATA_WIDTH = 11,
   V_DATA_WIDTH = 10;
	
  wire [H_DATA_WIDTH - 1: 0] h_data;
  wire [V_DATA_WIDTH - 1: 0] v_data;
  
  sync_gen sync_gen_inst(
    .rst_n(rst_n), .clk(clk),
    .mode(2'b11),
    .h_data_reg(h_data),
    .v_data_reg(v_data),
    .data_en_reg(data_en),
    .hsync_reg(hsync),
    .vsync_reg(vsync)
  );
  
endmodule