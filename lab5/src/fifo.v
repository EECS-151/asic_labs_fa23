//=========================================================================
// FIFO Template
//-------------------------------------------------------------------------
//

module fifo #(parameter WIDTH = 8, parameter LOGDEPTH = 3) (
    input clk,
    input reset,

    input enq_val,
    input [WIDTH-1:0] enq_data,
    output enq_rdy,

    output deq_val,
    output [WIDTH-1:0] deq_data,
    input deq_rdy

);

localparam DEPTH = (1 << LOGDEPTH);

// the buffer itself. Take note of the 2D syntax.
wire [WIDTH-1:0] buffer [DEPTH-1:0];
// read pointer
wire [LOGDEPTH-1:0] rptr;
// write pointer
wire [LOGDEPTH-1:0] wptr;
// is the buffer full? This is needed for when rptr == wptr
wire full;

// Define any additional regs or wires you need (if any) here
wire [LOGDEPTH-1:0] wptr_next;
wire [LOGDEPTH-1:0] rptr_next;
genvar i;


// use "fire" to indicate when a valid transaction has been made
wire enq_fire;
wire deq_fire;

assign enq_fire = enq_val & enq_rdy;
assign deq_fire = deq_val & deq_rdy;

assign wptr_next = wptr + enq_fire;
assign rptr_next = rptr + deq_fire;

REGISTER_R #(.N(LOGDEPTH)) wptr_reg (.clk(clk), .d(wptr_next), .q(wptr), .rst(reset));
REGISTER_R #(.N(LOGDEPTH)) rptr_reg (.clk(clk), .d(rptr_next), .q(rptr), .rst(reset));
REGISTER_R full_reg (.clk(clk), .d((wptr_next == rptr_next) & (full | enq_fire)), .q(full), .rst(reset));

generate
    for (i=0; i<DEPTH; i=i+1) begin : buffer_step
        REGISTER_R_CE #(.N(WIDTH)) buffer_reg (.clk(clk), .d(enq_data), .q(buffer[i]), .rst(reset), .ce((wptr == i && enq_fire)));
    end
endgenerate

/*
always @(posedge clk) begin
  if (reset) begin
    // clear everything
    full <= 1'b0;
    rptr <= {LOGDEPTH{1'b0}};
    wptr <= {LOGDEPTH{1'b0}};
  end else begin

    // Your code here
    wptr <= wptr_next;
    rptr <= rptr_next;
    buffer[wptr] <= enq_fire ? enq_data : buffer[wptr];
    full <= (wptr_next == rptr_next) & (full | enq_fire);

  end
end
*/
// Additional code here, if needed
assign enq_rdy = ~full;
assign deq_val = (wptr != rptr) | full; // ~empty
assign deq_data = buffer[rptr];

endmodule
