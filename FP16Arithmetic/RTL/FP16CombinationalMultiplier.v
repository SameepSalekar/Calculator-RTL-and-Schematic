`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 05:26:00 PM
// Design Name: 
// Module Name: FP16CombinationalMultiplier
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

module FP16CombinationalMultiplier ( input wire [`FP16_WIDTH - 1:0] OperandA,
                                     input wire [`FP16_WIDTH - 1:0] OperandB,
                                     output wire [`FP16_WIDTH - 1:0] Result,
                                     output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector,
                                     output wire InvalidOperation,
                                     output wire Overflow,
                                     output wire Underflow,
                                     output wire Inexact);
                                     
       localparam PRODUCT_WIDTH = 2 * `FP16_SIGNIFICAND_WIDTH; 
       
       wire SignA;
       wire SignB;
       
       wire [`FP16_EXPONENT_WIDTH - 1:0] StoredExponentA;
       wire [`FP16_EXPONENT_WIDTH - 1:0] StoredExponentB;
       
       wire [`FP16_FRACTION_WIDTH - 1:0] FractionA;                              
       wire [`FP16_FRACTION_WIDTH - 1:0] FractionB;
       
       wire signed [6:0] UnbiasedExponentA;
       wire signed [6:0] UnbiasedExponentB;
       
       wire [`FP16_SIGNIFICAND_WIDTH - 1:0] SignificandA;
       wire [`FP16_SIGNIFICAND_WIDTH - 1:0] SignificandB;
       
       wire [`FP16_CLASS_WIDTH - 1:0] ClassificationA;
       wire [`FP16_CLASS_WIDTH - 1:0] ClassificationB;
       
       wire OperandAIsZero;
       wire OperandAIsSubnormal;
       wire OperandAIsNormal;
       wire OperandAIsInfinity;
       wire OperandAIsNaN;
       wire OperandAIsQuietNaN;
       wire OperandAIsSignalingNaN;
       
       wire OperandBIsZero;
       wire OperandBIsSubnormal;
       wire OperandBIsNormal;
       wire OperandBIsInfinity;
       wire OperandBIsNaN;
       wire OperandBIsQuietNaN;
       wire OperandBIsSignalingNaN;
       
       wire SpecialCaseDetected;
       wire [`FP16_WIDTH - 1:0] SpecialResult;
       wire SpecialInvalidOperation;
       wire SpecialDivideByZero;
       
       wire ProductSign;
       
       wire signed [7:0] ProductExponentWide;
       wire signed [6:0] ProductExponent;
       
       wire [PRODUCT_WIDTH - 1:0] FullSignificandProduct;
       
       wire DiscardedBitsNonzero;
       wire ProductStickyBit;
      
       wire [`FP16_EXTENDED_SIGNIFICAND_WIDTH:0] ProductSignificandForNormalization;
       
       wire [`FP16_EXTENDED_SIGNIFICAND_WIDTH - 1:0] NormalizedSignificand;
       
       wire signed [6:0] NormalizedExponent;
       wire NormalizerIsZero;
       wire NormalizerIsNormal;
       wire NormalizerIsSubnormal;
       wire NormalizerExponentOverflow;
       
       wire RoundedSign;
       wire [`FP16_EXPONENT_WIDTH - 1:0] RoundedStoredExponent;
       wire [`FP16_FRACTION_WIDTH - 1:0] RoundedFraction;
       wire [`FP16_CLASS_WIDTH - 1:0] RoundedClassification;
       wire [`FP16_SIGNIFICAND_WIDTH - 1:0] RoundedSignificand;
       wire signed [6:0] RoundedExponent;
       wire RounderOverflow;
       wire RounderUnderflow;
       wire RounderInexact;
       
       wire [`FP16_WIDTH - 1:0] ArithmeticResult;
       
       FP16Unpacker UnpackOperandA (.Value(OperandA), .Sign(SignA), .StoredExponent(StoredExponentA), .Fraction(FractionA),
                                    .UnbiasedExponent(UnbiasedExponentA), .Significand(SignificandA), 
                                    .Classification(ClassificationA), .IsZero(OperandAIsZero), .IsSubnormal(OperandAIsSubnormal),
                                    .IsNormal(OperandAIsNormal), .IsInfinity(OperandAIsInfinity), .IsNaN(OperandAIsNaN),
                                    .IsQuietNaN(OperandAIsQuietNaN), .IsSignalingNaN(OperandAIsSignalingNaN));
                                    
       FP16Unpacker UnpackOperandB (.Value(OperandB), .Sign(SignB), .StoredExponent(StoredExponentB), .Fraction(FractionB),
                                    .UnbiasedExponent(UnbiasedExponentB), .Significand(SignificandB), 
                                    .Classification(ClassificationB), .IsZero(OperandBIsZero), .IsSubnormal(OperandBIsSubnormal),
                                    .IsNormal(OperandBIsNormal), .IsInfinity(OperandBIsInfinity), .IsNaN(OperandBIsNaN),
                                    .IsQuietNaN(OperandBIsQuietNaN), .IsSignalingNaN(OperandBIsSignalingNaN));
                                    
       FP16SpecialCaseResolver SpecialCaseUnit (.OperandA(OperandA), .OperandB(OperandB), .Operation(`FP16_OP_MULTIPLY),
                                                .SpecialCaseDetected(SpecialCaseDetected), .SpecialResult(SpecialResult),
                                                .InvalidOperation(SpecialInvalidOperation), .DivideByZero(SpecialDivideByZero));
                                                
       FP16Normalizer Normalizer (.SignificandIn(ProductSignificandForNormalization), .ExponentIn(ProductExponent), 
                                  .SignificandOut(NormalizedSignificand), .ExponentOut(NormalizedExponent), .IsZero(NormalizerIsZero),
                                  .IsNormal(NormalizerIsNormal), .IsSubnormal(NormalizerIsSubnormal), .ExponentOverflow(NormalizerExponentOverflow)); 
       
       FP16Rounder Rounder (.Sign(ProductSign), .ExponentIn(NormalizedExponent), .SignificandIn(NormalizedSignificand), 
                            .ResultSign(RoundedSign), .StoredExponent(RoundedStoredExponent), .Fraction(RoundedFraction),
                            .Classification(RoundedClassification), .RoundedSignificand(RoundedSignificand),
                            .RoundedExponent(RoundedExponent), .Overflow(RounderOverflow), .Underflow(RounderUnderflow), 
                            .Inexact(RounderInexact));
                            
       FP16Packer ResultPacker (.Sign(RoundedSign), .StoredExponent(RoundedStoredExponent), .Fraction(RoundedFraction),
                                .Classification(RoundedClassification), .PackedValue(ArithmeticResult));
                                
                                                                                 
       
       assign ProductSign = SignA ^ SignB;
       
       assign ProductExponentWide = $signed(UnbiasedExponentA) + $signed(UnbiasedExponentB);
       
       assign ProductExponent = ProductExponentWide[6:0];
                                    
       assign FullSignificandProduct = SignificandA * SignificandB;
       
       assign DiscardedBitsNonzero = |(FullSignificandProduct[6:0]);
       
       assign ProductStickyBit = FullSignificandProduct[7] | DiscardedBitsNonzero;
       
       assign ProductSignificandForNormalization = {FullSignificandProduct[21:8], ProductStickyBit};       

       assign Result = SpecialCaseDetected ? SpecialResult:ArithmeticResult;
       
       assign InvalidOperation = SpecialInvalidOperation;
       
       assign Overflow = SpecialCaseDetected ? 1'b0 : RounderOverflow;
       
       assign Underflow = SpecialCaseDetected ? 1'b0 : RounderUnderflow;
       
       assign Inexact = SpecialCaseDetected ? 1'b0 : RounderInexact;
              
       assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact};                               

endmodule
