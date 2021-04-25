module led_driver (
	input clk,
	input disp,
	output LEDR0,
	output LEDR1,
	output LEDR2,
	output LEDR3,
	output LEDR4,
	output LEDR5,
	output LEDR6,
	output LEDR7,
	output LEDR8,
	output LEDR9
);

	always @(posedge clk or disp) begin
		if (disp) begin
			{LEDR0,LEDR1,LEDR2,LEDR3,LEDR4,LEDR5,LEDR6,LEDR7,LEDR8,LEDR9} = {10'b0000000000};
		end
		else begin
			{LEDR0,LEDR1,LEDR2,LEDR3,LEDR4,LEDR5,LEDR6,LEDR7,LEDR8,LEDR9} = {10'b1111111111};
		end
	end
	
endmodule
