`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:01:15 AM
// Design Name: 
// Module Name: FP16Rounder
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

module FP16Rounder
#(parameter EXPONENT_WIDTH = 7 )
( input wire Sign,
  input wire signed [EXPONENT_WIDTH - 1:0] ExponentIn,
  input wire [`FP16_EXTENDED_SIGNIFICAND_WIDTH - 1:0] SignificandIn,
  output reg [`FP16_EXPONENT_WIDTH - 1:0] StoredExponent,
  output reg [`FP16_FRACTION_WIDTH - 1:0] Fraction,
  output reg [`FP16_CLASS_WIDTH - 1:0] Classification,
  output reg [`FP16_SIGNIFICAND_WIDTH - 1:0] RoundedSignificand,
  output reg signed [EXPONENT_WIDTH - 1:0] RoundedExponent,
  output reg ResultSign,
  output reg Overflow,
  output reg Underflow,
  output reg Inexact );
  
  reg [`FP16_SIGNIFICAND_WIDTH - 1:0] RetainedSignificand;
  reg [`FP16_SIGNIFICAND_WIDTH:0] ExtendedRoundedSignificand;
  reg GuardBit;
  reg RoundBit;
  reg StickyBit;
  reg RoundIncrement;
  
  always@(*)begin
    RetainedSignificand = SignificandIn[`FP16_EXTENDED_SIGNIFICAND_WIDTH - 1:`FP16_GRS_WIDTH];
    GuardBit = SignificandIn[`FP16_GUARD_BIT];
    RoundBit = SignificandIn[`FP16_ROCKY_BIT];
    StickyBit = SignificandIn[`FP16_STICKY_BIT];
    Inexact = GuardBit | RoundBit | StickyBit;
    RoundIncrement = GuardBit && (RoundBit || StickyBit || RetainedSignificand[0]);
    ExtendedRoundedSignificand = {1'b0, RetainedSignificand} + RoundIncrement;
    ResultSign = Sign;
    StoredExponent = `FP16_EXPONENT_ZERO;
    Fraction = `FP16_FRACTION_ZERO;
    Classification = `FP16_CLASS_ZERO;
    RoundedSignificand = {`FP16_SIGNIFICAND_WIDTH{1'b0}};
    RoundedExponent = ExponentIn;
    Overflow = 1'b0;
    Underflow = 1'b0;
    
    if (ExtendedRoundedSignificand[`FP16_SIGNIFICAND_WIDTH]) begin
        RoundedSignificand = ExtendedRoundedSignificand[`FP16_SIGNIFICAND_WIDTH:1];
        RoundedExponent = ExponentIn + 7'sd1;
    end
    else 
    begin
        RoundedSignificand = ExtendedRoundedSignificand[`FP16_SIGNIFICAND_WIDTH - 1:0];
        RoundedExponent = ExponentIn;
    end 
    
    if (RoundedExponent > 7'sd15) begin
        StoredExponent = `FP16_EXPONENT_SPECIAL;
        Fraction = `FP16_FRACTION_ZERO;
        Classification = `FP16_CLASS_INFINITY;
        Overflow = 1'b1;
        Inexact = 1'b1;
        Underflow = 1'b0;
    end
    else
        if (RoundedSignificand == {`FP16_SIGNIFICAND_WIDTH{1'b0}}) begin
            StoredExponent = `FP16_EXPONENT_ZERO;
            Fraction = `FP16_FRACTION_ZERO;
            Classification = `FP16_CLASS_ZERO;
            Overflow = 1'b0;
            Underflow = (ExponentIn <= -7'sd14) && Inexact;
        end
        else
            if (RoundedSignificand[`FP16_SIGNIFICAND_WIDTH - 1]) begin
                StoredExponent = RoundedExponent + 7'sd15;
                Fraction = RoundedSignificand[`FP16_FRACTION_WIDTH - 1:0];
                Classification = `FP16_CLASS_NORMAL;
                Overflow = 1'b0;
                Underflow = 1'b0;
            end
            else
            begin
                StoredExponent = `FP16_EXPONENT_ZERO;
                Fraction = RoundedSignificand[`FP16_FRACTION_WIDTH - 1:0];
                Classification = `FP16_CLASS_SUBNORMAL;
                Overflow = 1'b0;
                Underflow = Inexact;
            end            
  end         
endmodule
