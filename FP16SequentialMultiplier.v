`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2026 09:56:42 PM
// Design Name: 
// Module Name: FP16SequentialMultiplier
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

module FP16SequentialMultiplier ( input wire clk,
                                  input wire reset,
                                  input wire START,
                                  input wire [`FP16_WIDTH - 1:0] OperandA,
                                  input  wire [`FP16_WIDTH - 1:0] OperandB,
                                  output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector,
                                  output reg [`FP16_WIDTH - 1:0] Result,
                                  output reg BUSY,
                                  output reg DONE,
                                  output reg InvalidOperation,
                                  output reg Overflow,
                                  output reg Underflow,
                                  output reg Inexact);
         
       localparam STATE_IDLE = 2'b00;
       localparam STATE_MULTIPLY = 2'b01;
       localparam STATE_FINALIZE = 2'b10;
      
       localparam SIGNIFICAND_ITERATIONS = `FP16_SIGNIFICAND_WIDTH;
      
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
       
       wire InputSpecialCaseDetected;
       wire [`FP16_WIDTH - 1:0] InputSpecialResult;
       wire InputInvalidOperation;
       wire InputDivideByZero;
        
       wire [PRODUCT_WIDTH - 1:0] ProductAfterAddition;
       
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
       
       wire [`FP16_WIDTH - 1:0] PackedArithmeticResult;
       
       reg [1:0] CurrentState;
       
       reg [PRODUCT_WIDTH - 1:0] ProductRegister;
       reg [PRODUCT_WIDTH - 1:0] MultiplicandRegister;
       reg [`FP16_SIGNIFICAND_WIDTH - 1:0] MultiplierRegister;
       reg [3:0] IterationCount;
       reg StoredProductSign;
       reg signed [6:0] StoredProductExponent;
       
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
       
       FP16SpecialCaseResolver SpecialCaseUnit (.OperandA(OperandA), .OperandB(OperandB), .Operation(`FP16_OP_SEQUENTIAL_MULTIPLY),
                                                .SpecialCaseDetected(InputSpecialCaseDetected), .SpecialResult(InputSpecialResult),
                                                .InvalidOperation(InputInvalidOperation), .DivideByZero(InputDivideByZero));

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
       
       assign ProductAfterAddition = MultiplierRegister[0] ? (ProductRegister + MultiplicandRegister) : ProductRegister;
       
       assign ProductStickyBit = ProductRegister[7] | (|ProductRegister[6:0]);
       
       assign ProductSignificandForNormalization = {ProductRegister[21:8], ProductStickyBit};
       
       always @(posedge clk) begin
        if (reset) begin
            CurrentState <= STATE_IDLE;
            Result <= `FP16_POSITIVE_ZERO;
            BUSY <= 1'b0;
            DONE <= 1'b0;
            InvalidOperation <= 1'b0;
            Overflow <= 1'b0;
            Underflow <= 1'b0;
            Inexact <= 1'b0;
            ProductRegister <= {PRODUCT_WIDTH{1'b0}};
            MultiplicandRegister <= {PRODUCT_WIDTH{1'b0}};
            MultiplierRegister <= {`FP16_SIGNIFICAND_WIDTH{1'b0}};
            IterationCount <= 4'd0;
            StoredProductSign <= 1'b0;
            StoredProductExponent <= 7'sd0;
        end
        else
        begin
            DONE <= 1'b0;
            case (CurrentState)
                STATE_IDLE: begin
                    BUSY <= 1'b0;
                        if (START) begin
                            InvalidOperation <= 1'b0;
                            Overflow <= 1'b0;
                            Inexact <= 1'b0;
                                if (InputSpecialCaseDetected) begin
                                    Result <= InputSpecialResult;
                                    InvalidOperation <= InputInvalidOperation;
                                    Overflow <= 1'b0;
                                    Underflow <= 1'b0;
                                    Inexact <= 1'b0;
                                    BUSY <= 1'b0;
                                    DONE <= 1'b1;
                                    CurrentState <= STATE_IDLE;
                                end
                                else
                                begin
                                    ProductRegister <= {PRODUCT_WIDTH{1'b0}};
                                    MultiplicandRegister <= {{`FP16_SIGNIFICAND_WIDTH{1'b0}}, SignificandA};
                                    MultiplierRegister <= SignificandB;
                                    IterationCount <= 4'd0;
                                    StoredProductSign <= SignA ^ SignB;
                                    StoredProductExponent <= $signed(UnbiasedExponentA) + $signed(UnbiasedExponentB);
                                    BUSY <= 1'b1;
                                    CurrentState <= STATE_MULTIPLY;
                                end
                                end
                        end        
                STATE_MULTIPLY: begin
                    BUSY <= 1'b1;
                    ProductRegister <= ProductAfterAddition;
                    MultiplicandRegister <= MultiplicandRegister << 1;
                    MultiplierRegister <= MultiplierRegister >> 1;
                    if (IterationCount == SIGNIFICAND_ITERATIONS - 1)begin
                        ProductRegister <= ProductAfterAddition;
                        CurrentState <= STATE_FINALIZE;
                    end
                    else
                    begin
                        IterationCount <= IterationCount + 1'b1;
                    end
                end
                
                STATE_FINALIZE: begin
                    Result <= PackedArithmeticResult;
                    InvalidOperation <= 1'b0;
                    Overflow <= RounderOverflow;
                    Underflow <= RounderUnderflow;
                    Inexact <= RounderInexact;
                    BUSY <= 1'b0;
                    DONE <= 1'b1;
                    CurrentState <= STATE_IDLE;
                end
                
                default: begin
                    CurrentState <= STATE_IDLE;
                    BUSY <= 1'b0;
                    DONE <= 1'b0;
                    ProductRegister <= {PRODUCT_WIDTH{1'b0}};
                    MultiplicandRegister <= {PRODUCT_WIDTH{1'b0}};
                    MultiplierRegister <= {`FP16_SIGNIFICAND_WIDTH{1'b0}};
                    IterationCount <= 4'd0;
                end                                        
                endcase    
            end
            
       end
       
       assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact}; 
               
endmodule
