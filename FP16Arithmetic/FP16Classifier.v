`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2026 07:01:06 PM
// Design Name: 
// Module Name: FP16Classifier
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

module FP16Classifier(
input wire [`FP16_WIDTH - 1:0] Value,
output wire Sign,
output wire IsPositiveZero,
output wire IsNegativeZero,
output wire IsSubnormal,
output wire IsNormal,
output wire IsFinite,
output wire IsInfinity,
output wire IsPositiveInfinity,
output wire IsNegativeInfinity,
output wire IsNan,
output wire IsQuietNaN,
output wire IsSignalingNaN,
output reg [`FP16_CLASS_WIDTH - 1:0] Classification);

    wire [`FP16_EXPONENT_WIDTH - 1:0] Exponent;
    wire [`FP16_FRACTION_WIDTH - 1:0] Fraction;
    
    wire ExponentIsZero;
    wire ExponentIsSpecial;
    wire FractionIsZero;
    wire FractionIsNonZero;
    wire QuietNaNBit;
    
    
    assign Sign = Value[`FP16_SIGN_BIT];
    assign Exponent = Value[`FP16_EXPONENT_RANGE];
    assign Fraction = Value[`FP16_FRACTION_RANGE];
    
    assign ExponentIsZero = (Exponent == `FP16_EXPONENT_ZERO);
    assign ExponentIsSpecial = (Exponent == `FP16_EXPONENT_SPECIAL);
    assign FractionIsZero = (Exponent == `FP16_FRACTION_ZERO);
    assign FractionIsNonZero = ~FractionIsZero;
    assign QuietNaNBit = Fraction[`FP16_QUIET_NAN_BIT];
    
    assign IsZero = ExponentIsZero && FractionIsZero;
    assign IsPositiveZero = IsZero && (Sign == `FP16_SIGN_POSITIVE);
    assign IsNegativeZero = IsZero && (Sign == `FP16_SIGN_NEGATIVE);
    
    assign IsSubnoraml = ExponentIsZero && FractionIsNonZero;
    
    assign IsNormal = ~ExponentIsZero && ~ExponentIsSpecial;
    
    assign IsFinite = IsZero || IsSubnormal || IsNormal;    
    
    assign IsInfinity = ExponentIsSpecial && FractionIsZero;
    assign IsPositiveInfinity = IsInfinity && (Sign == `FP16_SIGN_POSITIVE);
    assign IsNegativeInfinity = IsInfinity && (Sign == `FP16_SIGN_NEGATIVE);
    
    assign IsNaN = ExponentIsSpecial && FractionIsNonZero;
    assign IsQuietNaN = IsNaN && QuietNaNBit;
    assign IsSignalingNaN = IsNan && ~QuietNaNBit;
    
    always@(*)begin
        Classification = `FP16_CLASS_ZERO;
        if (IsSignalingNaN) begin
            Classification = `FP16_CLASS_SIGNALING_NAN;
        end
        else
        if (IsQuietNaN) begin
            Classification = `FP16_CLASS_QUIET_NAN;
        end
        else
        if (IsInfinity) begin
            Classification = `FP16_CLASS_INFINITY;
        end
        else
        if (IsNormal) begin
            Classification = `FP16_CLASS_NORMAL;
        end
        else
        if (IsSubnormal)begin
            Classification = `FP16_CLASS_SUBNORMAL;
        end
        else begin
            Classification = `FP16_CLASS_ZERO;
        end
    end        
endmodule
