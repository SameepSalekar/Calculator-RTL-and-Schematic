`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 12:01:27 AM
// Design Name: 
// Module Name: IntegerRunningProduct
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


module IntegerRunningProduct
#(parameter WIDTH = 8)
(input wire clk,
 input wire reset,
 input wire Start,
 input wire Clear,
 input wire SignedMode,
 input wire [WIDTH - 1:0] OperandIn,
 output reg [(2 * WIDTH) - 1:0] RunningProduct,
 output reg Busy,
 output reg Done);
 
 reg [(2 * WIDTH) - 1:0] CurrentProduct;
 wire [(2 * WIDTH) - 1:0] ExtendedOperand;
 wire [(4 * WIDTH) - 1:0] MultiplierResult;
 wire MultiplierBusy;
 wire MultiplierDone;
 reg MultiplierStart;
 
 assign ExtendedOperand = (SignedMode) ? {{WIDTH{OperandIn[WIDTH - 1]}}, OperandIn}:
                                         {{WIDTH{1'b0}}, OperandIn};
 
 SequentialMultiplier #(.WIDTH(2 * WIDTH))
 RunningProductMultiplier (.clk(clk), .reset(reset), .START(MultiplierStart),
                           .SignedMode(SignedMode), .A(CurrentProduct),
                           .B(ExtendedOperand), .Product(MultiplierResult),
                           .BUSY(MultiplierBusy), .DONE(MultiplierDone));
                                                                  
 always @(posedge clk) begin
    if (reset) begin
        CurrentProduct <= {{((2 * WIDTH) - 1){1'b0}}, 1'b1};
        RunningProduct <= {{((2 * WIDTH) - 1){1'b0}}, 1'b1};
        MultiplierStart <= 1'b0;
        Busy <= 1'b0;
        Done <= 1'b0;
    end
    else
    begin
        MultiplierStart <= 1'b0;
        Done <= 1'b0;
        if (Clear && !Busy) begin
            CurrentProduct <= {{((2 * WIDTH) - 1){1'b0}}, 1'b1};
            RunningProduct <= {{((2 * WIDTH) - 1){1'b0}}, 1'b1};
        end
        else
            if (Start && !Busy) begin
                MultiplierStart <= 1'b1;
                Busy <= 1'b1;
            end
            else
                if (MultiplierDone && Busy) begin
                    CurrentProduct <= MultiplierResult[(2 * WIDTH) - 1:0];
                    RunningProduct <= MultiplierResult[(2 * WIDTH) - 1:0];
                    Busy <= 1'b0;
                    Done <= 1'b1;
                end
    end
 end
 
endmodule
