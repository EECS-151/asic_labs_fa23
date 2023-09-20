//=========================================================================
// RTL Model of GCD Unit
//-------------------------------------------------------------------------
//

// W is a parameter specifying the bit width of the module
module gcd#( parameter W = 16 ) 
( 
	input pll_ref_clk,
	input pll_bypass,
	input pll_fb_mode,
	input pll_fb_clk,
	input reset,
	input scan_in,
	input scan_enable,
	output scan_out,
	input operands_val,
	output operands_rdy,
	input result_rdy,
	output result_val
);

// Synchronize reset / valid
reg top_reset_sync0;
reg top_reset_sync1;

reg top_operands_val_sync0;
reg top_operands_val_sync1;

wire clk;

// At this top level, hook together the 
// datapath part and control part only

// In verilog, multi-bit wires will only be
// a single bit wide if they are not declared
wire B_mux_sel, A_en, B_en, B_zero, A_lt_B;
wire [1:0] A_mux_sel;

wire [W-1:0] result_bits_data;
wire [W-1:0] operands_bits_A;
wire [W-1:0] operands_bits_B;

gcd_scan#(W) gcd_scan(
  .scan_in(scan_in),
  .scan_clock(pll_ref_clk),
  .scan_out(scan_out),
  .scan_enable(scan_enable),
  .result_bits_data(result_bits_data),
  .operands_bits_A(operands_bits_A),
  .operands_bits_B(operands_bits_B)
);

// Notice W parameter is sent to the datapath
// module as well
gcd_datapath#(W) GCDdpath0(

	// external
	.operands_bits_A(operands_bits_A),
	.operands_bits_B(operands_bits_B),
	.result_bits_data(result_bits_data),

	// system
	.clk(clk), 
	.reset(top_reset_sync1),

	// internal (between ctrl and dpath)
	.A_mux_sel(A_mux_sel[1:0]), 
	.A_en(A_en), 
	.B_en(B_en),
	.B_mux_sel(B_mux_sel),
	.B_zero(B_zero),
	.A_lt_B(A_lt_B)
);

gcd_control GCDctrl0(

	// external
	.operands_rdy(operands_rdy),
	.operands_val(top_operands_val_sync1), 
	.result_rdy(result_rdy),
	.result_val(result_val), 

	// system
	.clk(clk), 
	.reset(top_reset_sync1), 

	// internal (between ctrl and dpath)
	.B_zero(B_zero), 
	.A_lt_B(A_lt_B),
	.A_mux_sel(A_mux_sel[1:0]), 
	.A_en(A_en), 
	.B_en(B_en),
	.B_mux_sel(B_mux_sel)

);

PLL pll (
  .REF_CLK(pll_ref_clk),
  .FB_CLK(pll_fb_clk),
  .FB_MODE(pll_fb_mode),
  .PLL_BYPASS(pll_bypass),

  .CLK_4X(clk),
  .CLK_2X(),
  .CLK_1X()
  );


  // synchronize signals to the fast clock
  always @(posedge clk)
  begin
    top_reset_sync0 <= reset;
    top_reset_sync1 <= top_reset_sync0;
    top_operands_val_sync0 <= operands_val;
    top_operands_val_sync1 <= top_operands_val_sync0;
  end

endmodule
