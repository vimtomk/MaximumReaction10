module msec_timer #(
  parameter [31:0] FREQ_KHZ
) (
  input      clk,
  output reg msec_pulse
);

localparam CNT_WIDTH = $clog2(FREQ_KHZ); // check this built-in function out; $clog2(N) is ceiling(log2(N)), 
                                         // i.e. how many bits is enough to represent the number N
localparam [CNT_WIDTH-1:0] TERM_CNT = FREQ_KHZ - 1; // The range of our counter is 0 to N-1, which has N values
                                                    // e.g. if FREQ_KHZ is 50000, counting from 0 to 49999 has a 
                                                    // period of 50000 clock cycles
reg [CNT_WIDTH-1:0]  msec_cnt;

initial
begin
  msec_cnt <= {CNT_WIDTH{1'b0}}; // not really important, but very handy for simulation
end

always @(posedge clk)
begin
  if ((msec_cnt & TERM_CNT) == TERM_CNT) begin // NOTE: this is a cool way to avoid having a lot of digits to match; 
                                               // The & (AND) operator with a constant makes it so that we only look
                                               // at as many digits have 1's in the constant TERM_CNT.  For an up-counter
                                               // the first time it hits a number with ones in all the spots we care
                                               // about is when it hits TERM_CNT
    msec_cnt <= 'h0;
    msec_pulse <= 1'b1;
  end else begin
    msec_cnt <= msec_cnt + 'h1;
    msec_pulse <= 1'b0;
  end
end

endmodule
