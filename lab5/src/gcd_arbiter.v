module gcd_arbiter #(parameter W = 32) (
  input clk,
  input reset,

  // this will be connected to the input FIFO
  input operands_val,
  input [W-1:0] operands_bits_A,
  input [W-1:0] operands_bits_B,
  output operands_rdy,

  output request0_val,
  output [W-1:0] request0_operands_bits_A,
  output [W-1:0] request0_operands_bits_B,
  input request0_rdy,

  output request1_val,
  output [W-1:0] request1_operands_bits_A,
  output [W-1:0] request1_operands_bits_B,
  input request1_rdy,

  // This will be connected to the output FIFO
  output result_val,
  output [W-1:0] result_bits_data,
  input result_rdy,

  input response0_val,
  input [W-1:0] response0_result_bits_data,
  output response0_rdy,

  input response1_val,
  input [W-1:0] response1_result_bits_data,
  output response1_rdy
);

// Keep track of which GCD unit you will enqueue to next

// Keep track of which GCD unit you will dequeue from next

// Define our "fire" wires
wire operands_fire, request0_fire, request1_fire, result_fire, response0_fire, response1_fire;

// Wires and assignments go here
// Hint: Most of your code will be assignments

// Sequential logic goes here
// Be sure to implement reset! Look at fifo.v for an example


endmodule
