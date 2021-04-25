module alu (
  input    clk,
  input  [7:0]  operandA,
  input  [7:0]  operandB,
  input  [2:0]  opCode,
  output [15:0] opResult
);
	
  reg [15:0] myReg;

  always @(posedge clk)
  begin
  // TODO: add code here for the ALU; remember to either
  //       change opResult to a output reg ... type, or
  //       to declare a reg to assign in this procedure
  //       and then assign opResult = your_reg
  
	case (opCode)
		3'b000 : myReg <= operandA + operandB; // adding
		3'b001 : myReg <= operandA - operandB; // subtracting
		3'b010 : myReg <= operandA ^ operandB; // xor
		3'b011 : myReg <= operandA & operandB; // and
		3'b100 : myReg <= operandA | operandB; // or
		3'b101 : myReg <= operandA[7:0] *  operandB[7:0]; // multiply
		3'b110 : myReg <= operandA[7:0] << operandB[3:0]; // left shift
		default: myReg <= operandB[7:0] >> operandB[3:0]; // right shift
	endcase
	
  end
  assign opResult = myReg; // assigning the value out to the opResult such that the output is displayed on the hex display
  
endmodule
