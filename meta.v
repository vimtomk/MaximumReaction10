module meta #(
  parameter DATA_WIDTH,
  parameter DEPTH // must be 2 or greater
) (
  input                   clk,
  input  [DATA_WIDTH-1:0] in_sig,
  output [DATA_WIDTH-1:0] out_sig
);

  reg [DATA_WIDTH-1:0] meta_sig [DEPTH:1];
  integer i;
  
  always @(posedge clk)
  begin
    meta_sig[1] <= in_sig;
    for (i=2;i<=DEPTH;i=i+1) meta_sig[i] <= meta_sig[i-1];
  end
  assign out_sig = meta_sig[DEPTH];
endmodule
    