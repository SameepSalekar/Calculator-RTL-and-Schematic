`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 04:27:07 PM
// Design Name: 
// Module Name: topModule
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


module topModule
# (parameter WIDTH = 4)
( input wire [WIDTH - 1:0] A,
  input wire [WIDTH - 1:0] B,
  input wire Subtractor,
  output wire [WIDTH - 1:0] result,
  output wire zero,
  output wire negative,
  output wire carry,
  output wire overflow);
 
 wire [WIDTH - 1:0] B_new;
 wire [WIDTH - 1:0] propagators;
 wire [WIDTH - 1:0] generators;
 reg [WIDTH:0] carriers;
 
 reg PropagatedSoFar;
 reg GeneratedBehavior;
 wire arithmetic_carry;
 wire arithmetic_overflow;
 
 assign B_new = B ^ {WIDTH{Subtractor}};
 assign propagators = A ^ B_new;
 assign generators = A & B_new;
 
 integer i;
 integer j;
 
 always@(*)begin
    carriers[0] = Subtractor;
    for (i = 1; i <= WIDTH; i = i + 1) begin
        GeneratedBehavior = 1'b0;
        PropagatedSoFar = 1'b1;
        for(j = i - 1; j >= 0; j = j - 1) begin
            GeneratedBehavior = GeneratedBehavior | (PropagatedSoFar & generators[j]);
            PropagatedSoFar = PropagatedSoFar & propagators[j];
        end
        GeneratedBehavior = GeneratedBehavior | (PropagatedSoFar & Subtractor);
        carriers[i] = GeneratedBehavior;
    end
 end   
 
 assign result = propagators ^ carriers[WIDTH - 1:0];
 assign arithmetic_carry = carriers[WIDTH];
 assign arithmetic_overflow = carriers[WIDTH - 1] ^ carriers[WIDTH];
 
 ArithmeticStatusUnit #(.WIDTH(WIDTH))
 StatusUnit (.result(result), .carry_in(arithmetic_carry), .overflow_in(arithmetic_overflow), .zero(zero), .negative(negative), .carry(carry), .overflow(overflow));
 
endmodule
