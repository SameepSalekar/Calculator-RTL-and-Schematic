`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2026 02:10:58 AM
// Design Name: 
// Module Name: FP16AddSub
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
module FP16AddSub(input wire [`FP16_WIDTH - 1:0] OperandA,
                  input wire [`FP16_WIDTH - 1:0] OperandB,
                  input wire Subtract,
                  output wire [`FP16_WIDTH - 1:0] Result,
                  output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector,
                  output wire InvalidOperation,
                  output wire Overflow,
                  output wire Underflow,
                  output wire Inexact);
                  
       localparam EXTENDED_WIDTH = `FP16_EXTENDED_SIGNIFICAND_WIDTH;
       
       wire [`FP16_OPERATION_WIDTH - 1:0] Operation;
       
       wire [`FP16_EXPONENT_WIDTH - 1:0] StoredExponentA;
       wire [`FP16_EXPONENT_WIDTH - 1:0] StoredExponentB;
       wire [`FP16_FRACTION_WIDTH - 1:0] FractionA;
       wire [`FP16_FRACTION_WIDTH - 1:0] FractionB;
       wire [`FP16_SIGNIFICAND_WIDTH - 1:0] SignificandA;
       wire [`FP16_SIGNIFICAND_WIDTH - 1:0] SignificandB;
       wire [`FP16_CLASS_WIDTH - 1:0] ClassificationA;
       wire [`FP16_CLASS_WIDTH - 1:0] ClassificationB;
       wire signed [6:0] UnbiasedExponentA;
       wire signed [6:0] UnbiasedExponentB;
       wire SignA;
       wire SignB;
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
       
       wire [`FP16_WIDTH - 1:0] SpecialResult;
       wire SpecialCaseDetected;
       wire SpecialInvalidOperation;
       wire SpecialDivideByZero;
       
       wire EffectiveSignB;
       
       wire [EXTENDED_WIDTH - 1:0] ExtendedSignificandA;
       wire [EXTENDED_WIDTH - 1:0] ExtendedSignificandB;
       
       wire AMagnitudeGreater;
       wire MagnitudesEqual;
       wire AIsLargerOrEqual;
       
       wire [EXTENDED_WIDTH - 1:0] LargerSignificand;
       wire [EXTENDED_WIDTH - 1:0] SmallerSignificand;
       wire signed [6:0] LargerExponent;
       wire signed [6:0] SmallerExponent;
       wire LargerSign;
       wire SmallerSign;
       
       wire signed [7:0] ExponentDifferenceSigned;
       wire [5:0] ExponentDifference;
       
       wire [EXTENDED_WIDTH - 1:0] AlignedSmallerSignificand;
       wire AlignmentStickyBit;
       
       wire [EXTENDED_WIDTH - 1:0] NormalizedSignificand;
       wire signed [6:0] NormalizedExponent;
       wire NormalizerIsZero;
       wire NormalizerIsNormal;
       wire NormalizerIsSubnormal;
       wire NormalizerExponentOverflow;
       
       wire [`FP16_EXPONENT_WIDTH - 1:0] RoundedStoredExponent;
       wire [`FP16_FRACTION_WIDTH - 1:0] RoundedFraction;
       wire [`FP16_CLASS_WIDTH - 1:0] RoundedClassification;
       wire [`FP16_SIGNIFICAND_WIDTH - 1:0] RoundedSignificand;
       wire signed [6:0] RoundedExponent;
       wire RounderOverflow;
       wire RounderUnderflow;
       wire RounderInexact;
       wire RoundedSign;
       
       wire [`FP16_WIDTH - 1:0] ArithmeticResult; 
       
       reg [EXTENDED_WIDTH:0] ArithmeticSignificand;
       reg ArithmeticSign;
       
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
                                    
       FP16SpecialCaseResolver SpecialCaseUnit (.OperandA(OperandA), .OperandB(OperandB), .Operation(Operation),
                                                .SpecialCaseDetected(SpecialCaseDetected), .SpecialResult(SpecialResult),
                                                .InvalidOperation(SpecialInvalidOperation), .DivideByZero(SpecialDivideByZero));
       
       FP16ShiftRightJam #(.WIDTH(EXTENDED_WIDTH), .SHIFT_AMOUNT_WIDTH (6)) AlignSmallerOperand (.Value(SmallerSignificand),
                           .ShiftAmount(ExponentDifference), .ShiftedValue(AlignedSmallerSignificand), .StickyBit(AlignmentStickyBit));
                           
       FP16Normalizer Normalizer(.SignificandIn(ArithmeticSignificand), .ExponentIn(LargerExponent), .SignificandOut(NormalizedSignificand),
                                 .ExponentOut(NormalizedExponent), .IsZero(NormalizerIsZero), .IsNormal(NormalizerIsNormal), 
                                 .IsSubnormal(NormalizerIsSubnormal), .ExponentOverflow(NormalizerExponentOverflow));
                                 
       FP16Rounder Rounder (.Sign(ArithmeticSign), .ExponentIn(NormalizedExponent), .SignificandIn(NormalizedSignificand), 
                            .ResultSign(RoundedSign), .StoredExponent(RoundedStoredExponent), .Fraction(RoundedFraction),
                            .Classification(RoundedClassification), .RoundedSignificand(RoundedSignificand), .RoundedExponent(RoundedExponent),
                            .Overflow(RounderOverflow), .Underflow(RounderUnderflow), .Inexact(RounderInexact));
                            
       FP16Packer ResultPacker (.Sign(RoundedSign), .StoredExponent(RoundedStoredExponent), .Fraction(RoundedFraction), 
                                .Classification(RoundedClassification), .PackedValue(ArithmeticResult));
       
       assign Operation = Subtract?`FP16_OP_SUBTRACT:`FP16_OP_ADD;
       
       assign EffectiveSignB = SignB ^ Subtract;
       
       assign ExtendedSignificandA = {SignificandA, {`FP16_GRS_WIDTH{1'b0}}};
       assign ExtendedSignificandB = {SignificandB, {`FP16_GRS_WIDTH{1'b0}}};
       
       assign AMagnitudeGreater = (UnbiasedExponentA > UnbiasedExponentB) || ((UnbiasedExponentA == UnbiasedExponentB) && (SignificandA > SignificandB));
       assign MagnitudesEqual = (UnbiasedExponentA == UnbiasedExponentB) && (SignificandA == SignificandB);
       assign AIsLargerOrEqual = AMagnitudeGreater || MagnitudesEqual;
       
       assign LargerSignificand = AIsLargerOrEqual?ExtendedSignificandA:ExtendedSignificandB;
       assign SmallerSignificand = AIsLargerOrEqual?ExtendedSignificandB:ExtendedSignificandA;
       assign LargerSign = AIsLargerOrEqual?SignA:EffectiveSignB;
       assign SmallerSign = AIsLargerOrEqual?EffectiveSignB:SignA;
       assign LargerExponent = AIsLargerOrEqual?UnbiasedExponentA:UnbiasedExponentB;
       assign SmallerExponent = AIsLargerOrEqual?UnbiasedExponentB:UnbiasedExponentA;
       
       assign ExponentDifferenceSigned = LargerExponent - SmallerExponent;
       
       assign ExponentDifference = ExponentDifferenceSigned[5:0];
       
       assign Result = SpecialCaseDetected?SpecialResult:ArithmeticResult;
       
       assign InvalidOperation = SpecialInvalidOperation;
       assign Overflow = SpecialCaseDetected?1'b0:RounderOverflow;
       assign Underflow = SpecialCaseDetected?1'b0:RounderUnderflow;
       assign Inexact = SpecialCaseDetected?1'b0:RounderInexact;
       
       assign ExceptionVector[`FP16_EXCEPTION_INVALID_BIT] = InvalidOperation;
       assign ExceptionVector[`FP16_EXCEPTION_DIVZERO_BIT] = 1'b0;
       assign ExceptionVector[`FP16_EXCEPTION_OVERFLOW_BIT] = Overflow;
       assign ExceptionVector[`FP16_EXCEPTION_UNDERFLOW_BIT] = Underflow;
       assign ExceptionVector[`FP16_EXCEPTION_INEXACT_BIT] = Inexact;
       
       always@(*) begin
        ArithmeticSignificand = {(EXTENDED_WIDTH + 1){1'b0}};
        ArithmeticSign = 1'b0;
            if(LargerSign == SmallerSign) begin
                ArithmeticSignificand = {1'b0, LargerSignificand} + {1'b0, AlignedSmallerSignificand};
                ArithmeticSign = LargerSign;    
            end
            else
            begin
                ArithmeticSignificand = {1'b0, LargerSignificand} - {1'b0, AlignedSmallerSignificand};
                ArithmeticSign = LargerSign;
                if({1'b0, LargerSignificand} == {1'b0, AlignedSmallerSignificand})begin
                    ArithmeticSign = `FP16_SIGN_POSITIVE;
                end 
            end       
       end 
       
                                                                                                                    
endmodule
