module display_driver (
  input clk,
  input        dispMode,
  input        oneMsPulse,
  input [7:0]  OpReg,
  input        ShowOpReg, // one-cycle pulse
  input [2:0]  OpCode,
  input        ShowOpCode, // one-cycle pulse
  input [15:0] OpResult,
  output [7:0] HEX0,
  output [7:0] HEX1,
  output [7:0] HEX2,
  output [7:0] HEX3,
  output [7:0] HEX4,
  output [7:0] HEX5
);

  localparam SHOW_RESULT = 2'b00;
  localparam SHOW_OPREG  = 2'b01;
  localparam SHOW_OPCODE = 2'b10;
  localparam CHAR_C = 5'h0C; // char value for C
  localparam CHAR_R = 5'h10;
  localparam CHAR_BLANK = 5'h14;
  localparam CHAR_S = 5'h05; // using 5 for S
  localparam CHAR_H = 5'h19; // H
  localparam CHAR_I = 5'h01; // I
  
  wire [15:0] DEC_POWER [4:0];
  assign DEC_POWER[4] = 16'd10000;
  assign DEC_POWER[3] = 16'd1000;
  assign DEC_POWER[2] = 16'd100;
  assign DEC_POWER[1] = 16'd10;
  assign DEC_POWER[0] = 16'd1;
  
  reg [1:0]  displayState;
  reg [11:0] threeSecCnt;
  
  reg [15:0] decResult;
  reg [15:0] decTemp;
  reg [2:0] decState;
  reg [3:0] decDigits [4:0];
  
  reg [4:0] char0;
  reg [4:0] char1;
  reg [4:0] char2;
  reg [4:0] char3;
  reg [4:0] char4;
  reg [4:0] char5;
  
  integer i;
  
  
  always @(*) // NOTE: this is shorthand for (displayState, OpResult, dispMode, decDigits, OpReg, OpCode), and does the trick!
  begin
    if (displayState == SHOW_RESULT) begin // dump out the result value to the hex display
      if (dispMode) // ... as a 4-digit hex value
        {char5,char4,char3,char2,char1,char0} = {CHAR_BLANK,CHAR_BLANK,1'b0,OpResult[15:12],1'b0,OpResult[11:8],1'b0,OpResult[7:4],1'b0,OpResult[3:0]};
      else begin // ... or as a 5-digit decimal value
        char5 = CHAR_BLANK;
        char4 = {1'b0,decDigits[4]};
        char3 = {1'b0,decDigits[3]};
        char2 = {1'b0,decDigits[2]};
        char1 = {1'b0,decDigits[1]};
        char0 = {1'b0,decDigits[0]};
      end
    end else if (displayState==SHOW_OPREG) begin
      {char5,char4,char3,char2,char1,char0} = {CHAR_R, CHAR_E, CHAR_G, CHAR_BLANK, 1'b0, OpReg[7:4], 1'b0, OpReg[3:0]}; // TODO: need this to concatenate 6 5-bit values to say 'rEg ##'
                                                               // Keep in mind - they're 5 bits each!!! And use the OpResult hex line above for hints
    end else begin
      {char5,char4,char3,char2,char1,char0} = {CHAR_C, CHAR_O, CHAR_D, CHAR_E, CHAR_BLANK, 2'b00,OpCode[2:0]}; // TODO: need this to concatenate 6 5-bit values to say 'CoDE #'
                                                                                   // initially it says '     #'
    end
  end

  always @(posedge clk)
  begin
    // NOTE:  Here is an FSM for tracking what is currently on the display
    case (displayState)
    SHOW_RESULT : begin // show the 4 (hex) or 5 (dec) digit output of the ALU
      threeSecCnt <= 12'd0;
      if (ShowOpReg) begin // !! button press !! start showing rEg ## for 3 seconds
        displayState <= SHOW_OPREG;
      end else if (ShowOpCode) begin // !! button press !! start showing CoDE # for 3 seconds
        displayState <= SHOW_OPCODE;
      end
    end
    SHOW_OPREG : begin 
      if (ShowOpCode) begin // interrupted by a more recent button press - show that
        threeSecCnt  <= 12'd0;
        displayState <= SHOW_OPCODE;
      end else begin
        if (ShowOpReg) begin // another button press to the OpReg - give it another 3 seconds
          threeSecCnt  <= 12'd0;
        end else begin
          threeSecCnt <= threeSecCnt+oneMsPulse;
        end
        if (threeSecCnt==12'd2999) begin // 3 seconds timed out (3000 msec) - return to showing the result
          displayState <= SHOW_RESULT;
        end
      end
    end
    default : begin // SHOW_OPCODE
      if (ShowOpReg) begin // interrupted by a more recent button press - show that
        threeSecCnt  <= 12'd0;
        displayState <= SHOW_OPREG;
      end else begin
        if (ShowOpCode) begin // another button press to the OpCode - give it another 3 seconds
          threeSecCnt  <= 12'd0;
        end else begin
          threeSecCnt <= threeSecCnt+oneMsPulse;
        end
        if (threeSecCnt==12'd2999) begin // 3000 msec timed out here
          displayState <= SHOW_RESULT;
        end
      end
    end
    endcase
    
    // NOTE:  Here is another FSM in the same always @(posedge clk) process
    //        This is okay to lump unrelated FSMs together, or they can be
    //        separated - either preference is okay
    //        This one is encoded a little differently - it is for converting
    //        a 16-bit binary value into a 5-digit decimal value:
    //        Note that in Verilog, ** is the exponent operator (10**2 == 100)
    if (decState==3'b111) begin // NOTE: this is like 10**(-1) - just encoded to treat it like an idle state
      if (decResult!=OpResult) begin // !! There's a new value on OpResult that we haven't converted to decimal yet!!
        decState <= 3'b100; // start looking for the ten-thousands digit, 10**4
        decResult <= OpResult; // store the new value right away, just in case the switch bounces (we will recalculate)
        for (i=0;i<=4;i=i+1) decDigits[i] <= {4'b0}; // reset all digit states to zero - we will transfer 10**X to each digit...
      end
      decTemp <= OpResult; // store off the value in a temporary reg
    end else begin // here we will decrement through the values of 10**(4...0)
      if (decTemp>=DEC_POWER[decState]) begin // is the remaining value (that hasn't been converted) greater than 10**X?
        decTemp <= decTemp-DEC_POWER[decState]; // if so, subtract 10**X from the remaining binary reg...
        decDigits[decState] <= decDigits[decState]+4'd1; // ...and add it to the decimal digit that we're building
      end else begin // we're below 10**X, time to decrement X
        decState <= decState-1; // ...if decState is on the ones digit, we've hit decTemp==0 (done), and decState will underflow
	                        // to 3'b111 on the next cycle - this causes this state machine to go back to idle!
      end
    end
  end
  
  // NOTE: this notation instantiates an array of 6 of these - it is okay
  // to call this out 6 times, but this is often nice to implicitly
  // generate a number of related instances
  hex_driver hex_display [5:0] (
    .InVal ({char5,char4,char3,char2,char1,char0}),
    .OutVal ({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0})
  );
endmodule
