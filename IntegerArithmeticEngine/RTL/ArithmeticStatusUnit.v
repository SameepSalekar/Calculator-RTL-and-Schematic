`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:20:25 PM
// Design Name: 
// Module Name: ArithmeticStatusUnit
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

module ArithmeticStatusUnit
# (parameter WIDTH = 8)
(input wire [WIDTH - 1:0] result,
  input wire carry_in,
  input wire overflow_in,
  output wire zero,
  output wire negative,
  output wire carry,
  output wire overflow);
  
  assign zero = (~|(result));
  assign negative = result[WIDTH-1];
  assign carry = carry_in;
  assign overflow = overflow_in;

endmodule