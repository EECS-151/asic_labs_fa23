`timescale 1 ns /  100 ps

module gcd_testbench;

  //--------------------------------------------------------------------
  // Define test vectors
  //--------------------------------------------------------------------
  wire [31:0] src_bits [7:0];
  wire [15:0] sink_bits [7:0];
  assign src_bits[0] = { 16'd27,  16'd15  }; assign sink_bits[0] = { 16'd3  };
  assign src_bits[1] = { 16'd21,  16'd49  }; assign sink_bits[1] = { 16'd7  };
  assign src_bits[2] = { 16'd25,  16'd30  }; assign sink_bits[2] = { 16'd5  };
  assign src_bits[3] = { 16'd19,  16'd27  }; assign sink_bits[3] = { 16'd1  };
  assign src_bits[4] = { 16'd40,  16'd40  }; assign sink_bits[4] = { 16'd40 };
  assign src_bits[5] = { 16'd250, 16'd190 }; assign sink_bits[5] = { 16'd10 };
  assign src_bits[6] = { 16'd5,   16'd250 }; assign sink_bits[6] = { 16'd5  };
  assign src_bits[7] = { 16'd0,   16'd0   }; assign sink_bits[7] = { 16'd0  };


  //--------------------------------------------------------------------
  // Setup a clock
  //--------------------------------------------------------------------
  reg clk = 0;
  //always #(`CLOCK_PERIOD/2) clk = ~clk;
  always #20 clk = ~clk; // 50Mhz

  //--------------------------------------------------------------------
  // Instantiate DUT and wire/reg the inputs and outputs
  //--------------------------------------------------------------------
  reg [7:0] test_index;
  reg [7:0] scan_index;
  wire [15:0] src_bits_A;
  wire [15:0] src_bits_B;
  wire [15:0] compare_bits;
  wire [16*3-1:0] scan_chain;
  reg [16*3-1:0] scanback_chain;
  wire [15:0] scanback_bits;

  assign src_bits_A = src_bits[test_index][31:16];
  assign src_bits_B = src_bits[test_index][15:0];
  assign compare_bits = sink_bits[test_index];
  assign scan_chain = {src_bits_A, src_bits_B, 16'b0};
  assign scanback_bits = scanback_chain[15:0];

  reg reset;
  reg        src_val;
  wire        src_done;
  wire [15:0] result_bits_data;
  wire        result_val;
  reg        result_rdy;
  wire scan_out;
  reg pll_bypass;
  reg pll_fb_mode;
  reg pll_fb_clk;
  reg scan_in;
  reg scan_enable;
  
  top #(16) top
  (
  .IO_scan_out(scan_out),
  .IO_operands_rdy(src_rdy),
  .IO_result_rdy(result_rdy),
  .IO_result_val(result_val),
  .IO_pll_ref_clk(clk),
  .IO_pll_bypass(pll_bypass),
  .IO_pll_fb_mode(pll_fb_mode),
  .IO_pll_fb_clk(pll_fb_clk),
  .IO_reset(reset),
  .IO_scan_in(scan_in),
  .IO_scan_enable(scan_enable),
  .IO_operands_val(src_val),
  .IO_vdd(1'b1),
  .IO_iovdd(1'b1),
  .IO_vss(1'b0),
  .IO_iovss(1'b0)
  );

  //--------------------------------------------------------------------
  // Define a sequential interface that steps through each test in
  // the src/sink array every time a valid ready/val handshake occurs
  //--------------------------------------------------------------------

  initial begin
    $vcdpluson;
    // Initial values
    src_val = 0;
    result_rdy = 1;
    pll_bypass = 0;
    pll_fb_mode = 0;
    pll_fb_clk = 0;

    // Strope reset
    repeat (5) @(negedge clk) reset = 1;
    @(negedge clk) reset = 0;

    // Loop through test vectors..
    for (test_index = 0; test_index < 7; test_index = test_index + 1) begin
      // Start when DUT is ready
      @(negedge clk & src_rdy);
      // Start the scan chain
      scan_enable = 1;
      for (scan_index = 0; scan_index < 16*3; scan_index = scan_index + 1) begin
        scan_in = scan_chain[scan_index];
        @(negedge clk);
      end
      src_val = 1; 
      scan_enable = 0;
      @(negedge clk);
      src_val = 0; 
      // Wait until result is made valid
      @(posedge result_val);
      // Make sure the result gets synchronized to the
      // scan registers by waiting
      // (eg. synchronize the val signal in the testbench)
      @(negedge clk);
      @(negedge clk);
      @(negedge clk);
      scan_enable = 1;
      // Scan everything out (even though the operands are unnecessary)
      for (scan_index = 0; scan_index < 16*3; scan_index = scan_index + 1) begin
        scanback_chain[scan_index] = scan_out;
        @(negedge clk);
      end
      // Don't check right away (not sure when this signal will go high),
      // but check at the next positive edge
      @(negedge clk);
      scan_enable = 0;
      if (compare_bits == scanback_chain[15:0]) begin
        $display(" [ passed ] Test ( %d ), [ %d == %d ] (decimal)",test_index,compare_bits,scanback_chain[15:0]);
      end else begin
        $display(" [ failed ] Test ( %d ), [ %d == %d ] (decimal)",test_index,compare_bits,scanback_chain[15:0]);
      end
    end

    $vcdplusoff;
    $finish;
  end


  //--------------------------------------------------------------------
  // Timeout
  //--------------------------------------------------------------------
  // If something goes wrong, kill the simulation...
  reg [  63:0] cycle_count = 0;
  always @(posedge clk) begin
    cycle_count = cycle_count + 1;
    if (cycle_count >= 100000) begin
      $display("TIMEOUT");
      $finish;
    end
  end


endmodule
