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

 // Arithmetic Operation Codes
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

 // Device Under Test
 IntegerArithmeticEngine #(.WIDTH(WIDTH))
 DUT (.clk(clk), .reset(reset), .Start(Start), .Clear(Clear),
      .Operation(Operation), .SignedMode(SignedMode),
      .OperandA(OperandA), .OperandB(OperandB),
      .Result(Result), .Busy(Busy), .Done(Done), .Error(Error),
      .ZeroFlag(ZeroFlag), .NegativeFlag(NegativeFlag),
      .CarryFlag(CarryFlag), .OverflowFlag(OverflowFlag),
      .Greater(Greater), .Equal(Equal), .Lesser(Lesser));

 // Generate a 10 ns Clock Period
 always #5 clk = ~clk;

 // Generate a One-Cycle Start Pulse
 task PulseStart;
 begin
    @(negedge clk);
    Start = 1'b1;
    @(negedge clk);
    Start = 1'b0;
 end
 endtask

 // Wait Until a Sequential Operation is Complete
 task WaitForDone;
 begin
    while (Done !== 1'b1)
        @(negedge clk);
 end
 endtask

 initial begin
    $display("------------------------------------------------------------");
    $display("Testing IntegerArithmeticEngine");
    $display("WIDTH = %0d", WIDTH);
    $display("------------------------------------------------------------");

    clk = 1'b0;
    reset = 1'b1;
    Start = 1'b0;
    Clear = 1'b0;
    Operation = 4'd0;
    SignedMode = 1'b0;
    OperandA = {WIDTH{1'b0}};
    OperandB = {WIDTH{1'b0}};

    // Reset the Arithmetic Engine
    #20;
    reset = 1'b0;


    // UNSIGNED INTEGER TESTS

    $display("\n========== UNSIGNED INTEGER TESTS ==========\n");


    // Test 1: Basic Addition
    // 25 + 17 = 42
    // Expected Result = 42
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


    // Test 2: Basic Subtraction
    // 25 - 17 = 8
    // Expected Result = 8
    Operation = SUBTRACT_OPERATION;
    OperandA = 8'd25;
    OperandB = 8'd17;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd8)
        $display("SUBTRACT PASSED");
    else
        $display("SUBTRACT FAILED: Result = %d", Result);


    // Test 3: Unsigned Comparison
    // 25 > 17
    // Expected Greater = 1
    // Expected Equal = 0
    // Expected Lesser = 0
    Operation = COMPARE_OPERATION;
    OperandA = 8'd25;
    OperandB = 8'd17;
    PulseStart;
    #1;

    if (Greater == 1'b1 && Equal == 1'b0 && Lesser == 1'b0)
        $display("COMPARE PASSED");
    else
        $display("COMPARE FAILED");


    // Test 4: Combinational Multiplication
    // 12 * 7 = 84
    // Expected Result = 84
    Operation = MULTIPLY_OPERATION;
    OperandA = 8'd12;
    OperandB = 8'd7;
    PulseStart;
    #1;

    if (Result == 16'd84)
        $display("COMBINATIONAL MULTIPLY PASSED");
    else
        $display("COMBINATIONAL MULTIPLY FAILED: Result = %d", Result);


    // Test 5: Sequential Multiplication
    // 13 * 9 = 117
    // Expected Result = 117
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


    // Test 6: Integer Division
    // 100 / 9 = 11 Remainder 1
    // Expected Quotient = 11
    // Expected Remainder = 1
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


    // Test 7: Integer Square Root
    // sqrt(100) = 10
    // Expected Root = 10
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


    // Test 8: Integer Accumulation
    // 10 + 20 + 30 = 60
    // Expected Accumulated Result = 60
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
        $display("ACCUMULATOR FAILED: Sum = %d",
                 Result[WIDTH - 1:0]);


    // Test 9: Wide Integer Accumulation
    // Uses the Full 2*WIDTH Result
    // 100 + 100 + 100 = 300
    // Expected Result = 300
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


    // Test 10: Multiply-Accumulate
    // First Operation:
    // 5 * 4 = 20
    //
    // Second Operation:
    // 3 * 6 = 18
    //
    // Accumulated Result = 20 + 18 = 38
    // Expected Result = 38
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


    // Test 11: Running Product
    // Clear Restores the Running Product to 1
    //
    // Initial = 1
    // 1 * 2 = 2
    // 2 * 3 = 6
    // 6 * 4 = 24
    //
    // Expected Result = 24
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


    // Test 12: Running Product Clear
    // Clear Restores the Running Product to 1
    // Expected Result = 1
    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;
    #1;

    if (Result == 16'd1)
        $display("RUNNING PRODUCT CLEAR PASSED");
    else
        $display("RUNNING PRODUCT CLEAR FAILED: Product = %d", Result);


    // SIGNED INTEGER TESTS

    $display("\n========== SIGNED INTEGER TESTS ==========\n");


    // Test 13: Signed Addition
    // -20 + 7 = -13
    // Expected Result = -13
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


    // Test 14: Signed Comparison
    // -10 < 5
    // Expected Lesser = 1
    // Expected Equal = 0
    // Expected Greater = 0
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


    // Test 15: Signed Sequential Multiplication
    // -7 * 6 = -42
    // Expected Result = -42
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


    // Test 16: Signed Integer Division
    // -100 / 9 = -11
    // Expected Quotient = -11
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


    $display("\n--------------------THE END--------------------");
    $display("INTEGER ARITHMETIC ENGINE TESTBENCH COMPLETE");

    #20;
    $finish;
 end

endmodule
