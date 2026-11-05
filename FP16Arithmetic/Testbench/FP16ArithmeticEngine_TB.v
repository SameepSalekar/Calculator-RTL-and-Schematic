`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 03:11:55 AM
// Design Name: 
// Module Name: FP16ArithmeticEngine_TB
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


`include "FP16Definitions.vh"

module FP16ArithmeticEngine_TB;

 reg clk;
 reg reset;
 reg Start;
 reg Clear;

 reg [`FP16_OPERATION_WIDTH - 1:0] Operation;

 reg [`FP16_WIDTH - 1:0] OperandA;
 reg [`FP16_WIDTH - 1:0] OperandB;

 wire [`FP16_WIDTH - 1:0] Result;
 wire [31:0] WideResult;

 wire Busy;
 wire Done;

 wire InvalidOperation;
 wire DivideByZero;
 wire Overflow;
 wire Underflow;
 wire Inexact;

 wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector;

 wire Greater;
 wire Equal;
 wire Lesser;
 wire Unordered;

 // Device Under Test
 FP16ArithmeticEngine DUT
 (.clk(clk),
  .reset(reset),
  .Start(Start),
  .Clear(Clear),
  .Operation(Operation),
  .OperandA(OperandA),
  .OperandB(OperandB),
  .Result(Result),
  .WideResult(WideResult),
  .Busy(Busy),
  .Done(Done),
  .InvalidOperation(InvalidOperation),
  .DivideByZero(DivideByZero),
  .Overflow(Overflow),
  .Underflow(Underflow),
  .Inexact(Inexact),
  .ExceptionVector(ExceptionVector),
  .Greater(Greater),
  .Equal(Equal),
  .Lesser(Lesser),
  .Unordered(Unordered));

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

 // Generate a One-Cycle Clear Pulse
 task PulseClear;
 begin
    @(negedge clk);
    Clear = 1'b1;
    @(negedge clk);
    Clear = 1'b0;
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

    clk = 1'b0;
    reset = 1'b1;
    Start = 1'b0;
    Clear = 1'b0;

    Operation = `FP16_OP_ADD;

    OperandA = `FP16_POSITIVE_ZERO;
    OperandB = `FP16_POSITIVE_ZERO;

    // Reset the Arithmetic Engine
    #20;

    @(negedge clk);
    reset = 1'b0;


    // FP16 ARITHMETIC TESTS


    // Test 1: Basic Addition
    // FP16 Values:
    // 16'h3E00 = 1.5
    // 16'h4100 = 2.5
    // 1.5 + 2.5 = 4.0
    // Expected FP16 Result = 16'h4400
    Operation = `FP16_OP_ADD;
    OperandA = 16'h3E00;
    OperandB = 16'h4100;

    PulseStart;
    #1;

    if (Result == 16'h4400)
        $display("FP16 ADD PASSED");
    else
        $display("FP16 ADD FAILED: Result = %h", Result);


    // Test 2: Basic Subtraction
    // FP16 Values:
    // 16'h4500 = 5.0
    // 16'h4100 = 2.5
    // 5.0 - 2.5 = 2.5
    // Expected FP16 Result = 16'h4100
    Operation = `FP16_OP_SUBTRACT;
    OperandA = 16'h4500;
    OperandB = 16'h4100;

    PulseStart;
    #1;

    if (Result == 16'h4100)
        $display("FP16 SUBTRACT PASSED");
    else
        $display("FP16 SUBTRACT FAILED: Result = %h", Result);


    // Test 3: Positive Comparison
    // FP16 Values:
    // 16'h4200 = 3.0
    // 16'h4000 = 2.0
    // 3.0 > 2.0
    // Expected Greater = 1
    // Expected Equal = 0
    // Expected Lesser = 0
    // Expected Unordered = 0
    Operation = `FP16_OP_COMPARE;
    OperandA = 16'h4200;
    OperandB = 16'h4000;

    PulseStart;
    #1;

    if ((Greater == 1'b1) &&
        (Equal == 1'b0) &&
        (Lesser == 1'b0) &&
        (Unordered == 1'b0))
        $display("FP16 COMPARE GREATER PASSED");
    else
        $display("FP16 COMPARE GREATER FAILED");


    // Test 4: Signed Comparison
    // FP16 Values:
    // 16'hC000 = -2.0
    // 16'h3C00 = 1.0
    // -2.0 < 1.0
    // Expected Greater = 0
    // Expected Equal = 0
    // Expected Lesser = 1
    // Expected Unordered = 0
    Operation = `FP16_OP_COMPARE;
    OperandA = 16'hC000;
    OperandB = 16'h3C00;

    PulseStart;
    #1;

    if ((Greater == 1'b0) &&
        (Equal == 1'b0) &&
        (Lesser == 1'b1) &&
        (Unordered == 1'b0))
        $display("FP16 SIGNED COMPARE PASSED");
    else
        $display("FP16 SIGNED COMPARE FAILED");


    // Test 5: Combinational Multiplication
    // FP16 Values:
    // 16'h3E00 = 1.5
    // 16'h4000 = 2.0
    // 1.5 * 2.0 = 3.0
    // Expected FP16 Result = 16'h4200
    Operation = `FP16_OP_MULTIPLY;
    OperandA = 16'h3E00;
    OperandB = 16'h4000;

    PulseStart;
    #1;

    if (Result == 16'h4200)
        $display("FP16 COMBINATIONAL MULTIPLY PASSED");
    else
        $display("FP16 COMBINATIONAL MULTIPLY FAILED: Result = %h",
                 Result);


    // Test 6: Negative Multiplication
    // FP16 Values:
    // 16'hBE00 = -1.5
    // 16'h4000 = 2.0
    // -1.5 * 2.0 = -3.0
    // Expected FP16 Result = 16'hC200
    Operation = `FP16_OP_MULTIPLY;
    OperandA = 16'hBE00;
    OperandB = 16'h4000;

    PulseStart;
    #1;

    if (Result == 16'hC200)
        $display("FP16 NEGATIVE MULTIPLY PASSED");
    else
        $display("FP16 NEGATIVE MULTIPLY FAILED: Result = %h",
                 Result);


    // Test 7: Sequential Multiplication
    // FP16 Values:
    // 16'h4200 = 3.0
    // 16'h4400 = 4.0
    // 3.0 * 4.0 = 12.0
    // Expected FP16 Result = 16'h4A00
    Operation = `FP16_OP_SEQUENTIAL_MULTIPLY;
    OperandA = 16'h4200;
    OperandB = 16'h4400;

    PulseStart;
    WaitForDone;
    #1;

    if (Result == 16'h4A00)
        $display("FP16 SEQUENTIAL MULTIPLY PASSED");
    else
        $display("FP16 SEQUENTIAL MULTIPLY FAILED: Result = %h",
                 Result);


    // Test 8: FP16 Division
    // FP16 Values:
    // 16'h4900 = 10.0
    // 16'h4200 = 3.0
    // 10.0 / 3.0 = 3.333...
    // Expected FP16 Result = 16'h42AB
    Operation = `FP16_OP_DIVIDE;
    OperandA = 16'h4900;
    OperandB = 16'h4200;

    PulseStart;
    WaitForDone;
    #1;

    if (Result == 16'h42AB)
        $display("FP16 DIVIDE PASSED");
    else
        $display("FP16 DIVIDE FAILED: Result = %h", Result);


    // Test 9: Division by Zero
    // FP16 Values:
    // 16'h4000 = 2.0
    // FP16_POSITIVE_ZERO = 0.0
    // 2.0 / 0.0 = Positive Infinity
    // Expected FP16 Result = FP16_POSITIVE_INFINITY
    // Expected DivideByZero = 1
    Operation = `FP16_OP_DIVIDE;
    OperandA = 16'h4000;
    OperandB = `FP16_POSITIVE_ZERO;

    PulseStart;
    WaitForDone;
    #1;

    if ((Result == `FP16_POSITIVE_INFINITY) &&
        (DivideByZero == 1'b1))
        $display("FP16 DIVIDE BY ZERO PASSED");
    else
        $display("FP16 DIVIDE BY ZERO FAILED: Result = %h DivideByZero = %b",
                 Result, DivideByZero);


    // Test 10: FP16 Square Root
    // FP16 Value:
    // 16'h4900 = 10.0
    // sqrt(10.0) = 3.162...
    // Expected FP16 Result = 16'h4253
    Operation = `FP16_OP_SQUARE_ROOT;
    OperandA = 16'h4900;
    OperandB = `FP16_POSITIVE_ZERO;

    PulseStart;
    WaitForDone;
    #1;

    if (Result == 16'h4253)
        $display("FP16 SQUARE ROOT PASSED");
    else
        $display("FP16 SQUARE ROOT FAILED: Result = %h",
                 Result);


    // Test 11: Negative Square Root
    // FP16 Value:
    // 16'hC400 = -4.0
    // sqrt(-4.0) is Invalid for a Real FP16 Result
    // Expected Result = FP16_CANONICAL_QNAN
    // Expected InvalidOperation = 1
    Operation = `FP16_OP_SQUARE_ROOT;
    OperandA = 16'hC400;
    OperandB = `FP16_POSITIVE_ZERO;

    PulseStart;
    WaitForDone;
    #1;

    if ((InvalidOperation == 1'b1) &&
        (Result == `FP16_CANONICAL_QNAN))
        $display("FP16 NEGATIVE SQUARE ROOT PASSED");
    else
        $display("FP16 NEGATIVE SQUARE ROOT FAILED: Result = %h Invalid = %b",
                 Result, InvalidOperation);


    // Test 12: FP16 Accumulation
    // Clear Accumulator Before Starting
    //
    // FP16 Values:
    // 16'h3C00 = 1.0
    // 16'h4000 = 2.0
    // 16'h4200 = 3.0
    //
    // 1.0 + 2.0 + 3.0 = 6.0
    // Expected FP16 Result = 16'h4600
    Operation = `FP16_OP_ACCUMULATE;

    PulseClear;

    OperandA = 16'h3C00;
    PulseStart;

    OperandA = 16'h4000;
    PulseStart;

    OperandA = 16'h4200;
    PulseStart;

    #1;

    if (Result == 16'h4600)
        $display("FP16 ACCUMULATOR PASSED");
    else
        $display("FP16 ACCUMULATOR FAILED: Result = %h",
                 Result);


    // Test 13: FP16 Wide Accumulation
    // Clear Wide Accumulator Before Starting
    //
    // FP16 Input Values:
    // 16'h3C00 = 1.0
    // 16'h4000 = 2.0
    // 16'h4200 = 3.0
    //
    // 1.0 + 2.0 + 3.0 = 6.0
    // Expected FP32 Wide Result = 32'h40C00000
    Operation = `FP16_OP_WIDE_ACCUMULATE;

    PulseClear;

    OperandA = 16'h3C00;
    PulseStart;

    OperandA = 16'h4000;
    PulseStart;

    OperandA = 16'h4200;
    PulseStart;

    #1;

    if (WideResult == 32'h40C00000)
        $display("FP16 WIDE ACCUMULATOR PASSED");
    else
        $display("FP16 WIDE ACCUMULATOR FAILED: WideResult = %h",
                 WideResult);


    // Test 14: FP16 Multiply-Accumulate
    // Clear MAC Accumulator Before Starting
    //
    // First Operation:
    // 16'h3E00 = 1.5
    // 16'h4000 = 2.0
    // 1.5 * 2.0 = 3.0
    //
    // Second Operation:
    // 16'h4000 = 2.0
    // 16'h4200 = 3.0
    // 2.0 * 3.0 = 6.0
    //
    // Accumulated Result = 3.0 + 6.0 = 9.0
    // Expected FP16 Result = 16'h4880
    Operation = `FP16_OP_MAC;

    PulseClear;

    OperandA = 16'h3E00;
    OperandB = 16'h4000;
    PulseStart;

    OperandA = 16'h4000;
    OperandB = 16'h4200;
    PulseStart;

    #1;

    if (Result == 16'h4880)
        $display("FP16 MAC PASSED");
    else
        $display("FP16 MAC FAILED: Result = %h",
                 Result);


    // Test 15: Running Product Initialization
    // Clear Running Product Before Starting
    // Clear Restores the Running Product to FP16 1.0
    // FP16 Representation of 1.0 = 16'h3C00
    // Expected FP16 Result = 16'h3C00
    Operation = `FP16_OP_RUNNING_PRODUCT;

    PulseClear;

    #1;

    if (Result == 16'h3C00)
        $display("FP16 RUNNING PRODUCT INITIALIZATION PASSED");
    else
        $display("FP16 RUNNING PRODUCT INITIALIZATION FAILED: Result = %h",
                 Result);


    // Test 16: FP16 Running Product
    // Running Product Starts at 1.0
    //
    // FP16 Input Values:
    // 16'h4000 = 2.0
    // 16'h4200 = 3.0
    // 16'h4400 = 4.0
    //
    // Initial = 1.0
    // 1.0 * 2.0 = 2.0
    // 2.0 * 3.0 = 6.0
    // 6.0 * 4.0 = 24.0
    //
    // Expected FP16 Result = 16'h4E00
    OperandA = 16'h4000;
    PulseStart;
    WaitForDone;

    OperandA = 16'h4200;
    PulseStart;
    WaitForDone;

    OperandA = 16'h4400;
    PulseStart;
    WaitForDone;

    #1;

    if (Result == 16'h4E00)
        $display("FP16 RUNNING PRODUCT PASSED");
    else
        $display("FP16 RUNNING PRODUCT FAILED: Result = %h",
                 Result);


    // Test 17: Running Product Clear
    // Clear Restores the Running Product to FP16 1.0
    // FP16 Representation of 1.0 = 16'h3C00
    // Expected FP16 Result = 16'h3C00
    PulseClear;

    #1;

    if (Result == 16'h3C00)
        $display("FP16 RUNNING PRODUCT CLEAR PASSED");
    else
        $display("FP16 RUNNING PRODUCT CLEAR FAILED: Result = %h",
                 Result);


    // FP16 SPECIAL-CASE AND EXCEPTION TESTS


    // Test 18: Invalid Addition
    // Positive Infinity + Negative Infinity is Undefined
    // Expected Result = FP16_CANONICAL_QNAN
    // Expected InvalidOperation = 1
    Operation = `FP16_OP_ADD;
    OperandA = `FP16_POSITIVE_INFINITY;
    OperandB = `FP16_NEGATIVE_INFINITY;

    PulseStart;
    #1;

    if ((InvalidOperation == 1'b1) &&
        (Result == `FP16_CANONICAL_QNAN))
        $display("FP16 INVALID ADDITION PASSED");
    else
        $display("FP16 INVALID ADDITION FAILED: Result = %h Invalid = %b",
                 Result, InvalidOperation);


    // Test 19: Invalid Multiplication
    // 0.0 * Positive Infinity is Undefined
    // Expected Result = FP16_CANONICAL_QNAN
    // Expected InvalidOperation = 1
    Operation = `FP16_OP_MULTIPLY;
    OperandA = `FP16_POSITIVE_ZERO;
    OperandB = `FP16_POSITIVE_INFINITY;

    PulseStart;
    #1;

    if ((InvalidOperation == 1'b1) &&
        (Result == `FP16_CANONICAL_QNAN))
        $display("FP16 INVALID MULTIPLICATION PASSED");
    else
        $display("FP16 INVALID MULTIPLICATION FAILED: Result = %h Invalid = %b",
                 Result, InvalidOperation);


    // Test 20: NaN Comparison
    // Comparing NaN with 1.0 Produces an Unordered Result
    // FP16_CANONICAL_QNAN = Quiet NaN
    // 16'h3C00 = 1.0
    // Expected Unordered = 1
    Operation = `FP16_OP_COMPARE;
    OperandA = `FP16_CANONICAL_QNAN;
    OperandB = 16'h3C00;

    PulseStart;
    #1;

    if (Unordered == 1'b1)
        $display("FP16 NAN COMPARE PASSED");
    else
        $display("FP16 NAN COMPARE FAILED");


    $display("------------------------------------------");
    $display("FP16 ARITHMETIC ENGINE TESTBENCH COMPLETE");
    $display("------------------------------------------");

    #20;
    $finish;

 end

endmodule

