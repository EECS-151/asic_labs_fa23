//=========================================================================
// Template for GCD coprocessor
//-------------------------------------------------------------------------
//

module gcd_coprocessor #( parameter W = 32 ) (
  input clk,
  input reset,

  input operands_val,
  input [W-1:0] operands_bits_A,
  input [W-1:0] operands_bits_B,
  output operands_rdy,

  output result_val,
  output [W-1:0] result_bits,
  input result_rdy

);

// You should be able to build this with only structural verilog!

// Define wires
wire [W-1:0] op_bits_A_req_queue;
wire [W-1:0] op_bits_B_req_queue;
wire operands_val_req_queue;
wire operands_rdy_req_queue;

wire [W-1:0] result_bits_data_resp_queue;
wire result_rdy_resp_queue;
wire result_val_resp_queue;

wire [1:0] A_mux_sel;
wire A_en, B_en, A_lt_B, B_zero, B_mux_sel;

// For lab 5, instantiate gcd_arbiter here

// For lab 5, delete gcd_datapath and gcd_control;
//  use gcd_unit instead (you will need 2!)
gcd_datapath #(.W(W)) GCD_DP
( 
	.operands_bits_A(op_bits_A_req_queue),
	.operands_bits_B(op_bits_B_req_queue),
	.result_bits_data(result_bits_data_resp_queue),
	.clk(clk), 
	.reset(reset),
	.B_mux_sel(B_mux_sel), 
	.A_en(A_en), 
	.B_en(B_en),
	.A_mux_sel(A_mux_sel),
	.B_zero(B_zero),
	.A_lt_B(A_lt_B)
);
gcd_control GCD_CONTROL
( 
	.clk(clk), 
	.reset(reset), 
	.operands_val(operands_val_req_queue), 
	.result_rdy(result_rdy_resp_queue),
	.B_zero(B_zero), 
	.A_lt_B(A_lt_B),
	.result_val(result_val_resp_queue), 
	.operands_rdy(operands_rdy_req_queue),
	.A_mux_sel(A_mux_sel),
	.B_mux_sel(B_mux_sel), 
	.A_en(A_en), 
	.B_en(B_en)
);
// Instantiate request FIFO
fifo #(.WIDTH(2*W), .LOGDEPTH(2)) REQ_FIFO (
    .clk(clk),
    .reset(reset),

    .enq_val(operands_val),
    .enq_data({operands_bits_A,operands_bits_B}),
    .enq_rdy(operands_rdy),

    .deq_val(operands_val_req_queue),
    .deq_data({op_bits_A_req_queue,op_bits_B_req_queue}),
    .deq_rdy(operands_rdy_req_queue)
);
// Instantiate response FIFO
fifo #(.WIDTH(W), .LOGDEPTH(2)) RESP_FIFO (
    .clk(clk),
    .reset(reset),

    .enq_val(result_val_resp_queue),
    .enq_data(result_bits_data_resp_queue),
    .enq_rdy(result_rdy_resp_queue),

    .deq_val(result_val),
    .deq_data(result_bits),
    .deq_rdy(result_rdy)
);

endmodule
