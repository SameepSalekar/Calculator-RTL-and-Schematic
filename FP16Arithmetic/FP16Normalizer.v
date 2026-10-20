`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/14/2026 07:17:06 PM
// Design Name: 
// Module Name: FP16Normalizer
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

module FP16Normalizer
#(parameter INPUT_WIDTH = `FP16_EXTENDED_SIGNIFICAND_WIDTH + 1,
  parameter OUTPUT_WIDTH = `FP16_EXTENDED_SIGNIFICAND_WIDTH,
  parameter EXPONENT_WIDTH = 7,
  parameter SHIFT_AMOUNT_WIDTH = 6,
  parameter LEADING_ZERO_COUNT_WIDTH = $clog2(OUTPUT_WIDTH + 1))
(input wire [INPUT_WIDTH - 1:0] SignificandIn,
 input wire signed [EXPONENT_WIDTH - 1:0] ExponentIn,
 output reg [OUTPUT_WIDTH - 1:0] SignificandOut,
 output reg signed [EXPONENT_WIDTH - 1:0] ExponentOut,
 output reg IsZero,
 output reg IsNormal,
 output reg IsSubnormal,
 output reg ExponentOverflow);
 
 wire CarryBit;
 wire [OUTPUT_WIDTH - 1:0] CarryShiftedSignificand;
 wire [OUTPUT_WIDTH - 1:0] CarryAdjustedSignificand;
 wire signed [EXPONENT_WIDTH - 1:0] CarryAdjustedExponent;
 
 wire [LEADING_ZERO_COUNT_WIDTH - 1:0] LeadingZeroCount;
 wire CarryAdjustedIsZero;
 
 wire [SHIFT_AMOUNT_WIDTH - 1:0] SubnormalShiftAmount;
 
 wire [OUTPUT_WIDTH - 1:0] SubnormalShiftedSignificand;
 wire SubnormalStickyBit;
 
 assign CarryBit = SignificandIn[INPUT_WIDTH - 1];
 assign CarryShiftedSignificand = SignificandIn[INPUT_WIDTH - 1:1];
 
 assign CarryAdjustedSignificand = CarryBit?{CarryShiftedSignificand[OUTPUT_WIDTH - 1:1], CarryShiftedSignificand[0]|SignificandIn[0]}:SignificandIn[OUTPUT_WIDTH - 1:0];
 assign CarryAdjustedExponent = ExponentIn + (CarryBit?7'sd1:7'sd0);
 
 FP16LeadingZeroCounter #(.WIDTH(OUTPUT_WIDTH),.COUNT_WIDTH(LEADING_ZERO_COUNT_WIDTH))
 LeadingZeroCounter (.Value(CarryAdjustedSignificand), .LeadingZeroCount(LeadingZeroCount), .IsZero(CarryAdjustedIsZero));
 
 assign SubnormalShiftAmount = (CarryAdjustedExponent < -7'sd14)?(-7'sd14 - CarryAdjustedExponent):{SHIFT_AMOUNT_WIDTH{1'b0}};
 
 FP16RightShiftJam #(.WIDTH(OUTPUT_WIDTH), .SHIFT_AMOUNT_WIDTH(SHIFT_AMOUNT_WIDTH))
 SubnormalShiftUnit (.Value(CarryAdjustedSignificand), .ShiftAmount(SubnormalShiftAmount), .ShiftedValue(SubnormalShiftedSignificand), .StickyBit(SubnormalStickyBit));

 integer MaximumLeftShift;
 integer AppliedLeftShift;
 
 always@(*)begin
    SignificandOut = {OUTPUT_WIDTH{1'b0}};
    ExponentOut = -7'sd14;
    IsZero = 1'b0;
    IsNormal = 1'b0;
    IsSubnormal = 1'b0;
    ExponentOverflow = 1'b0;
    MaximumLeftShift = 0;
    AppliedLeftShift = 0;
        if (CarryAdjustedIsZero) begin
            SignificandOut = {OUTPUT_WIDTH{1'b0}};
            ExponentOut = -7'sd14;
            IsZero = 1'b1;
            IsNormal = 1'b0;
            IsSubnormal = 1'b0;
            ExponentOverflow = 1'b0;
        end    
        else if (CarryAdjustedExponent < -7'sd14) begin
            SignificandOut = SubnormalShiftedSignificand;
            ExponentOut = -7'sd14;
            IsZero = ~(|SubnormalShiftedSignificand);
            IsNormal = SubnormalShiftedSignificand[OUTPUT_WIDTH - 1];
            IsSubnormal = (|SubnormalShiftedSignificand) && ~SubnormalShiftedSignificand[OUTPUT_WIDTH - 1];
            ExponentOverflow = 1'b0;
        end
        else
        begin
            MaximumLeftShift = CarryAdjustedExponent + 14;
                if(LeadingZeroCount < MaximumLeftShift) begin
                    AppliedLeftShift = LeadingZeroCount;
                end
                else 
                begin
                    AppliedLeftShift = MaximumLeftShift;
                end
                SignificandOut = CarryAdjustedSignificand << AppliedLeftShift;
                ExponentOut = CarryAdjustedExponent - AppliedLeftShift;
                IsZero = 1'b0;
                IsNormal = SignificandOut[OUTPUT_WIDTH - 1];
                IsSubnormal = (ExponentOut == -7'sd14) && ~SignificandOut[OUTPUT_WIDTH - 1];
                ExponentOverflow = (ExponentOut > 7'sd15);
        end        
 end                           
endmodule