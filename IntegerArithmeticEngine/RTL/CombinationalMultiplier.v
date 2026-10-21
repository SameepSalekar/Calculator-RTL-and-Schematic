`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:14:49 PM
// Design Name: 
// Module Name: CombinationalMultiplier
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


module CombinationalMultiplier
# (parameter WIDTH = 8)
( input wire [WIDTH - 1:0] A,
  input wire [WIDTH - 1:0] B,
  input wire SignedMode,
  output wire [(2 * WIDTH) - 1:0] Product
  );
 wire [WIDTH - 1:0] MagnitudeA;
 wire [WIDTH - 1:0] MagnitudeB;
 
 wire [(2 * WIDTH * WIDTH) - 1:0] PartialProducts;
 reg [(2 * WIDTH) - 1:0] MagnitudeProduct;
 wire NegativeProduct;
 integer i;
 
 assign MagnitudeA = (SignedMode && A[WIDTH - 1])?(~A + 1'b1):A;
 assign MagnitudeB = (SignedMode && B[WIDTH - 1])?(~B + 1'b1):B;
 
 assign NegativeProduct = SignedMode && (A[WIDTH - 1] ^ B[WIDTH - 1]);
 
 PartialProductGenerator #(.WIDTH(WIDTH))
 PartialProductUnit (.A(MagnitudeA), .B(MagnitudeB), .PartialProducts(PartialProducts));
 
 always@(*)begin
    MagnitudeProduct = {(2 * WIDTH){1'b0}};
    for (i = 0; i < WIDTH; i = i + 1) begin
        MagnitudeProduct = MagnitudeProduct + PartialProducts[(i * 2 * WIDTH) +: (2 * WIDTH)];
    end
 end       
  
 assign Product = (NegativeProduct)?(~MagnitudeProduct + 1'b1): MagnitudeProduct;
endmodule
