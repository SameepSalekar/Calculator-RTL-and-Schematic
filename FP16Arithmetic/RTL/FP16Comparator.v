`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2026 12:08:07 AM
// Design Name: 
// Module Name: FP16Comparator
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

module FP16Comparator( input wire [`FP16_WIDTH - 1:0] OperandA,
                       input wire [`FP16_WIDTH - 1:0] OperandB,
                       output reg Greater,
                       output reg Equal,
                       output reg Lesser,
                       output reg Unordered,
                       output reg InvalidOperation );
      
      wire SignA;
      wire IsZeroA;
      wire IsPositiveZeroA;
      wire IsNegativeZeroA;
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
      wire IsPositiveZeroB;
      wire IsNegativeZeroB;
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
      
      wire [`FP16_CLASS_WIDTH - 1:0] MagnitudeA;
      wire [`FP16_CLASS_WIDTH - 1:0] MagnitudeB;
      
      FP16Classifier ClassifierA (.Value(OperandA), .Sign(SignA), .IsZero(IsZeroA), .IsPositiveZero(IsPositiveZeroA),
                                  .IsNegativeZero(IsNegativeZeroA), .IsSubnormal(IsSubnormalA), .IsNormal(IsNormalA),
                                  .IsFinite(IsFiniteA), .IsInfinity(IsInfinityA),.IsPositiveInfinity(IsPositiveInfinityA),
                                  .IsNegativeInfinity(IsNegativeInfinityA), .IsNaN(IsNaNA), .IsQuietNaN(IsQuietNaNA),
                                  .IsSignalingNaN(IsSignalingNaNA), .Classification(ClassificationA));
                                  
      FP16Classifier ClassifierB (.Value(OperandB), .Sign(SignB), .IsZero(IsZeroB), .IsPositiveZero(IsPositiveZeroB),
                                  .IsNegativeZero(IsNegativeZeroB), .IsSubnormal(IsSubnormalB), .IsNormal(IsNormalB),
                                  .IsFinite(IsFiniteB), .IsInfinity(IsInfinityB),.IsPositiveInfinity(IsPositiveInfinityB),
                                  .IsNegativeInfinity(IsNegativeInfinityB), .IsNaN(IsNaNB), .IsQuietNaN(IsQuietNaNB),
                                  .IsSignalingNaN(IsSignalingNaNB), .Classification(ClassificationB));
      
      assign MagnitudeA = OperandA[`FP16_EXPONENT_MSB:`FP16_FRACTION_LSB]; 
      assign MagnitudeB = OperandB[`FP16_EXPONENT_MSB:`FP16_FRACTION_LSB];     
      
      always@(*)begin
        Greater = 1'b0;
        Equal = 1'b0;
        Lesser = 1'b0;
        Unordered = 1'b0;
        InvalidOperation = 1'b0;
        
        if (IsNaNA || IsNaNB) begin
            Greater = 1'b0;
            Equal = 1'b0;
            Lesser = 1'b0;
            Unordered = 1'b1;
            InvalidOperation = IsSignalingNaNA || IsSignalingNaNB;
        end
        
        else
        
        if (IsZeroA && IsZeroB) begin
            Equal = 1'b1;
        end
        
        else
        
        if (OperandA == OperandB) begin
            Equal = 1'b1;
        end
        
        else 
        
        if (SignA != SignB) begin
            if (SignA == `FP16_SIGN_POSITIVE) begin
                Greater = 1'b1;
            end
            else
            begin
                Lesser = 1'b1;
            end
        end
        
        else
        
        if (SignA == `FP16_SIGN_POSITIVE) begin
            if (MagnitudeA > MagnitudeB) begin
                Greater = 1'b1;
            end
            else
            if (MagnitudeA < MagnitudeB) begin
                Lesser = 1'b1;
            end
            else
            begin
                Equal = 1'b1;
            end                            
        end                                          
        
        else
        begin
            if (MagnitudeA > MagnitudeB) begin
                Lesser = 1'b1;
            end
            else
            if (MagnitudeA < MagnitudeB) begin
                Greater = 1'b1;
            end
            else
            begin
                Equal = 1'b1;
            end
        end                                                                                
      end  
endmodule
