`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 07:41:55 PM
// Design Name: 
// Module Name: FixedPointMultiplyAccumulate
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


module FixedPointMultiplyAccumulate
#(parameter WIDTH = 8,
  parameter FRACTIONAL_BITS = 4)
 (input wire clk,
  input wire reset,
  input wire enable,
  input wire Clear,
  input wire SignedMode,
  input wire [WIDTH - 1:0] A,
  input wire [WIDTH - 1:0] B,
  output reg [WIDTH - 1:0] Sum);
  
  wire [(2 * WIDTH) - 1:0] Product;
  wire [(2 * WIDTH) - 1:0] ScaledProduct;
  wire [WIDTH - 1:0] AccumulationValue;
  
  CombinationalMultiplier #(.WIDTH(WIDTH)) MultiplierUnit(.A(A), .B(B), .SignedMode(SignedMode), .Product(Product));
  
  assign ScaledProduct = (SignedMode) ? $signed(Product) >>> FRACTIONAL_BITS : Product >> FRACTIONAL_BITS;
  
  assign AccumulationValue = ScaledProduct[WIDTH - 1:0];
  
  always@(posedge clk)begin
    if(reset)begin
        Sum <= {WIDTH{1'b0}};
    end
    else
        if (Clear) begin
            Sum <= {WIDTH{1'b0}};
        end
        else
            if (enable) begin
                Sum <= Sum + AccumulationValue;
            end
  end
endmodule
