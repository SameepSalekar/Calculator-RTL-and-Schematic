`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 05:48:20 PM
// Design Name: 
// Module Name: FP16RightShiftJam
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

module FP16RightShiftJam
#(parameter WIDTH = `FP16_EXTENDED_SIGNIFICAND_WIDTH,
  parameter SHIFT_AMOUNT_WIDTH = 6)
(input wire [WIDTH - 1:0] Value,
 input wire [SHIFT_AMOUNT_WIDTH - 1:0] ShiftAmount,
 output reg [WIDTH - 1:0] ShiftedValue,
 output reg StickyBit);
 
 integer BitIndex;
 
 always@(*)begin
    ShiftedValue = {WIDTH{1'b0}};
    StickyBit = 1'b0;
    
    if (ShiftAmount == 0)begin
        ShiftedValue = Value;
        StickyBit = 1'b0;
    end
    else if (ShiftAmount >= WIDTH) begin
                StickyBit = |(Value);
                ShiftedValue = {WIDTH{1'b0}};
                ShiftedValue[0] = StickyBit;
    end
    else
    begin
        ShiftedValue = Value >> ShiftAmount;
        StickyBit = 1'b0;
        
        for (BitIndex = 0; BitIndex < WIDTH; BitIndex = BitIndex + 1) begin
            if (BitIndex < ShiftAmount) begin
                StickyBit = StickyBit | Value[BitIndex];
            end    
        end
    ShiftedValue[0] = ShiftedValue[0] | StickyBit;                        
 end   
end
endmodule
