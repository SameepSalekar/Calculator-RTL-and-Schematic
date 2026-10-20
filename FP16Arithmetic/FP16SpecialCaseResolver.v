`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 12:18:12 PM
// Design Name: 
// Module Name: FP16SpecialCaseResolver
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

module FP16SpecialCaseResolver( input wire [`FP16_WIDTH - 1:0] OperandA, 
                                input wire [`FP16_WIDTH - 1:0] OperandB,
                                input wire [`FP16_OPERATION_WIDTH - 1:0] Operation,
                                output reg [`FP16_WIDTH - 1:0] SpecialResult,
                                output reg SpecialCaseDetected,
                                output reg InvalidOperation,
                                output reg DivideByZero);
                                
       wire SignA;
       wire IsZeroA;
       wire IsSubnormalA;
       wire IsNormalA;
       wire IsFiniteA;
       wire IsInfinityA;
       wire IsPositiveInfinityA;
       wire IsNegativeInfinityA;
       wire IsNaNA;
       wire IsQuietNaNA;
       wire IsSignalingNaNA;
       wire [`FP16_CLASS_WIDTH - 1:0] ClassificationA;
       
       wire SignB;
       wire IsZeroB;
       wire IsSubnormalB;
       wire IsNormalB;
       wire IsFiniteB;
       wire IsInfinityB;
       wire IsPositiveInfinityB;
       wire IsNegativeInfinityB;
       wire IsNaNB;
       wire IsQuietNaNB;
       wire IsSignalingNaNB;
       wire [`FP16_CLASS_WIDTH - 1:0] ClassificationB;
       
       wire AnyNaN;
       wire AnySignalingNaN;
       wire MultiplicationResultSign;
       wire DivisionResultSign;
       wire EffectiveSignB;
       wire MagnitudesEqual;
       wire [`FP16_WIDTH - 1:0] EffectiveOperandB;
       
       FP16Classifier ClassifierA (.Value(OperandA), .Sign(SignA), .IsZero(IsZeroA), .IsPositiveZero(), .IsNegativeZero(),
                                   .IsSubnormal(IsSubnormalA), .IsNormal(IsNormalA), .IsFinite(IsFiniteA), .IsInfinity(IsInfinityA),
                                   .IsPositiveInfinity(IsPositiveInfinityA), .IsNegativeInfinity(IsNegativeInfinityA), .IsNaN(IsNaNA),
                                   .IsQuietNaN(IsQuietNaNA), .IsSignalingNaN(IsSignalingNaNA), .Classification(ClassificationA));
                                   
       FP16Classifier ClassifierB (.Value(OperandB), .Sign(SignB), .IsZero(IsZeroB), .IsPositiveZero(), .IsNegativeZero(),
                                   .IsSubnormal(IsSubnormalB), .IsNormal(IsNormalB), .IsFinite(IsFiniteB), .IsInfinity(IsInfinityB),
                                   .IsPositiveInfinity(IsPositiveInfinityB), .IsNegativeInfinity(IsNegativeInfinityB), .IsNaN(IsNaNB),
                                   .IsQuietNaN(IsQuietNaNB), .IsSignalingNaN(IsSignalingNaNB), .Classification(ClassificationB));
       
       assign AnyNaN = IsNaNA || IsNaNB;
       assign AnySignalingNaN = IsSignalingNaNA || IsSignalingNaNB;
       assign MultiplicationResultSign = SignA ^ SignB;
       assign DivisionResultSign = SignA ^ SignB;
       assign EffectiveSignB = SignB ^ (Operation == `FP16_OP_SUBTRACT);
       assign EffectiveOperandB = {EffectiveSignB, OperandB[`FP16_EXPONENT_MSB:`FP16_FRACTION_LSB]};
       assign MagnitudesEqual = (OperandA[`FP16_EXPONENT_MSB:`FP16_FRACTION_LSB] == OperandB[`FP16_EXPONENT_MSB:`FP16_FRACTION_LSB]);
       
       always@(*) begin
        SpecialCaseDetected = 1'b0;
        SpecialResult = `FP16_POSITIVE_ZERO;
        InvalidOperation = 1'b0;
        DivideByZero = 1'b0;
        
        case (Operation)
            `FP16_OP_ADD,
            `FP16_OP_SUBTRACT,
            `FP16_OP_ACCUMULATE:
        begin
            if (AnySignalingNaN) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
                InvalidOperation = 1'b1;
            end
            else if (AnyNaN) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
            end
            else if (IsInfinityA && IsInfinityB) begin
                SpecialCaseDetected = 1'b1;
                if (SignA != EffectiveSignB) begin
                    SpecialResult = `FP16_CANONICAL_QNAN;
                    InvalidOperation = 1'b1;
                end
                else
                begin
                    SpecialResult = {SignA, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
                end
            end
            else if (IsInfinityA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = {SignA, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
            end
            else if (IsInfinityB) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = {EffectiveSignB, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
            end
            else if (IsZeroA && IsZeroB) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = {SignA & EffectiveSignB, `FP16_EXPONENT_ZERO, `FP16_FRACTION_ZERO};
            end
            else if (IsZeroA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = EffectiveOperandB;
            end
            else if (IsZeroB) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = OperandA;
            end
            else if (IsFiniteA && IsFiniteB && MagnitudesEqual && (SignA != EffectiveSignB)) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_POSITIVE_ZERO;
            end
        end    
        
        `FP16_OP_MULTIPLY,
        `FP16_OP_SEQUENTIAL_MULTIPLY:
        begin
            if (AnySignalingNaN) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
                InvalidOperation = 1'b1;
            end
            else if (AnyNaN) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
            end
            else if ((IsZeroA && IsInfinityB) || (IsInfinityA && IsZeroB)) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
            end
            else if (IsInfinityA || IsInfinityB) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = {MultiplicationResultSign, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
            end
            else if (IsZeroA || IsZeroB) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = {MultiplicationResultSign, `FP16_EXPONENT_ZERO, `FP16_FRACTION_ZERO};
            end
        end
        
        `FP16_OP_DIVIDE:
        begin
        if (AnySignalingNaN) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = `FP16_CANONICAL_QNAN;
            InvalidOperation = 1'b1;
        end
        else if (AnyNaN) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = `FP16_CANONICAL_QNAN;
        end
        else if (IsZeroA && IsZeroB) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = `FP16_CANONICAL_QNAN;
            InvalidOperation = 1'b1;
        end                                           
        else if (IsInfinityA && IsInfinityB) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = `FP16_CANONICAL_QNAN;
            InvalidOperation = 1'b1;
        end
        else if (IsInfinityA) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = {DivisionResultSign, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
        end            
        else if (IsInfinityB) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = {DivisionResultSign, `FP16_EXPONENT_ZERO, `FP16_FRACTION_ZERO};
        end
        else if (IsZeroB) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = {DivisionResultSign, `FP16_EXPONENT_SPECIAL, `FP16_FRACTION_ZERO};
            DivideByZero = 1'b1;
        end        
        else if (IsZeroA) begin
            SpecialCaseDetected = 1'b1;
            SpecialResult = {DivisionResultSign, `FP16_EXPONENT_ZERO, `FP16_FRACTION_ZERO};
        end
        end
        
        `FP16_OP_SQUARE_ROOT:
        begin
            if (IsSignalingNaNA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
                InvalidOperation = 1'b1;
            end
            else if (IsNaNA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
            end
            else if (IsZeroA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = OperandA;
            end
            else if (IsInfinityA && !SignA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_POSITIVE_INFINITY;
            end
            else if (IsInfinityA && SignA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
                InvalidOperation = 1'b1;
            end
            else if (IsFiniteA && SignA) begin
                SpecialCaseDetected = 1'b1;
                SpecialResult = `FP16_CANONICAL_QNAN;
                InvalidOperation = 1'b1;
            end
        end
        
        default:
        begin
            SpecialCaseDetected = 1'b0;
            SpecialResult = `FP16_POSITIVE_ZERO;
            InvalidOperation = 1'b0;
            DivideByZero = 1'b0;
        end
        endcase
       end                                                                             
endmodule
