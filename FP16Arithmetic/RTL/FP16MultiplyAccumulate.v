`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 02:48:02 AM
// Design Name: 
// Module Name: FP16MultiplyAccumulate
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

module FP16MultiplyAccumulate( input wire clk,
                               input wire reset,
                               input wire enable,
                               input wire [`FP16_WIDTH - 1:0] OperandA,
                               input wire [`FP16_WIDTH - 1:0] OperandB,
                               output reg [`FP16_WIDTH - 1:0] Sum,
                               output reg InvalidOperation,
                               output reg Overflow,
                               output reg Underflow,
                               output reg Inexact,
                               output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);
        
       wire [`FP16_WIDTH - 1:0] Product;
       wire MultiplicationInvalidOperation;
       wire MultiplicationOverflow;
       wire MultiplicationUnderflow;
       wire MultiplicationInexact;
       wire [`FP16_EXCEPTION_WIDTH - 1:0] MultiplicationExceptionVector;
       
       wire [`FP16_WIDTH - 1:0] NextSum;
       wire AdditionInvalidOperation;
       wire AdditionOverflow;
       wire AdditionUnderflow;
       wire AdditionInexact;
       wire [`FP16_EXCEPTION_WIDTH - 1:0] AdditionExceptionVector;
       
       wire CombinedInvalidOperation;
       wire CombinedOverflow;
       wire CombinedUnderflow;
       wire CombinedInexact;
       
       FP16CombinationalMultiplier Multiplier (.OperandA(OperandA), .OperandB(OperandB), .Result(Product), 
                                               .InvalidOperation(MultiplicationInvalidOperation), 
                                               .Overflow(MultiplicationOverflow), .Underflow(MultiplicationUnderflow),
                                               .Inexact(MultiplicationInexact), .ExceptionVector(MultiplicationExceptionVector));
                                               
       FP16AddSub AccumulatorAdder (.OperandA(Sum), .OperandB(Product), .Subtract(1'b0), .Result(NextSum), 
                                    .InvalidOperation(AdditionInvalidOperation), .Overflow(AdditionOverflow), 
                                    .Underflow(AdditionUnderflow), .Inexact(AdditionInexact), 
                                    .ExceptionVector(AdditionExceptionVector));
                                    
       assign CombinedInvalidOperation = MultiplicationInvalidOperation | AdditionInvalidOperation;
       
       assign CombinedOverflow = MultiplicationOverflow | AdditionOverflow;                             
                                         
       assign CombinedUnderflow = MultiplicationUnderflow | AdditionUnderflow;

       assign CombinedInexact = MultiplicationInexact | AdditionInexact;
       
       always @(posedge clk) begin
        if (reset) begin
            Sum <= `FP16_POSITIVE_ZERO;
            InvalidOperation <= 1'b0;
            Overflow <= 1'b0;
            Underflow <= 1'b0;
            Inexact <= 1'b0;
        end
        else 
            if (enable) begin
                Sum <= NextSum;
                InvalidOperation <= CombinedInvalidOperation;
                Overflow <= CombinedOverflow;
                Underflow <= CombinedUnderflow;
                Inexact <= CombinedInexact;
            end
       end
       
       assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact};     
endmodule
