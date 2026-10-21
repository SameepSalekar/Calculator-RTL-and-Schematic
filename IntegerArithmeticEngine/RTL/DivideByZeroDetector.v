`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:03:15 PM
// Design Name: 
// Module Name: DivideByZeroDetector
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

module DivideByZeroDetector
#(parameter WIDTH = 8)
( input wire [WIDTH - 1:0] Divisor,
  output wire DivideByZero);
  
  assign DivideByZero = (~|(Divisor));
  
endmodule
