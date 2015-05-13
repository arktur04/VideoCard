module sync_gen
  #(parameter
   H_DATA_WIDTH = 11,
   V_DATA_WIDTH = 10,
   MODE_WIDTH = 2
  )
  (
  input wire rst_n, clk,
  input wire [MODE_WIDTH - 1: 0] mode,
  output reg [H_DATA_WIDTH - 1: 0] h_data_reg,
  output reg [V_DATA_WIDTH - 1: 0] v_data_reg,
  output reg data_en_reg,
  output reg hsync_reg,
  output reg vsync_reg
  );
  localparam HSYNC_CNT_WIDTH = 11;
  localparam VSYNC_CNT_WIDTH = 10;
  localparam H_DIV_WIDTH = 2;
  //--------
  localparam MODE_0 = 0; //640 x 480
  localparam MODE_1 = 1; //640 x 400
  localparam MODE_2 = 2; //640 x 350
  localparam MODE_3 = 3; //320 x 200
  //--------
  localparam HSYNC_A = 191; 
  localparam HSYNC_B = 95; 
  localparam HSYNC_C = 1280; 
  localparam HSYNC_D = 33; 
    
  localparam VSYNC_A = 2;
  localparam VSYNC_0_B = 33;
  localparam VSYNC_0_C = 480; 
  localparam VSYNC_0_D = 10;
  
  localparam H_RES_0 = 640;
  localparam V_RES_0 = 480;
  
  localparam HSYNC_PERIOD = HSYNC_A + HSYNC_B + HSYNC_C + HSYNC_D; 
  localparam VSYNC_0_PERIOD = VSYNC_A + VSYNC_0_B + VSYNC_0_C + VSYNC_0_D;
  //---------- 
  localparam V_RES_1 = 400;
  
  localparam VSYNC_2_B = 60;
  localparam VSYNC_2_C = 350;
  localparam VSYNC_2_D = 37;
  localparam V_RES_2 = 350;
  
  localparam H_RES_3 = 320;
  localparam V_RES_3 = 200;
  
  localparam VSYNC_2_PERIOD = VSYNC_A + VSYNC_2_B + VSYNC_2_C + VSYNC_2_D;
  localparam TOP_MARGIN_40 = 40; // top margin for 640 x 400 mode ((480 - 400) / 2), due to MODE_1 and MODE_3 are emulated in MODE_0 actually
  //----------
  wire [VSYNC_CNT_WIDTH - 1: 0] top_margin = (mode == MODE_1 || mode == MODE_3)? TOP_MARGIN_40: 0;
  wire [VSYNC_CNT_WIDTH - 1: 0] vsync_b = (mode == MODE_2)? VSYNC_2_B: VSYNC_0_B;
  wire [VSYNC_CNT_WIDTH - 1: 0] vsync_c = (mode == MODE_2)? VSYNC_2_C: VSYNC_0_C;
  wire [VSYNC_CNT_WIDTH - 1: 0] vsync_period = (mode == MODE_2)? VSYNC_2_PERIOD: VSYNC_0_PERIOD;
  wire [VSYNC_CNT_WIDTH - 1: 0] vres = (mode == MODE_0)? V_RES_0: (mode == MODE_1)? V_RES_1: (mode == MODE_2)? V_RES_2: V_RES_3;
  wire scale2 = mode == MODE_3; 
  //----------
  reg [HSYNC_CNT_WIDTH - 1: 0] hsync_cnt_reg;
  wire [HSYNC_CNT_WIDTH - 1: 0] hsync_cnt_next = hsync_cnt_reg + 1'b1;
  wire [HSYNC_CNT_WIDTH - 1: 0] hres = (mode == MODE_3)? H_RES_3: H_RES_0;
 
  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	  hsync_cnt_reg <= 0;
	 end
	 else
	 begin
	   if(hsync_cnt_next == HSYNC_PERIOD)
	   begin
	     hsync_cnt_reg <= 0;
	   end
	   else
	   begin
	     hsync_cnt_reg <= hsync_cnt_next;
	   end
 	 end
  end
  
  reg [VSYNC_CNT_WIDTH - 1: 0] vsync_cnt_reg;
  wire [VSYNC_CNT_WIDTH - 1: 0] vsync_cnt_next = vsync_cnt_reg + 1'b1;
 
  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	  vsync_cnt_reg <= 0;
	end
	else
	begin
	  if(hsync_cnt_next == HSYNC_PERIOD)
	  begin
	    if(vsync_cnt_next == vsync_period)
	    begin
	      vsync_cnt_reg <= 0;
	    end
	    else
	    begin
	      vsync_cnt_reg <= vsync_cnt_next;
	    end
	  end 
 	end
  end

  always@* hsync_reg = hsync_cnt_reg >= HSYNC_A;
  always@* vsync_reg = vsync_cnt_reg >= VSYNC_A;
  
  reg h_data_start_reg;
  
  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	   data_en_reg <= 0;
		h_data_start_reg <= 0;
	 end
	 else
	 begin
      data_en_reg <= (hsync_cnt_reg >= (HSYNC_A + HSYNC_B)) && (hsync_cnt_reg < (HSYNC_A + HSYNC_B + HSYNC_C)) && (vsync_cnt_reg >= (VSYNC_A + vsync_b + top_margin)) && (vsync_cnt_reg < (VSYNC_A + vsync_b + vsync_c - top_margin));
		h_data_start_reg <= hsync_cnt_reg == HSYNC_A + HSYNC_B - 1;
	 end
  end	
  
  //wire h_data_start = hsync_cnt_reg == HSYNC_A + HSYNC_B,
  wire v_data_start = vsync_cnt_reg == VSYNC_A + vsync_b + top_margin;

  wire [H_DATA_WIDTH - 1: 0] h_data_next = h_data_reg + 1'b1;
  reg [H_DIV_WIDTH - 1: 0] h_divider_reg;
  wire [H_DIV_WIDTH: 0] h_divider_next = h_divider_reg + 1'b1,
  h_divider_max = (scale2)? 3'b100: 3'b010; // 
  
  //horizontal prescaler
  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	   h_divider_reg <= 0;
	 end
	else
	begin
	    if(h_data_start_reg || h_divider_next == h_divider_max)
		 begin
		   h_divider_reg <= 0;
		 end
		 else
		 begin
	      h_divider_reg <= h_divider_next; //
	    end
	    if(h_data_start_reg)
		 begin
		   h_divider_reg <= 0;
	    end
	end	 
  end
	
  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	   h_data_reg <= 0;
	 end
	else
	begin
	  if(h_data_start_reg)
	  begin
		 h_data_reg <= 0;
	  end
	  else
	  begin
	    if(h_divider_next == h_divider_max && h_data_next <= hres)
		 begin
         h_data_reg <= h_data_next;
		 end
	  end
	end
  end
	
  wire [V_DATA_WIDTH - 1: 0] v_data_next = v_data_reg + 1'b1;
  reg v_divider_reg;

  //vertical prescaler
  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	  v_divider_reg <= 0;
	 end
	 else
	 begin	   
	     if(v_data_start)
		  begin
			 v_divider_reg <= 0;
		  end
        else
        if(h_data_start_reg)
        begin		  
			 if(scale2)
	       begin
	         v_divider_reg <= ~v_divider_reg;
	       end
	       else
	       begin
	         v_divider_reg <= 0;
	       end
	     end
    end
  end

  always@(negedge rst_n, posedge clk)
  begin 
    if(!rst_n)
    begin
	   v_data_reg <= 0;
	 end
	 else
	 begin	   
	     if(v_data_start)
		  begin
		    v_data_reg <= 0;
		  end
        else
        if(h_data_start_reg && (!scale2 || scale2 && v_divider_reg) && v_data_next <= vres)  
		  begin
          v_data_reg <= v_data_next;
		  end
    end
  end
  
endmodule
  