module gcd_unit #( parameter W = 32 ) (
  input clk,
  input reset,

  input operands_val,
  input [W-1:0] operands_bits_A,
  input [W-1:0] operands_bits_B,
  output operands_rdy,

  output result_val,
  output [W-1:0] result_bits_data,
  input result_rdy

);

// Define wires
wire B_zero, A_lt_B, B_mux_sel, A_en, B_en;
wire [1:0] A_mux_sel;

// Instantiate gcd_datapath
gcd_datapath #(W) dpath (
  .clk(clk),
  .reset(reset),
  .B_mux_sel(B_mux_sel),
  .A_en(A_en),
  .B_en(B_en),
  .A_mux_sel(A_mux_sel),
  .B_zero(B_zero),
  .A_lt_B(A_lt_B),
  .operands_bits_A(operands_bits_A),
  .operands_bits_B(operands_bits_B),
  .result_bits_data(result_bits_data)
);

// Instantiate gcd_control
gcd_control ctrl (
  .clk(clk),
  .reset(reset),
  .operands_val(operands_val),
  .result_rdy(result_rdy),
  .B_zero(B_zero),
  .A_lt_B(A_lt_B),
  .result_val(result_val),
  .operands_rdy(operands_rdy),
  .A_mux_sel(A_mux_sel),
  .B_mux_sel(B_mux_sel),
  .A_en(A_en),
  .B_en(B_en)
);

endmodule
