`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:33:17 PM
// Design Name: 
// Module Name: IntegerArithmeticEngine_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module IntegerArithmeticEngine_tb;

 parameter WIDTH = 8;

 reg clk;
 reg reset;
 reg Start;
 reg Clear;
 reg [3:0] Operation;
 reg SignedMode;
 reg [WIDTH - 1:0] OperandA;
 reg [WIDTH - 1:0] OperandB;

 wire [(2 * WIDTH) - 1:0] Result;
 wire Busy;
 wire Done;
 wire Error;
 wire ZeroFlag;
 wire NegativeFlag;
 wire CarryFlag;
 wire OverflowFlag;
 wire Greater;
 wire Equal;
 wire Lesser;

 localparam ADD_OPERATION = 4'd0;
 localparam SUBTRACT_OPERATION = 4'd1;
 localparam COMPARE_OPERATION = 4'd2;
 localparam MULTIPLY_OPERATION = 4'd3;
 localparam SEQUENTIAL_MULTIPLY_OPERATION = 4'd4;
 localparam DIVIDE_OPERATION = 4'd5;
 localparam SQUARE_ROOT_OPERATION = 4'd6;
 localparam ACCUMULATE_OPERATION = 4'd7;
 localparam WIDE_ACCUMULATE_OPERATION = 4'd8;
 localparam MAC_OPERATION = 4'd9;
 localparam RUNNING_PRODUCT_OPERATION = 4'd10;
 
 IntegerArithmeticEngine #(.WIDTH(WIDTH))
 DUT (.clk(clk), .reset(reset), .Start(Start), .Clear(Clear),
      .Operation(Operation), .SignedMode(SignedMode),
      .OperandA(OperandA), .OperandB(OperandB),
      .Result(Result), .Busy(Busy), .Done(Done), .Error(Error),
      .ZeroFlag(ZeroFlag), .NegativeFlag(NegativeFlag),
      .CarryFlag(CarryFlag), .OverflowFlag(OverflowFlag),
      .Greater(Greater), .Equal(Equal), .Lesser(Lesser));

 always #5 clk = ~clk;

 task PulseStart;
 begin
    @(negedge clk);
    Start = 1'b1;
    @(negedge clk);
    Start = 1'b0;
 end
 endtask

 task WaitForDone;
 begin
    while (Done !== 1'b1)
        @(negedge clk);
 end
 endtask

 initial begin
    clk = 1'b0;
    reset = 1'b1;
    Start = 1'b0;
    Clear = 1'b0;
    Operation = 4'd0;
    SignedMode = 1'b0;
    OperandA = {WIDTH{1'b0}};
    OperandB = {WIDTH{1'b0}};

    #20;
    reset = 1'b0;

    Operation = ADD_OPERATION;
    SignedMode = 1'b0;
    OperandA = 8'd25;
    OperandB = 8'd17;
    PulseStart;
    #1;

    if (Result == 16'd42)
        $display("ADD PASSED");
    else
        $display("ADD FAILED: Result = %d", Result);

    Operation = SUBTRACT_OPERATION;
    OperandA = 8'd25;
    OperandB = 8'd17;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd8)
        $display("SUBTRACT PASSED");
    else
        $display("SUBTRACT FAILED: Result = %d", Result);

    Operation = COMPARE_OPERATION;
    OperandA = 8'd25;
    OperandB = 8'd17;
    PulseStart;
    #1;

    if (Greater == 1'b1 && Equal == 1'b0 && Lesser == 1'b0)
        $display("COMPARE PASSED");
    else
        $display("COMPARE FAILED");

    Operation = MULTIPLY_OPERATION;
    OperandA = 8'd12;
    OperandB = 8'd7;
    PulseStart;
    #1;

    if (Result == 16'd84)
        $display("COMBINATIONAL MULTIPLY PASSED");
    else
        $display("COMBINATIONAL MULTIPLY FAILED: Result = %d", Result);

    Operation = SEQUENTIAL_MULTIPLY_OPERATION;
    OperandA = 8'd13;
    OperandB = 8'd9;
    PulseStart;
    WaitForDone;
    #1;

    if (Result == 16'd117)
        $display("SEQUENTIAL MULTIPLY PASSED");
    else
        $display("SEQUENTIAL MULTIPLY FAILED: Result = %d", Result);

    Operation = DIVIDE_OPERATION;
    OperandA = 8'd100;
    OperandB = 8'd9;
    PulseStart;
    WaitForDone;
    #1;

    if (Result[WIDTH - 1:0] == 8'd11 &&
        Result[(2 * WIDTH) - 1:WIDTH] == 8'd1)
        $display("DIVIDE PASSED");
    else
        $display("DIVIDE FAILED: Quotient = %d Remainder = %d",
                 Result[WIDTH - 1:0],
                 Result[(2 * WIDTH) - 1:WIDTH]);

    Operation = SQUARE_ROOT_OPERATION;
    OperandA = 8'd100;
    OperandB = 8'd0;
    PulseStart;
    #1;

    if (Result[((WIDTH + 1) / 2) - 1:0] == 4'd10)
        $display("SQUARE ROOT PASSED");
    else
        $display("SQUARE ROOT FAILED: Root = %d",
                 Result[((WIDTH + 1) / 2) - 1:0]);

    Operation = ACCUMULATE_OPERATION;
    OperandA = 8'd10;
    PulseStart;
    OperandA = 8'd20;
    PulseStart;
    OperandA = 8'd30;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd60)
        $display("ACCUMULATOR PASSED");
    else
        $display("ACCUMULATOR FAILED: Sum = %d", Result[WIDTH - 1:0]);

    Operation = WIDE_ACCUMULATE_OPERATION;
    OperandA = 8'd100;
    PulseStart;
    OperandA = 8'd100;
    PulseStart;
    OperandA = 8'd100;
    PulseStart;
    #1;

    if (Result == 16'd300)
        $display("WIDE ACCUMULATOR PASSED");
    else
        $display("WIDE ACCUMULATOR FAILED: Sum = %d", Result);

    Operation = MAC_OPERATION;
    SignedMode = 1'b0;
    OperandA = 8'd5;
    OperandB = 8'd4;
    PulseStart;
    OperandA = 8'd3;
    OperandB = 8'd6;
    PulseStart;
    #1;

    if (Result == 16'd38)
        $display("MAC PASSED");
    else
        $display("MAC FAILED: Sum = %d", Result);

    Operation = RUNNING_PRODUCT_OPERATION;
    SignedMode = 1'b0;

    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;

    OperandA = 8'd2;
    PulseStart;
    WaitForDone;

    OperandA = 8'd3;
    PulseStart;
    WaitForDone;

    OperandA = 8'd4;
    PulseStart;
    WaitForDone;

    #1;

    if (Result == 16'd24)
        $display("RUNNING PRODUCT PASSED");
    else
        $display("RUNNING PRODUCT FAILED: Product = %d", Result);

    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;
    #1;

    if (Result == 16'd1)
        $display("RUNNING PRODUCT CLEAR PASSED");
    else
        $display("RUNNING PRODUCT CLEAR FAILED: Product = %d", Result);

    Operation = ADD_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd20;
    OperandB = 8'sd7;
    PulseStart;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd13)
        $display("SIGNED ADD PASSED");
    else
        $display("SIGNED ADD FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));

    Operation = COMPARE_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd10;
    OperandB = 8'sd5;
    PulseStart;
    #1;

    if (Lesser == 1'b1 && Equal == 1'b0 && Greater == 1'b0)
        $display("SIGNED COMPARE PASSED");
    else
        $display("SIGNED COMPARE FAILED");

    Operation = SEQUENTIAL_MULTIPLY_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd7;
    OperandB = 8'sd6;
    PulseStart;
    WaitForDone;
    #1;

    if ($signed(Result) == -16'sd42)
        $display("SIGNED SEQUENTIAL MULTIPLY PASSED");
    else
        $display("SIGNED SEQUENTIAL MULTIPLY FAILED: Result = %d",
                 $signed(Result));

    Operation = DIVIDE_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd100;
    OperandB = 8'sd9;
    PulseStart;
    WaitForDone;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd11)
        $display("SIGNED DIVIDE PASSED");
    else
        $display("SIGNED DIVIDE FAILED: Quotient = %d",
                 $signed(Result[WIDTH - 1:0]));

    $display("INTEGER ARITHMETIC ENGINE TESTBENCH COMPLETE");

    #20;
    $finish;
 end

endmodule
