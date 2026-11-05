`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 10:14:54 PM
// Design Name: 
// Module Name: FP32WideAccumulator
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

module FP32WideAccumulator( input wire clk,
                            input wire reset,
                            input wire enable,
                            input wire [`FP16_WIDTH - 1:0] X,
                            output reg [31:0] Sum,
                            output reg InvalidOperation,
                            output reg Overflow,
                            output reg Underflow,
                            output reg Inexact,
                            output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);
       
       wire [31:0] ConvertedInput;
       
       wire [31:0] NextSum;
       wire AdditionInvalidOperation;
       wire AdditionOverflow;
       wire AdditionUnderflow;
       wire AdditionInexact;
       wire [`FP16_EXCEPTION_WIDTH - 1:0] AdditionExceptionVector;
       
       FP16toFP32Converter ConvertingUnit(.FP16Value(X), .FP32Value(ConvertedInput));
       
       FP32AccumulatorAdder WideAdder (.OperandA(Sum), .OperandB(ConvertedInput), .Result(NextSum), 
                                       .InvalidOperation(AdditionInvalidOperation), .Overflow(AdditionOverflow),
                                       .Underflow(AdditionUnderflow), .Inexact(AdditionInexact), 
                                       .ExceptionVector(AdditionExceptionVector));             
       
       always@(posedge clk)begin
        if (reset) begin
            Sum <= 32'h00000000;
            InvalidOperation <= 1'b0;
            Overflow <= 1'b0;
            Underflow <= 1'b0;
            Inexact <= 1'b0;
        end
        else
            if (enable) begin
                Sum <= NextSum;
                InvalidOperation <= AdditionInvalidOperation;
                Overflow <= AdditionOverflow;
                Underflow <= AdditionUnderflow;
                Inexact <= AdditionInexact;
            end
       end
       
       assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact};                
        
endmodule
