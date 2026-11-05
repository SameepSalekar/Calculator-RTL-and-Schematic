`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 10:41:38 PM
// Design Name: 
// Module Name: FP16WideAccumulator
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

module FP16WideAccumulator( input wire clk,
                            input wire reset,
                            input wire enable,
                            input wire Clear,
                            input wire [`FP16_WIDTH - 1:0] X,
                            output wire [31:0] Sum,
                            output wire InvalidOperation,
                            output wire Overflow,
                            output wire Underflow,
                            output wire Inexact,
                            output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);
                            
       wire AccumulatorReset;
       
       assign AccumulatorReset = reset | Clear;
       
       FP32WideAccumulator WideAccumulator (.clk(clk), .reset(AccumulatorReset), .enable(enable), .X(X), .Sum(Sum),
                                            .InvalidOperation(InvalidOperation), .Overflow(Overflow), .Underflow(Underflow),
                                            .Inexact(Inexact), .ExceptionVector(ExceptionVector));
                                                                 
endmodule
