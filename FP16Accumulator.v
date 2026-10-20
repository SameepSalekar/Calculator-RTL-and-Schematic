`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/09/2026 02:28:14 AM
// Design Name: 
// Module Name: FP16Accumulator
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

module FP16Accumulator( input wire clk,
                        input wire reset,
                        input wire enable,
                        input wire [`FP16_WIDTH - 1:0] X,
                        output reg [`FP16_WIDTH - 1:0] Sum,
                        output reg InvalidOperation,
                        output reg Overflow,
                        output reg Underflow,
                        output reg Inexact,
                        output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);
                        
       wire [`FP16_WIDTH - 1:0] AdditionResult;
       wire AdditionInvalidOperation;
       wire AdditionOverflow;
       wire AdditionUnderflow;
       wire AdditionInexact;
       wire [`FP16_EXCEPTION_WIDTH - 1:0] AdditionExceptionVector;
       
       FP16AddSub AccumulatorAdder (.OperandA(Sum), .OperandB(X), .Subtract(1'b0), .Result(AdditionResult),
                                    .InvalidOperation(AdditionInvalidOperation), .Overflow(AdditionOverflow),
                                    .Underflow(AdditionUnderflow), .Inexact(AdditionInexact), .ExceptionVector(AdditionExceptionVector));
       
       always@(*)begin
        if(reset)begin
            Sum <= `FP16_POSITIVE_ZERO;
            InvalidOperation <= 1'b0;
            Overflow <= 1'b0;
            Underflow <= 1'b0;
            Inexact <= 1'b0; 
        end
        else
            if(enable)begin
                Sum <= AdditionResult;
                InvalidOperation <= AdditionInvalidOperation;
                Overflow <= AdditionOverflow;
                Underflow <= AdditionUnderflow;
                Inexact <= AdditionInexact;
            end    
       end                             
       
       assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact};
       
endmodule
