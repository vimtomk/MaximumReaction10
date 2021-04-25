module debounce #(
  parameter [15:0] DWELL_CNT
)  (
  input   clk,
  input   sig_in,
  output  sig_out
);

// TODO:
// declare reg signals here for the 16-bit counter and 1-bit state
	reg        currentState;
	localparam CNT_WIDTH = $clog2(DWELL_CNT); // check this built-in function out; $clog2(N) is ceiling(log2(N)), 
	localparam [CNT_WIDTH-1:0] TERM_CNT = DWELL_CNT - 1; // The range of our counter is 0 to N-1, which has N values
	reg [CNT_WIDTH-1:0]  counter;

initial
begin
  // TODO: can add initialization values to registers here
  counter <= {CNT_WIDTH{1'b0}};
  currentState <= sig_in;
end

always @(posedge clk)
begin
	if (currentState == sig_in) begin
		counter <= 16'h00; // returning counter value to 0
	end else if ((counter & TERM_CNT) == TERM_CNT) begin // way to check if two values are equal 
		currentState <= sig_in; // setting current state to sig in
		counter <= 16'h00;
	end else begin
		counter <= counter + 16'h01; // incrementing counter
	end

end

// TODO: assign sig_out to the 1-bit reg that's tracking the debounce state
assign sig_out = currentState;
     
endmodule
     
