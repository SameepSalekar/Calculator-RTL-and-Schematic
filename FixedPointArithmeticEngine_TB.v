`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2026 07:06:33 PM
// Design Name: 
// Module Name: FixedPointArithmeticEngine_TB
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

module FixedPointArithmeticEngine_tb;

 parameter WIDTH = 8;
 parameter FRACTIONAL_BITS = 4;

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
 localparam ADD_OPERATION = 4'b0000;
 localparam SUBTRACT_OPERATION = 4'b0001;
 localparam COMPARE_OPERATION = 4'b0010;
 localparam MULTIPLY_OPERATION = 4'b0011;
 localparam SEQUENTIAL_MULTIPLY_OPERATION = 4'b0100;
 localparam DIVIDE_OPERATION = 4'b0101;
 localparam SQUARE_ROOT_OPERATION = 4'b0110;
 localparam ACCUMULATE_OPERATION = 4'b0111;
 localparam MAC_OPERATION = 4'b1001;
 localparam RUNNING_PRODUCT_OPERATION = 4'b1010;

 // Device Under Test
 FixedPointArithmeticEngine #(.WIDTH(WIDTH),
                              .FRACTIONAL_BITS(FRACTIONAL_BITS))
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
    $display("Testing FixedPointArithmeticEngine");
    $display("WIDTH = %0d | FRACTIONAL_BITS = %0d",
             WIDTH, FRACTIONAL_BITS);
    $display("------------------------------------------------------------");

    clk = 1'b0;
    reset = 1'b1;
    Start = 1'b0;
    Clear = 1'b0;
    Operation = ADD_OPERATION;
    SignedMode = 1'b0;
    OperandA = {WIDTH{1'b0}};
    OperandB = {WIDTH{1'b0}};

    // Reset the Arithmetic Engine
    #20;
    reset = 1'b0;


    // UNSIGNED FIXED-POINT TESTS
    // Q4.4 Scale Factor = 2^4 = 16
    // Stored Value 16 Represents 1.0

    $display("\n========== UNSIGNED FIXED-POINT TESTS ==========\n");


    // Test 1: Basic Addition
    // 24 + 36 = 60
    // Stored Values: 1.5 + 2.25 = 3.75
    // Expected Result = 60
    Operation = ADD_OPERATION;
    SignedMode = 1'b0;
    OperandA = 8'd24;
    OperandB = 8'd36;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd60)
        $display("FIXED POINT ADD PASSED");
    else
        $display("FIXED POINT ADD FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 2: Basic Subtraction
    // 60 - 20 = 40
    // Stored Values: 3.75 - 1.25 = 2.5
    // Expected Result = 40
    Operation = SUBTRACT_OPERATION;
    OperandA = 8'd60;
    OperandB = 8'd20;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd40)
        $display("FIXED POINT SUBTRACT PASSED");
    else
        $display("FIXED POINT SUBTRACT FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 3: Unsigned Comparison
    // 40 > 24
    // Stored Values: 2.5 > 1.5
    // Expected Greater = 1
    // Expected Equal = 0
    // Expected Lesser = 0
    Operation = COMPARE_OPERATION;
    OperandA = 8'd40;
    OperandB = 8'd24;
    PulseStart;
    #1;

    if (Greater == 1'b1 && Equal == 1'b0 && Lesser == 1'b0)
        $display("FIXED POINT COMPARE PASSED");
    else
        $display("FIXED POINT COMPARE FAILED");


    // Test 4: Combinational Multiplication
    // Stored Values: 24 = 1.5
    //                32 = 2.0
    // 1.5 * 2.0 = 3.0
    // Expected Stored Result = 48
    Operation = MULTIPLY_OPERATION;
    SignedMode = 1'b0;
    OperandA = 8'd24;
    OperandB = 8'd32;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd48)
        $display("FIXED POINT COMBINATIONAL MULTIPLY PASSED");
    else
        $display("FIXED POINT COMBINATIONAL MULTIPLY FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 5: Sequential Multiplication
    // Stored Values: 24 = 1.5
    //                40 = 2.5
    // 1.5 * 2.5 = 3.75
    // Expected Stored Result = 60
    Operation = SEQUENTIAL_MULTIPLY_OPERATION;
    OperandA = 8'd24;
    OperandB = 8'd40;
    PulseStart;
    WaitForDone;
    #1;

    if (Result[WIDTH - 1:0] == 8'd60)
        $display("FIXED POINT SEQUENTIAL MULTIPLY PASSED");
    else
        $display("FIXED POINT SEQUENTIAL MULTIPLY FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 6: Fixed-Point Division
    // Stored Values: 96 = 6.0
    //                24 = 1.5
    // 6.0 / 1.5 = 4.0
    // Expected Stored Result = 64
    Operation = DIVIDE_OPERATION;
    OperandA = 8'd96;
    OperandB = 8'd24;
    PulseStart;
    WaitForDone;
    #1;

    if (Result[WIDTH - 1:0] == 8'd64)
        $display("FIXED POINT DIVIDE PASSED");
    else
        $display("FIXED POINT DIVIDE FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 7: Fixed-Point Square Root
    // Stored Value: 64 = 4.0
    // sqrt(4.0) = 2.0
    // Expected Stored Result = 32
    Operation = SQUARE_ROOT_OPERATION;
    OperandA = 8'd64;
    OperandB = 8'd0;
    PulseStart;
    #1;

    if (Result[WIDTH - 1:0] == 8'd32)
        $display("FIXED POINT SQUARE ROOT PASSED");
    else
        $display("FIXED POINT SQUARE ROOT FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 8: Fixed-Point Accumulation
    // Clear Accumulator Before Starting
    //
    // Stored Values:
    // 16 = 1.0
    // 24 = 1.5
    // 32 = 2.0
    //
    // 1.0 + 1.5 + 2.0 = 4.5
    // Expected Stored Result = 72
    Operation = ACCUMULATE_OPERATION;
    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;

    OperandA = 8'd16;
    PulseStart;

    OperandA = 8'd24;
    PulseStart;

    OperandA = 8'd32;
    PulseStart;

    #1;

    if (Result[WIDTH - 1:0] == 8'd72)
        $display("FIXED POINT ACCUMULATOR PASSED");
    else
        $display("FIXED POINT ACCUMULATOR FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 9: Fixed-Point Multiply-Accumulate
    // Clear MAC Accumulator Before Starting
    //
    // First Operation:
    // 24 = 1.5
    // 32 = 2.0
    // 1.5 * 2.0 = 3.0
    //
    // Second Operation:
    // 16 = 1.0
    // 48 = 3.0
    // 1.0 * 3.0 = 3.0
    //
    // Accumulated Result = 3.0 + 3.0 = 6.0
    // Expected Stored Result = 96
    Operation = MAC_OPERATION;
    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;

    SignedMode = 1'b0;
    OperandA = 8'd24;
    OperandB = 8'd32;
    PulseStart;

    OperandA = 8'd16;
    OperandB = 8'd48;
    PulseStart;

    #1;

    if (Result[WIDTH - 1:0] == 8'd96)
        $display("FIXED POINT MAC PASSED");
    else
        $display("FIXED POINT MAC FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 10: Fixed-Point Running Product
    // Running Product Starts at 1.0
    //
    // Initial = 1.0
    // 1.0 * 2.0 = 2.0
    // 2.0 * 1.5 = 3.0
    // 3.0 * 2.0 = 6.0
    //
    // Expected Stored Result = 96
    Operation = RUNNING_PRODUCT_OPERATION;
    SignedMode = 1'b0;

    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;

    OperandA = 8'd32;
    PulseStart;
    WaitForDone;

    OperandA = 8'd24;
    PulseStart;
    WaitForDone;

    OperandA = 8'd32;
    PulseStart;
    WaitForDone;

    #1;

    if (Result[WIDTH - 1:0] == 8'd96)
        $display("FIXED POINT RUNNING PRODUCT PASSED");
    else
        $display("FIXED POINT RUNNING PRODUCT FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // Test 11: Running Product Clear
    // Clear Restores the Running Product to Fixed-Point 1.0
    // Q4.4 Representation of 1.0 = 16
    // Expected Stored Result = 16
    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;
    #1;

    if (Result[WIDTH - 1:0] == 8'd16)
        $display("FIXED POINT RUNNING PRODUCT CLEAR PASSED");
    else
        $display("FIXED POINT RUNNING PRODUCT CLEAR FAILED: Result = %d",
                 Result[WIDTH - 1:0]);


    // SIGNED FIXED-POINT TESTS

    $display("\n========== SIGNED FIXED-POINT TESTS ==========\n");


    // Test 12: Signed Addition
    // Stored Values: -24 = -1.5
    //                  8 = 0.5
    // -1.5 + 0.5 = -1.0
    // Expected Stored Result = -16
    Operation = ADD_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd24;
    OperandB = 8'sd8;
    PulseStart;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd16)
        $display("SIGNED FIXED POINT ADD PASSED");
    else
        $display("SIGNED FIXED POINT ADD FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));


    // Test 13: Signed Subtraction
    // Stored Values: 24 = 1.5
    //                32 = 2.0
    // 1.5 - 2.0 = -0.5
    // Expected Stored Result = -8
    Operation = SUBTRACT_OPERATION;
    SignedMode = 1'b1;
    OperandA = 8'sd24;
    OperandB = 8'sd32;
    PulseStart;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd8)
        $display("SIGNED FIXED POINT SUBTRACT PASSED");
    else
        $display("SIGNED FIXED POINT SUBTRACT FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));


    // Test 14: Signed Comparison
    // Stored Values: -24 = -1.5
    //                 16 = 1.0
    // -1.5 < 1.0
    // Expected Lesser = 1
    // Expected Equal = 0
    // Expected Greater = 0
    Operation = COMPARE_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd24;
    OperandB = 8'sd16;
    PulseStart;
    #1;

    if (Lesser == 1'b1 && Equal == 1'b0 && Greater == 1'b0)
        $display("SIGNED FIXED POINT COMPARE PASSED");
    else
        $display("SIGNED FIXED POINT COMPARE FAILED");


    // Test 15: Signed Combinational Multiplication
    // Stored Values: -24 = -1.5
    //                  32 = 2.0
    // -1.5 * 2.0 = -3.0
    // Expected Stored Result = -48
    Operation = MULTIPLY_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd24;
    OperandB = 8'sd32;
    PulseStart;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd48)
        $display("SIGNED FIXED POINT COMBINATIONAL MULTIPLY PASSED");
    else
        $display("SIGNED FIXED POINT COMBINATIONAL MULTIPLY FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));


    // Test 16: Signed Sequential Multiplication
    // Stored Values: -24 = -1.5
    //                  32 = 2.0
    // -1.5 * 2.0 = -3.0
    // Expected Stored Result = -48
    Operation = SEQUENTIAL_MULTIPLY_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd24;
    OperandB = 8'sd32;
    PulseStart;
    WaitForDone;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd48)
        $display("SIGNED FIXED POINT SEQUENTIAL MULTIPLY PASSED");
    else
        $display("SIGNED FIXED POINT SEQUENTIAL MULTIPLY FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));


    // Test 17: Signed Fixed-Point Division
    // Stored Values: -96 = -6.0
    //                  24 = 1.5
    // -6.0 / 1.5 = -4.0
    // Expected Stored Result = -64
    Operation = DIVIDE_OPERATION;
    SignedMode = 1'b1;
    OperandA = -8'sd96;
    OperandB = 8'sd24;
    PulseStart;
    WaitForDone;
    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd64)
        $display("SIGNED FIXED POINT DIVIDE PASSED");
    else
        $display("SIGNED FIXED POINT DIVIDE FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));


    // Test 18: Signed Fixed-Point Multiply-Accumulate
    // Clear MAC Accumulator Before Starting
    //
    // First Operation:
    // -24 = -1.5
    //  32 = 2.0
    // -1.5 * 2.0 = -3.0
    //
    // Second Operation:
    // 16 = 1.0
    // 16 = 1.0
    // 1.0 * 1.0 = 1.0
    //
    // Accumulated Result = -3.0 + 1.0 = -2.0
    // Expected Stored Result = -32
    Operation = MAC_OPERATION;
    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;

    SignedMode = 1'b1;
    OperandA = -8'sd24;
    OperandB = 8'sd32;
    PulseStart;

    OperandA = 8'sd16;
    OperandB = 8'sd16;
    PulseStart;

    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd32)
        $display("SIGNED FIXED POINT MAC PASSED");
    else
        $display("SIGNED FIXED POINT MAC FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));


    // Test 19: Signed Fixed-Point Running Product
    // Running Product Starts at 1.0
    //
    // Initial = 1.0
    // 1.0 * (-2.0) = -2.0
    // -2.0 * 1.5 = -3.0
    //
    // Expected Stored Result = -48
    Operation = RUNNING_PRODUCT_OPERATION;
    SignedMode = 1'b1;

    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;

    OperandA = -8'sd32;
    PulseStart;
    WaitForDone;

    OperandA = 8'sd24;
    PulseStart;
    WaitForDone;

    #1;

    if ($signed(Result[WIDTH - 1:0]) == -8'sd48)
        $display("SIGNED FIXED POINT RUNNING PRODUCT PASSED");
    else
        $display("SIGNED FIXED POINT RUNNING PRODUCT FAILED: Result = %d",
                 $signed(Result[WIDTH - 1:0]));

    $display("\n--------------------THE END--------------------");
    $display("FIXED POINT ARITHMETIC ENGINE TESTBENCH COMPLETE");

    #20;
    $finish;
 end

endmodule