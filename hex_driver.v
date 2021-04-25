module  hex_driver (
  input      [4:0] InVal,
  output reg [7:0] OutVal
);

always @(InVal)
begin
  case (InVal)
  // TODO: add all the different cases to correspond to the encoding
  //       in Table 2 of the lab assignment
  
  5'd0	 : OutVal = 8'hC0; // 0
  5'd1	 : OutVal = 8'hF9; // 1-I
  5'd2	 : OutVal = 8'hA4; // 2
  5'd3	 : OutVal = 8'hB0; // 3
  5'd4	 : OutVal = 8'h99; // 4
  5'd5	 : OutVal = 8'h92; // 5-S
  5'd6	 : OutVal = 8'h82; // 6
  5'd7	 : OutVal = 8'hF8; // 7
  5'd8	 : OutVal = 8'h80; // 8
  5'd9	 : OutVal = 8'h90; // 9
  5'd10	 : OutVal = 8'h88; // A
  5'd11	 : OutVal = 8'h83; // b
  5'd12	 : OutVal = 8'hC6; // C
  5'd13	 : OutVal = 8'hA1; // d
  5'd14	 : OutVal = 8'h86; // E
  5'd15	 : OutVal = 8'h8E; // F
  5'd16	 : OutVal = 8'hAF; // r -> 1010 1111 -> AF
  5'd17	 : OutVal = 8'h90; // g -> 1001 0000 -> 90
  5'd18	 : OutVal = 8'hA3; // o -> 1010 0011 -> A3
  5'd19	 : OutVal = 8'h89; // H -> 1000 1001 -> 89 U -> 1100 0001 - > C1
  
  
  default : OutVal = 8'hFF; // blank
  endcase
end

endmodule
	  