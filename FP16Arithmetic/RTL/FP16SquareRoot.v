`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2026 04:22:03 AM
// Design Name: 
// Module Name: FP16SquareRoot
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

module FP16SquareRoot( input wire clk,
                       input wire reset,
                       input wire START,
                       input wire [`FP16_WIDTH - 1:0] Radicand,
                       output reg [`FP16_WIDTH - 1:0] Result,
                       output reg BUSY,
                       output reg DONE,
                       output reg InvalidOperation,
                       output reg Overflow,
                       output reg Underflow,
                       output reg Inexact,
                       output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);

    localparam STATE_IDLE = 2'b00;
    localparam STATE_SQUARE_ROOT = 2'b01;
    localparam STATE_FINALIZE = 2'b10;
    localparam INTERNAL_RADICAND_WIDTH = 30;
    localparam INTERNAL_ROOT_WIDTH = 15;
    localparam INTERNAL_REMAINDER_WIDTH = 17;
    localparam NUMBER_OF_ITERATIONS = 15;

    wire RadicandSign;

    wire [`FP16_EXPONENT_WIDTH - 1:0] RadicandStoredExponent;
    wire [`FP16_FRACTION_WIDTH - 1:0] RadicandFraction;
    wire signed [6:0] RadicandUnbiasedExponent;
    wire [`FP16_SIGNIFICAND_WIDTH - 1:0] RadicandSignificand;
    wire [`FP16_CLASS_WIDTH - 1:0] RadicandClassification;

    wire RadicandIsZero;
    wire RadicandIsSubnormal;
    wire RadicandIsNormal;
    wire RadicandIsInfinity;
    wire RadicandIsNaN;
    wire RadicandIsQuietNaN;
    wire RadicandIsSignalingNaN;

    wire InputSpecialCaseDetected;
    wire [`FP16_WIDTH - 1:0] InputSpecialResult;
    wire InputInvalidOperation;
    wire InputDivideByZero;

    wire [3:0] RadicandLeadingZeros;

    wire [`FP16_SIGNIFICAND_WIDTH - 1:0] NormalizedInputSignificand;
    wire signed [6:0] RadicandLeadingZerosSigned;
    wire signed [6:0] AdjustedRadicandExponent;

    wire ExponentIsOdd;
    wire signed [6:0] EvenRadicandExponent;
    wire signed [6:0] InputResultExponent;

    wire [INTERNAL_RADICAND_WIDTH - 1:0] EvenExponentIntegerRadicand;
    wire [INTERNAL_RADICAND_WIDTH - 1:0] OddExponentIntegerRadicand;
    wire [INTERNAL_RADICAND_WIDTH - 1:0] InputIntegerRadicand;

    wire [INTERNAL_REMAINDER_WIDTH - 1:0] ShiftedRemainder;
    wire [INTERNAL_REMAINDER_WIDTH - 1:0] TrialDivisor;
    wire TrialSubtractAllowed;
    wire [INTERNAL_REMAINDER_WIDTH - 1:0] RemainderAfterStep;
    wire [INTERNAL_ROOT_WIDTH - 1:0] RootAfterStep;
    wire [INTERNAL_RADICAND_WIDTH - 1:0] RadicandAfterStep;

    wire SquareRootRemainderNonzero;
    wire RootStickyBit;

    wire [`FP16_EXTENDED_SIGNIFICAND_WIDTH:0] RootForNormalization;

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

    reg [INTERNAL_RADICAND_WIDTH - 1:0] RadicandRegister;
    reg [INTERNAL_ROOT_WIDTH - 1:0] RootRegister;
    reg [INTERNAL_REMAINDER_WIDTH - 1:0] RemainderRegister;

    reg [3:0] IterationCount;

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

    FP16Unpacker UnpackRadicand (.Value(Radicand), .Sign(RadicandSign), .StoredExponent(RadicandStoredExponent),
                                 .Fraction(RadicandFraction), .UnbiasedExponent(RadicandUnbiasedExponent),
                                 .Significand(RadicandSignificand), .Classification(RadicandClassification),
                                 .IsZero(RadicandIsZero), .IsSubnormal(RadicandIsSubnormal), .IsNormal(RadicandIsNormal),
                                 .IsInfinity(RadicandIsInfinity), .IsNaN(RadicandIsNaN), .IsQuietNaN(RadicandIsQuietNaN),
                                 .IsSignalingNaN(RadicandIsSignalingNaN));

    FP16SpecialCaseResolver SpecialCaseUnit (.OperandA(Radicand), .OperandB(`FP16_POSITIVE_ZERO),
                                            .Operation(`FP16_OP_SQUARE_ROOT),
                                            .SpecialCaseDetected(InputSpecialCaseDetected),
                                            .SpecialResult(InputSpecialResult),
                                            .InvalidOperation(InputInvalidOperation),
                                            .DivideByZero(InputDivideByZero));

    FP16Normalizer Normalizer (.SignificandIn(RootForNormalization), .ExponentIn(StoredResultExponent),
                               .SignificandOut(NormalizedResultSignificand), .ExponentOut(NormalizedResultExponent),
                               .IsZero(NormalizerIsZero), .IsNormal(NormalizerIsNormal),
                               .IsSubnormal(NormalizerIsSubnormal), .ExponentOverflow(NormalizerExponentOverflow));

    FP16Rounder Rounder (.Sign(`FP16_SIGN_POSITIVE), .ExponentIn(NormalizedResultExponent),
                         .SignificandIn(NormalizedResultSignificand), .ResultSign(RoundedSign),
                         .StoredExponent(RoundedStoredExponent), .Fraction(RoundedFraction),
                         .Classification(RoundedClassification), .RoundedSignificand(RoundedSignificand),
                         .RoundedExponent(RoundedExponent), .Overflow(RounderOverflow),
                         .Underflow(RounderUnderflow), .Inexact(RounderInexact));

    FP16Packer ResultPacker (.Sign(RoundedSign), .StoredExponent(RoundedStoredExponent),
                            .Fraction(RoundedFraction), .Classification(RoundedClassification),
                            .PackedValue(PackedArithmeticResult));

    assign RadicandLeadingZeros = LeadingZeroCount11(RadicandSignificand);

    assign NormalizedInputSignificand = RadicandSignificand << RadicandLeadingZeros;

    assign RadicandLeadingZerosSigned = $signed({3'b000, RadicandLeadingZeros});

    assign AdjustedRadicandExponent = RadicandUnbiasedExponent - RadicandLeadingZerosSigned;

    assign ExponentIsOdd = AdjustedRadicandExponent[0];

    assign EvenRadicandExponent = ExponentIsOdd ? AdjustedRadicandExponent - 7'sd1 : AdjustedRadicandExponent;

    assign InputResultExponent = EvenRadicandExponent >>> 1;

    assign EvenExponentIntegerRadicand = {{(INTERNAL_RADICAND_WIDTH - `FP16_SIGNIFICAND_WIDTH){1'b0}}, NormalizedInputSignificand} << 16;

    assign OddExponentIntegerRadicand = {{(INTERNAL_RADICAND_WIDTH - `FP16_SIGNIFICAND_WIDTH){1'b0}}, NormalizedInputSignificand} << 17;

    assign InputIntegerRadicand = ExponentIsOdd ? OddExponentIntegerRadicand : EvenExponentIntegerRadicand;

    assign ShiftedRemainder = {RemainderRegister[INTERNAL_REMAINDER_WIDTH - 3:0], RadicandRegister[INTERNAL_RADICAND_WIDTH - 1: INTERNAL_RADICAND_WIDTH - 2]};

    assign TrialDivisor = {RootRegister, 2'b01};

    assign TrialSubtractAllowed =
        ShiftedRemainder >= TrialDivisor;

    assign RemainderAfterStep = TrialSubtractAllowed ? (ShiftedRemainder - TrialDivisor) : ShiftedRemainder;

    assign RootAfterStep = {RootRegister[INTERNAL_ROOT_WIDTH - 2:0], TrialSubtractAllowed};

    assign RadicandAfterStep = {RadicandRegister[INTERNAL_RADICAND_WIDTH - 3:0], 2'b00};

    assign SquareRootRemainderNonzero = |(RemainderRegister);

    assign RootStickyBit = RootRegister[0] | SquareRootRemainderNonzero;

    assign RootForNormalization = {1'b0, RootRegister[13:1], RootStickyBit};

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

            RadicandRegister <= {INTERNAL_RADICAND_WIDTH{1'b0}};
            RootRegister <= {INTERNAL_ROOT_WIDTH{1'b0}};
            RemainderRegister <= {INTERNAL_REMAINDER_WIDTH{1'b0}};

            IterationCount <= 4'd0;
            StoredResultExponent <= 7'sd0;
        end
        else begin
            DONE <= 1'b0;

            case (CurrentState)

                STATE_IDLE: begin
                    BUSY <= 1'b0;

                    if (START) begin
                        InvalidOperation <= 1'b0;
                        Overflow <= 1'b0;
                        Underflow <= 1'b0;
                        Inexact <= 1'b0;

                        if (InputSpecialCaseDetected) begin
                            Result <= InputSpecialResult;

                            InvalidOperation <= InputInvalidOperation;

                            BUSY <= 1'b0;
                            DONE <= 1'b1;

                            CurrentState <= STATE_IDLE;
                        end
                        else begin
                            RadicandRegister <= InputIntegerRadicand;

                            RootRegister <= {INTERNAL_ROOT_WIDTH{1'b0}};
                            RemainderRegister <= {INTERNAL_REMAINDER_WIDTH{1'b0}};

                            IterationCount <= 4'd0;

                            StoredResultExponent <= InputResultExponent;

                            BUSY <= 1'b1;
                            CurrentState <= STATE_SQUARE_ROOT;
                        end
                    end
                end

                STATE_SQUARE_ROOT: begin
                    BUSY <= 1'b1;

                    RadicandRegister <= RadicandAfterStep;
                    RootRegister <= RootAfterStep;
                    RemainderRegister <= RemainderAfterStep;

                    if (IterationCount == NUMBER_OF_ITERATIONS - 1) begin
                        CurrentState <= STATE_FINALIZE;
                    end
                    else begin
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

                    RadicandRegister <= {INTERNAL_RADICAND_WIDTH{1'b0}};
                    RootRegister <= {INTERNAL_ROOT_WIDTH{1'b0}};
                    RemainderRegister <= {INTERNAL_REMAINDER_WIDTH{1'b0}};

                    IterationCount <= 4'd0;
                end

            endcase
        end
    end

    assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact};

endmodule
