`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2026 10:57:13 PM
// Design Name: 
// Module Name: FP16Divider
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

module FP16Divider( input wire clk,
                    input wire reset,
                    input wire START,
                    input wire [`FP16_WIDTH - 1:0] OperandA,
                    input wire [`FP16_WIDTH - 1:0] OperandB,
                    output reg [`FP16_WIDTH - 1:0] Result,
                    output reg BUSY,
                    output reg DONE,
                    output reg InvalidOperation,
                    output reg DivideByZero,
                    output reg Overflow,
                    output reg Underflow,
                    output reg Inexact,
                    output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);

    localparam STATE_IDLE = 2'b00;
    localparam STATE_DIVIDE = 2'b01;
    localparam STATE_FINALIZE = 2'b10;
    localparam DIVISION_WIDTH = `FP16_SIGNIFICAND_WIDTH + `FP16_EXTENDED_SIGNIFICAND_WIDTH - 1;

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

    wire [3:0] LeadingZerosA;
    wire [3:0] LeadingZerosB;

    wire [`FP16_SIGNIFICAND_WIDTH - 1:0] NormalizedInputSignificandA;
    wire [`FP16_SIGNIFICAND_WIDTH - 1:0] NormalizedInputSignificandB;

    wire signed [6:0] LeadingZerosASigned;
    wire signed [6:0] LeadingZerosBSigned;

    wire signed [6:0] AdjustedExponentA;
    wire signed [6:0] AdjustedExponentB;
    wire signed [6:0] InputQuotientExponent;

    wire [`FP16_SIGNIFICAND_WIDTH:0] ShiftedRemainder;
    wire RemainderAtLeastDivisor;
    wire [`FP16_SIGNIFICAND_WIDTH:0] RemainderAfterStep;

    wire [DIVISION_WIDTH - 1:0] DividendAfterStep;
    wire [DIVISION_WIDTH - 1:0] QuotientAfterStep;

    wire DivisionRemainderNonzero;
    wire QuotientStickyBit;

    wire [`FP16_EXTENDED_SIGNIFICAND_WIDTH:0] QuotientForNormalization;

    wire [`FP16_EXTENDED_SIGNIFICAND_WIDTH - 1:0] NormalizedResultSignificand;
    wire signed [6:0] NormalizedResultExponent;

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

    reg [DIVISION_WIDTH - 1:0] DividendRegister;
    reg [DIVISION_WIDTH - 1:0] QuotientRegister;

    reg [`FP16_SIGNIFICAND_WIDTH:0] RemainderRegister;
    reg [`FP16_SIGNIFICAND_WIDTH - 1:0] DivisorRegister;

    reg [4:0] IterationCount;

    reg StoredResultSign;
    reg signed [6:0] StoredResultExponent;

    function [3:0] LeadingZeroCount11;
    input [`FP16_SIGNIFICAND_WIDTH - 1:0] Value;

        integer BitIndex;
        reg FoundOne;

        begin
            LeadingZeroCount11 = 4'd0;
            FoundOne = 1'b0;

            for (BitIndex = `FP16_SIGNIFICAND_WIDTH - 1; BitIndex >= 0; BitIndex = BitIndex - 1) begin
                if (!FoundOne) begin
                    if (Value[BitIndex]) begin
                        FoundOne = 1'b1;
                    end
                    else begin
                        LeadingZeroCount11 = LeadingZeroCount11 + 1'b1;
                    end
                end
            end
        end
    endfunction

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

    FP16SpecialCaseResolver SpecialCaseUnit (.OperandA(OperandA), .OperandB(OperandB), .Operation(`FP16_OP_DIVIDE),
                                            .SpecialCaseDetected(InputSpecialCaseDetected), .SpecialResult(InputSpecialResult),
                                            .InvalidOperation(InputInvalidOperation), .DivideByZero(InputDivideByZero));

    FP16Normalizer Normalizer (.SignificandIn(QuotientForNormalization), .ExponentIn(StoredResultExponent),
                               .SignificandOut(NormalizedResultSignificand), .ExponentOut(NormalizedResultExponent),
                               .IsZero(NormalizerIsZero), .IsNormal(NormalizerIsNormal),
                               .IsSubnormal(NormalizerIsSubnormal), .ExponentOverflow(NormalizerExponentOverflow));

    FP16Rounder Rounder (.Sign(StoredResultSign), .ExponentIn(NormalizedResultExponent),
                         .SignificandIn(NormalizedResultSignificand), .ResultSign(RoundedSign),
                         .StoredExponent(RoundedStoredExponent), .Fraction(RoundedFraction),
                         .Classification(RoundedClassification), .RoundedSignificand(RoundedSignificand),
                         .RoundedExponent(RoundedExponent), .Overflow(RounderOverflow),
                         .Underflow(RounderUnderflow), .Inexact(RounderInexact));

    FP16Packer ResultPacker (.Sign(RoundedSign), .StoredExponent(RoundedStoredExponent),
                            .Fraction(RoundedFraction), .Classification(RoundedClassification),
                            .PackedValue(PackedArithmeticResult));

    assign LeadingZerosA = LeadingZeroCount11(SignificandA);
    assign LeadingZerosB = LeadingZeroCount11(SignificandB);

    assign NormalizedInputSignificandA = SignificandA << LeadingZerosA;

    assign NormalizedInputSignificandB = SignificandB << LeadingZerosB;

    assign LeadingZerosASigned = $signed({3'b000, LeadingZerosA});

    assign LeadingZerosBSigned = $signed({3'b000, LeadingZerosB});

    assign AdjustedExponentA = UnbiasedExponentA - LeadingZerosASigned;

    assign AdjustedExponentB = UnbiasedExponentB - LeadingZerosBSigned;

    assign InputQuotientExponent = AdjustedExponentA - AdjustedExponentB;

    assign ShiftedRemainder = {RemainderRegister[`FP16_SIGNIFICAND_WIDTH - 1:0], DividendRegister[DIVISION_WIDTH - 1]};

    assign RemainderAtLeastDivisor = ShiftedRemainder >= {1'b0, DivisorRegister};

    assign RemainderAfterStep = RemainderAtLeastDivisor ? ShiftedRemainder - {1'b0, DivisorRegister} : ShiftedRemainder;

    assign DividendAfterStep = {DividendRegister[DIVISION_WIDTH - 2:0], 1'b0};

    assign QuotientAfterStep = {QuotientRegister[DIVISION_WIDTH - 2:0], RemainderAtLeastDivisor};

    assign DivisionRemainderNonzero = |(RemainderRegister);

    assign QuotientStickyBit = ((QuotientRegister[0]) | (DivisionRemainderNonzero));

    assign QuotientForNormalization = {QuotientRegister[14:1], QuotientStickyBit};

    always @(posedge clk) begin
        if (reset) begin
            CurrentState <= STATE_IDLE;

            Result <= `FP16_POSITIVE_ZERO;

            BUSY <= 1'b0;
            DONE <= 1'b0;

            InvalidOperation <= 1'b0;
            DivideByZero <= 1'b0;
            Overflow <= 1'b0;
            Underflow <= 1'b0;
            Inexact <= 1'b0;

            DividendRegister <= {DIVISION_WIDTH{1'b0}};
            QuotientRegister <= {DIVISION_WIDTH{1'b0}};
            RemainderRegister <= {(`FP16_SIGNIFICAND_WIDTH + 1){1'b0}};
            DivisorRegister <= {`FP16_SIGNIFICAND_WIDTH{1'b0}};

            IterationCount <= 5'd0;

            StoredResultSign <= 1'b0;
            StoredResultExponent <= 7'sd0;
        end
        else begin
            DONE <= 1'b0;

            case (CurrentState)

                STATE_IDLE: begin
                    BUSY <= 1'b0;

                    if (START) begin
                        InvalidOperation <= 1'b0;
                        DivideByZero <= 1'b0;
                        Overflow <= 1'b0;
                        Underflow <= 1'b0;
                        Inexact <= 1'b0;

                        if (InputSpecialCaseDetected) begin
                            Result <= InputSpecialResult;

                            InvalidOperation <= InputInvalidOperation;
                            DivideByZero <= InputDivideByZero;

                            BUSY <= 1'b0;
                            DONE <= 1'b1;

                            CurrentState <= STATE_IDLE;
                        end
                        else begin
                            DividendRegister <= {NormalizedInputSignificandA, 13'b0000000000000};
                            DivisorRegister <= NormalizedInputSignificandB;
                            QuotientRegister <= {DIVISION_WIDTH{1'b0}};
                            RemainderRegister <= {(`FP16_SIGNIFICAND_WIDTH + 1){1'b0}};

                            StoredResultSign <= SignA ^ SignB;
                            StoredResultExponent <= InputQuotientExponent;

                            IterationCount <= 5'd0;

                            BUSY <= 1'b1;
                            CurrentState <= STATE_DIVIDE;
                        end
                    end
                end

                STATE_DIVIDE: begin
                    BUSY <= 1'b1;

                    DividendRegister <= DividendAfterStep;
                    QuotientRegister <= QuotientAfterStep;
                    RemainderRegister <= RemainderAfterStep;

                    if (IterationCount == DIVISION_WIDTH - 1) begin
                        CurrentState <= STATE_FINALIZE;
                    end
                    else begin
                        IterationCount <= IterationCount + 1'b1;
                    end
                end

                STATE_FINALIZE: begin
                    Result <= PackedArithmeticResult;

                    InvalidOperation <= 1'b0;
                    DivideByZero <= 1'b0;
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

                    DividendRegister <= {DIVISION_WIDTH{1'b0}};
                    QuotientRegister <= {DIVISION_WIDTH{1'b0}};
                    RemainderRegister <= {(`FP16_SIGNIFICAND_WIDTH + 1){1'b0}};

                    IterationCount <= 5'd0;
                end

            endcase
        end
    end

    assign ExceptionVector = {InvalidOperation, DivideByZero, Overflow, Underflow, Inexact};

endmodule