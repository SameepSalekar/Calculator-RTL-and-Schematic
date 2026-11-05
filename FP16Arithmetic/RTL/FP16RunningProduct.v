`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2026 09:15:26 PM
// Design Name: 
// Module Name: FP16RunningProduct
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

module FP16RunningProduct( input wire clk,
                           input wire reset,
                           input wire Start,
                           input wire Clear,
                           input wire [`FP16_WIDTH - 1:0] OperandIn,
                           output reg [`FP16_WIDTH - 1:0] RunningProduct,
                           output reg Busy,
                           output reg Done,
                           output reg InvalidOperation,
                           output reg Overflow,
                           output reg Underflow,
                           output reg Inexact,
                           output reg [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector );

      reg [`FP16_WIDTH - 1:0] CurrentProduct;
      reg MultiplierStart;

      wire [`FP16_WIDTH - 1:0] MultiplierResult;
      wire MultiplierBusy;
      wire MultiplierDone;
      wire MultiplierInvalidOperation;
      wire MultiplierOverflow;
      wire MultiplierUnderflow;
      wire MultiplierInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] MultiplierExceptionVector;

      FP16SequentialMultiplier RunningProductMultiplier (.clk(clk), .reset(reset), .START(MultiplierStart),
                                                         .OperandA(CurrentProduct), .OperandB(OperandIn),
                                                         .Result(MultiplierResult), .BUSY(MultiplierBusy),
                                                         .DONE(MultiplierDone), .InvalidOperation(MultiplierInvalidOperation),
                                                         .Overflow(MultiplierOverflow), .Underflow(MultiplierUnderflow),
                                                         .Inexact(MultiplierInexact), .ExceptionVector(MultiplierExceptionVector));

      always @(posedge clk) begin
        if (reset) begin
            CurrentProduct <= 16'h3C00;
            RunningProduct <= 16'h3C00;
            MultiplierStart <= 1'b0;
            Busy <= 1'b0;
            Done <= 1'b0;
            InvalidOperation <= 1'b0;
            Overflow <= 1'b0;
            Underflow <= 1'b0;
            Inexact <= 1'b0;
            ExceptionVector <= {`FP16_EXCEPTION_WIDTH{1'b0}};
        end
        else 
        begin
            MultiplierStart <= 1'b0;
            Done <= 1'b0;

            if (Clear && !Busy) begin
                CurrentProduct <= 16'h3C00;
                RunningProduct <= 16'h3C00;
                Busy <= 1'b0;
                InvalidOperation <= 1'b0;
                Overflow <= 1'b0;
                Underflow <= 1'b0;
                Inexact <= 1'b0;
                ExceptionVector <= {`FP16_EXCEPTION_WIDTH{1'b0}};
            end
            else 
                if (Start && !Busy) begin
                    MultiplierStart <= 1'b1;
                    Busy <= 1'b1;
                    InvalidOperation <= 1'b0;
                    Overflow <= 1'b0;
                    Underflow <= 1'b0;
                    Inexact <= 1'b0;
                    ExceptionVector <= {`FP16_EXCEPTION_WIDTH{1'b0}};
                end
                else 
                    if (MultiplierDone && Busy) begin
                        CurrentProduct <= MultiplierResult;
                        RunningProduct <= MultiplierResult;
                        Busy <= 1'b0;
                        Done <= 1'b1;
                        InvalidOperation <= MultiplierInvalidOperation;
                        Overflow <= MultiplierOverflow;
                        Underflow <= MultiplierUnderflow;
                        Inexact <= MultiplierInexact;
                        ExceptionVector <= MultiplierExceptionVector;
                    end
                end
      end
endmodule
