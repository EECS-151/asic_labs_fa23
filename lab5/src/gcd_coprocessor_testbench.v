`timescale 1 ns / 100 ps

module gcd_coprocessor_testbench;

  //--------------------------------------------------------------------
  // Define test vectors
  //--------------------------------------------------------------------
  localparam num_tests = 16;
  wire [15:0] test_A [num_tests-1:0];
  wire [15:0] test_B [num_tests-1:0];
  wire [15:0] test_results [num_tests-1:0];

  assign test_A[0] = 16'd27  ; assign test_B[0] = 16'd15  ; assign test_results[0] = 16'd3 ;
  assign test_A[1] = 16'd21  ; assign test_B[1] = 16'd49  ; assign test_results[1] = 16'd7 ;
  assign test_A[2] = 16'd25  ; assign test_B[2] = 16'd30  ; assign test_results[2] = 16'd5 ;
  assign test_A[3] = 16'd19  ; assign test_B[3] = 16'd27  ; assign test_results[3] = 16'd1 ;
  assign test_A[4] = 16'd40  ; assign test_B[4] = 16'd40  ; assign test_results[4] = 16'd40;
  assign test_A[5] = 16'd250 ; assign test_B[5] = 16'd190 ; assign test_results[5] = 16'd10;
  assign test_A[6] = 16'd5   ; assign test_B[6] = 16'd250 ; assign test_results[6] = 16'd5 ;
  assign test_A[7] = 16'd0   ; assign test_B[7] = 16'd0   ; assign test_results[7] = 16'd0 ;

  assign test_A[8] = 16'd1    ; assign test_B[8] = 16'd9     ; assign test_results[8] = 16'd1   ;
  assign test_A[9] = 16'd2    ; assign test_B[9] = 16'd1     ; assign test_results[9] = 16'd1   ;
  assign test_A[10] = 16'd96  ; assign test_B[10] = 16'd4096 ; assign test_results[10] = 16'd32 ;
  assign test_A[11] = 16'd19  ; assign test_B[11] = 16'd1    ; assign test_results[11] = 16'd1  ;
  assign test_A[12] = 16'd103 ; assign test_B[12] = 16'd199  ; assign test_results[12] = 16'd1  ;
  assign test_A[13] = 16'd250 ; assign test_B[13] = 16'd370  ; assign test_results[13] = 16'd10 ;
  assign test_A[14] = 16'd15  ; assign test_B[14] = 16'd250  ; assign test_results[14] = 16'd5  ;
  assign test_A[15] = 16'd6993; assign test_B[15] = 16'd999  ; assign test_results[15] = 16'd999;

  // cycle limit for performance test
  wire [15:0] cycle_limit = 16'd225;
  reg  [15:0] cycle_count = 16'd0;

  //--------------------------------------------------------------------
  // Setup a clock
  //--------------------------------------------------------------------
  reg clk = 0;
  always #(`CLOCK_PERIOD/2) clk = ~clk;
  // always #20 clk = ~clk; // 50Mhz

  reg done = 0;

  //--------------------------------------------------------------------
  // Instantiate DUT and wire/reg the inputs and outputs
  //--------------------------------------------------------------------

  reg reset;
  reg operands_val;
  reg [15:0] operands_bits_A;
  reg [15:0] operands_bits_B;
  wire operands_rdy;
  wire result_val;
  wire [15:0] result_bits;
  reg result_rdy;

  integer i = 0;

  gcd_coprocessor #(16) dut (
    .clk(clk),
    .reset(reset),
    .operands_val(operands_val),
    .operands_bits_A(operands_bits_A),
    .operands_bits_B(operands_bits_B),
    .operands_rdy(operands_rdy),
    .result_val(result_val),
    .result_bits(result_bits),
    .result_rdy(result_rdy)
  );

  //--------------------------------------------------------------------
  // Define a sequential interface that steps through each test in
  // the src/sink array every time a valid ready/val handshake occurs
  //--------------------------------------------------------------------

  // Apply stimulus
  initial begin
    $vcdpluson;
    // Initial values
    reset = 0;
    operands_val = 0;
    operands_bits_A = 16'd0;
    operands_bits_B = 16'd0;
    result_rdy = 1;

    // Strobe reset
    repeat (5) @(negedge clk) reset = 1;
    @(negedge clk) reset = 0;
    @(negedge clk);

    for (i = 0; i < num_tests; i = i + 1) begin
      // wait if operands not ready
      while (~operands_rdy) begin
        @(negedge clk) reset = 0;
      end
      operands_val = 1;
      operands_bits_A = test_A[i];
      operands_bits_B = test_B[i];
      @(negedge clk);
      operands_val = 0;
      @(negedge clk);
    end

  end

  always @(posedge done) begin
    if (cycle_count <= cycle_limit) begin
      $display(" [ passed ] Test ( Cycle ), [ %d <= %d ] (decimal)",cycle_count,cycle_limit);
    end else begin
      $display(" [ failed ] Test ( Cycle ), [ %d <= %d ] (decimal)",cycle_count,cycle_limit);
    end

    $vcdplusoff;
    $finish;
  end

  reg [15:0] test_idx = 0;
  // Observe results
  always @(posedge clk) begin
    if (test_idx >= num_tests) begin
      done = 1;
    end else if (~reset && result_val) begin
      if (result_bits == test_results[test_idx]) begin
        $display(" [ passed ] Test ( %d ), [ %d == %d ] (decimal)",test_idx,result_bits,test_results[test_idx]);
      end else begin
        $display(" [ failed ] Test ( %d ), [ %d == %d ] (decimal)",test_idx,result_bits,test_results[test_idx]);
      end
      test_idx = test_idx + 1;
    end
  end


  //--------------------------------------------------------------------
  // Timeout
  //--------------------------------------------------------------------
  // If something goes wrong, kill the simulation...
  always @(posedge clk) begin
    cycle_count = cycle_count + 1;
    if (cycle_count >= 100000) begin
      $display("TIMEOUT");
      $finish;
    end
  end

endmodule
