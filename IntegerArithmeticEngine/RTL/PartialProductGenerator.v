`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:10:03 PM
// Design Name: 
// Module Name: PartialProductGenerator
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


module PartialProductGenerator
#(parameter WIDTH = 8)
( input wire [WIDTH - 1:0]A,
  input wire [WIDTH - 1:0]B,
  output wire [(2 * WIDTH * WIDTH) - 1:0] PartialProducts);

wire [(2 * WIDTH) - 1:0] ExtendedA;

assign ExtendedA = {{WIDTH{1'b0}}, A};

genvar i;
generate
    for (i = 0; i < WIDTH; i = i + 1) begin: PARTIAL_PRODUCT_BLOCK
        assign PartialProducts[(i * 2 * WIDTH) +: (2 * WIDTH)] = (B[i]) ? (ExtendedA << i) : {(2 * WIDTH){1'b0}};
    end
endgenerate    
endmodule
