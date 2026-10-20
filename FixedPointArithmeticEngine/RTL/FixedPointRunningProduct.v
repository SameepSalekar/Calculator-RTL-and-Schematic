`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 07:53:28 PM
// Design Name: 
// Module Name: FixedPointRunningProduct
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


module FixedPointRunningProduct
#(parameter WIDTH = 8,
  parameter FRACTIONAL_BITS = 4)  
 (input wire clk,
  input wire reset,
  input wire Start,
  input wire Clear,
  input wire SignedMode,
  input wire [WIDTH - 1:0] OperandIn,
  output reg [WIDTH - 1:0] RunningProduct,
  output reg Busy,
  output reg Done);
  
  reg [WIDTH - 1:0] CurrentProduct;
  wire [(2 * WIDTH) - 1:0] MultiplierResult;
  wire [(2 * WIDTH) - 1:0] ScaledProduct;
  wire MultiplierBusy;
  wire MultiplierDone;
  reg MultiplierStart;
  
  assign ScaledProduct = (SignedMode) ? $signed(MultiplierResult) >>> FRACTIONAL_BITS : MultiplierResult >> FRACTIONAL_BITS;
  
  SequentialMultiplier #(.WIDTH(WIDTH)) RunningProductMultiplier (.clk(clk), .reset(reset), .START(MultiplierStart),
                                                                  .SignedMode(SignedMode), .A(CurrentProduct),
                                                                  .B(OperandIn), .Product(MultiplierResult),
                                                                  .BUSY(MultiplierBusy), .DONE(MultiplierDone));
                                                                  
  always@(posedge clk) begin
    if (reset) begin
        CurrentProduct <= {{(WIDTH - FRACTIONAL_BITS - 1){1'b0}}, 1'b1, {FRACTIONAL_BITS{1'b0}}};
        RunningProduct <= {{(WIDTH - FRACTIONAL_BITS - 1){1'b0}}, 1'b1, {FRACTIONAL_BITS{1'b0}}};
        MultiplierStart <= 1'b0;
        Busy <= 1'b0;
        Done <= 1'b0;
    end
    else
    begin
        MultiplierStart <= 1'b0;
        Done <= 1'b0;
        if (Clear && !Busy) begin
            CurrentProduct <= {{(WIDTH - FRACTIONAL_BITS - 1){1'b0}}, 1'b1, {FRACTIONAL_BITS{1'b0}}};
            RunningProduct <= {{(WIDTH - FRACTIONAL_BITS - 1){1'b0}}, 1'b1, {FRACTIONAL_BITS{1'b0}}};
        end
        else
            if (Start && !Busy) begin
            MultiplierStart <= 1'b1;
            Busy <= 1'b1;
            end
            else
                if (MultiplierDone && Busy) begin
                    CurrentProduct <= ScaledProduct[WIDTH - 1:0];
                    RunningProduct <= ScaledProduct[WIDTH - 1:0];
                    Busy <= 1'b0;
                    Done <= 1'b1;
                end        
        end
  end 
endmodule
