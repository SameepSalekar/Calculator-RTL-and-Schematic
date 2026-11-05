`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 06:43:50 PM
// Design Name: 
// Module Name: FP16LeadingZeroCounter
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

module FP16LeadingZeroCounter
#(parameter WIDTH = `FP16_EXTENDED_SIGNIFICAND_WIDTH,
  parameter COUNT_WIDTH = $clog2(WIDTH + 1))
( input wire [WIDTH - 1:0] Value,
  output reg [COUNT_WIDTH - 1:0] LeadingZeroCount,
  output wire IsZero);
  
  integer BitIndex;
  reg FoundOne;
  
  assign IsZero = ~|(Value);
  
  always@(*) begin
    LeadingZeroCount = {COUNT_WIDTH{1'b0}};
    FoundOne = 1'b0;
    for (BitIndex = WIDTH - 1; BitIndex >= 0; BitIndex = BitIndex - 1) begin
        if (!FoundOne) begin
            if (Value[BitIndex])begin
                FoundOne = 1'b1;
            end
            else
            begin
                LeadingZeroCount = LeadingZeroCount + 1'b1;
            end
        end
    end
  end              
endmodule
