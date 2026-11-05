`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 10:56:35 PM
// Design Name: 
// Module Name: FP16Unpacker
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

module FP16Unpacker(
    input wire [`FP16_WIDTH - 1:0] Value,
    output wire Sign,
    output wire [`FP16_EXPONENT_WIDTH - 1:0] StoredExponent,
    output wire [`FP16_FRACTION_WIDTH - 1:0] Fraction,
    output reg signed [6:0] UnbiasedExponent,
    output reg [`FP16_SIGNIFICAND_WIDTH - 1:0] Significand,
    output wire [`FP16_CLASS_WIDTH - 1:0] Classification,
    output wire IsZero,
    output wire IsSubnormal,
    output wire IsNormal,
    output wire IsInfinity,
    output wire IsNaN,
    output wire IsQuietNaN,
    output wire IsSignalingNaN);
    
    wire ClassifierSign;
    wire IsPositiveZero;
    wire IsFinite;
    wire IsPositiveInfinity;
    wire IsNegativeInfinity;
    
    FP16Classifier Classifier (.Value(Value), .Sign(ClassifierSign), .IsZero(IsZero), .IsPositiveZero(IsPositiveZero), 
                               .IsNegativeZero(IsNegativeZero), .IsSubnormal(IsSubnormal), .IsNormal(IsNormal), 
                               .IsFinite(IsFinite), .IsInfinity(IsInfinity), .IsPositiveInfinity(IsPositiveInfinity),
                               .IsNegativeInfinity(IsNegativeInfinity), .IsNaN(IsNaN), .IsQuietNaN(IsQuietNaN), 
                               .IsSignalingNaN(IsSignalingNaN), .Classification(Classification));

    assign Sign = Value[`FP16_SIGN_BIT];
    assign StoredExponent = Value[`FP16_EXPONENT_RANGE];
    assign Fraction = Value[`FP16_FRACTION_RANGE];
    
    always@(*) begin
        if (IsNormal) begin
            UnbiasedExponent = $signed({2'b00, StoredExponent}) - 7'sd15;
        end
        else
        if (IsSubnormal || IsZero) begin
            UnbiasedExponent = -7'sd14;
        end
        else begin
            UnbiasedExponent = 7'sd0;
        end    
    end 
    
    always@(*)begin
        if (IsNormal) begin
            Significand = {1'b1, Fraction};
        end
        else begin
            Significand = {1'b0, Fraction};
        end    
    end             
endmodule
