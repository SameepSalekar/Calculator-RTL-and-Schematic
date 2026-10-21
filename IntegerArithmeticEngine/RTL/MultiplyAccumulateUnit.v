`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 10:46:14 PM
// Design Name: 
// Module Name: MultiplyAccumulateUnit
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

module MultiplyAccumulateUnit
#(parameter WIDTH = 8,
  parameter ACC_WIDTH  = 2 * WIDTH)
( input wire clk,
  input wire reset,
  input wire enable,
  input wire SignedMode,
  input wire [WIDTH - 1:0] A,
  input wire [WIDTH - 1:0] B,
  output reg [ACC_WIDTH - 1:0] Sum);
  
  wire [(2 * WIDTH) - 1:0] Product;
  wire signed [WIDTH - 1:0] SignedA;
  wire signed [WIDTH - 1:0] SignedB;
  wire signed [(2 * WIDTH) - 1:0] SignedProduct;
  wire [(2 * WIDTH) - 1:0] UnsignedProduct;
  wire [ACC_WIDTH - 1:0] ExtendedUnsignedProduct;
  wire [ACC_WIDTH - 1:0] ExtendedSignedProduct;
  
  assign SignedA = A;
  assign SignedB = B;
  
  assign UnsignedProduct = A * B;
  assign SignedProduct = SignedA * SignedB;
  assign Product = (SignedMode)?SignedProduct:UnsignedProduct;

  assign ExtendedUnsignedProduct = {{(ACC_WIDTH - (2 * WIDTH)){1'b0}}, Product};
  assign ExtendedSignedProduct = {{(ACC_WIDTH - (2 * WIDTH)){Product[(2 * WIDTH) - 1]}}, Product};
  
  always@(posedge clk)begin
    if (reset) begin
        Sum <= {ACC_WIDTH{1'b0}};
    end
    else 
    begin
        if (enable) begin
            if (SignedMode)
                Sum <= Sum + ExtendedSignedProduct;
            else
                Sum <= Sum + ExtendedUnsignedProduct;
        end
    end
  end                      
endmodule