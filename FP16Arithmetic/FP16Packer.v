`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2026 11:44:08 PM
// Design Name: 
// Module Name: FP16Packer
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

module FP16Packer(
    input wire Sign,
    input wire [`FP16_EXPONENT_WIDTH - 1:0] StoredExponent,
    input wire [`FP16_FRACTION_WIDTH - 1:0] Fraction,
    input wire [`FP16_CLASS_WIDTH - 1:0] Classification,
    output reg [`FP16_WIDTH - 1:0] PackedValue);
    
    reg [`FP16_FRACTION_WIDTH - 1:0] AdjustedNaNFraction;
    
    always@(*) begin
        PackedValue = `FP16_CANONICAL_QNAN;
        AdjustedNaNFraction = Fraction;
        
        case (Classification)
            `FP16_CLASS_ZERO: begin
                PackedValue = {Sign, `FP16_EXPONENT_ZERO, `FP16_FRACTION_ZERO};
            end
            
            `FP16_CLASS_SUBNORMAL: begin
                PackedValue = {Sign, `FP16_EXPONENT_ZERO, Fraction};
            end
            
            `FP16_CLASS_NORMAL: begin
                PackedValue = {Sign, StoredExponent, Fraction};
            end
            
            `FP16_CLASS_INFINITY: begin
                PackedValue = {Sign, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
            end
            
            `FP16_CLASS_QUIET_NAN: begin
                AdjustedNaNFraction = Fraction;
                AdjustedNaNFraction[`FP16_QUIET_NAN_BIT] = 1'b1;
                PackedValue = {Sign, `FP16_EXPONENT_SPECIAL, AdjustedNaNFraction};
            end
            
            `FP16_CLASS_SIGNALING_NAN: begin
                AdjustedNaNFraction = Fraction;
                AdjustedNaNFraction[`FP16_QUIET_NAN_BIT] = 1'b0;
                if (AdjustedNaNFraction == `FP16_FRACTION_ZERO) begin
                    AdjustedNaNFraction[0] = 1'b1;
                end
                
                PackedValue = {Sign, `FP16_EXPONENT_SPECIAL, AdjustedNaNFraction};
            end
            
            default: begin
                PackedValue = `FP16_CANONICAL_QNAN;
            end            
        endcase
    end                              
endmodule
