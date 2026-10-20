`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 01:15:36 AM
// Design Name: 
// Module Name: FP32AccumulatorAdder
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

module FP32AccumulatorAdder( input wire [31:0] OperandA,
                             input wire [31:0] OperandB,
                             output reg [31:0] Result,
                             output reg InvalidOperation,
                             output reg Overflow,
                             output reg Underflow,
                             output reg Inexact,
                             output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector);
      
      localparam FP32_EXPONENT_BIAS = 127;
      localparam signed [9:0] FP32_MINIMUM_NORMAL_EXPONENT = -10'sd126;
      localparam signed [9:0] FP32_MAXIMUM_NORMAL_EXPONENT = 10'sd127;
      localparam [31:0] FP32_POSITIVE_ZERO = 32'h00000000;
      localparam [31:0] FP32_POSITIVE_INFINITY = 32'h7F800000;
      localparam [31:0] FP32_CANONICAL_QUIET_NAN = 32'h7FC00000;
      localparam FP32_SIGNIFICAND_WIDTH = 24;
      localparam FP32_EXTENDED_WIDTH = 27;
      
      wire SignA;
      wire SignB;
      wire [7:0] StoredExponentA;
      wire [7:0] StoredExponentB;
      wire [22:0] FractionA;
      wire [22:0] FractionB;
      
      wire AIsZero;
      wire AIsSubnormal;
      wire AIsNormal;
      wire AIsInfinity;
      wire AIsNaN;
      wire AIsQuietNaN;
      wire AIsSignalingNaN;

      wire BIsZero;
      wire BIsSubnormal;
      wire BIsNormal;
      wire BIsInfinity;
      wire BIsNaN;
      wire BIsQuietNaN;
      wire BIsSignalingNaN;
      
      wire [23:0] SignificandA;
      wire [23:0] SignificandB;
      
      wire signed [9:0] UnbiasedExponentA;
      wire signed [9:0] UnbiasedExponentB;
      
      reg [FP32_EXTENDED_WIDTH - 1:0] ExtendedA;
      reg [FP32_EXTENDED_WIDTH - 1:0] ExtendedB;
      
      reg [FP32_EXTENDED_WIDTH - 1:0] LargerSignificand;
      reg [FP32_EXTENDED_WIDTH - 1:0] SmallerSignificand;
      reg [FP32_EXTENDED_WIDTH - 1:0] AlignedSmallerSignificand;
      
      reg LargerSign;
      reg SmallerSign;
      reg ResultSign;
      
      reg signed [9:0] LargerExponent;
      reg signed [9:0] SmallerExponent;
      reg signed [9:0] WorkingExponent;
      
      reg [8:0] ExponentDifference;
      
      reg [FP32_EXTENDED_WIDTH:0] ArithmeticSignificand;
      reg [FP32_EXTENDED_WIDTH - 1:0] WorkingSignificand;
      
      reg [23:0] RetainedSignificand;
      reg [24:0] RoundedSignificand;
      
      reg GuardBit;
      reg RoundBit;
      reg StickyBit;
      reg RoundIncrement;
      
      reg [7:0] ResultStoredExponent;
      reg [22:0] ResultFraction;
      
      reg [22:0] NaNPayload;
      
      
      
      assign SignA = OperandA[31];
      assign SignB = OperandB[31];
      assign StoredExponentA = OperandA[30:23];
      assign StoredExponentB = OperandB[30:23];
      assign FractionA = OperandA[22:0];
      assign FractionB = OperandB[22:0];
      
      assign AIsZero = (StoredExponentA == 8'h00) && (FractionA == 23'h000000);
      assign AIsSubnormal = (StoredExponentA == 8'h00) && (FractionA != 23'h000000);
      assign AIsNormal = (StoredExponentA != 8'h00) && (StoredExponentA != 8'hFF);
      assign AIsInfinity = (StoredExponentA == 8'hFF) && (FractionA == 23'h000000);
      assign AIsNaN = (StoredExponentA == 8'hFF) && (FractionA != 23'h000000);
      assign AIsQuietNaN = AIsNaN && FractionA[22];
      assign AIsSignalingNaN = AIsNaN && !FractionA[22];
      
      assign BIsZero = (StoredExponentB == 8'h00) && (FractionB == 23'h000000);
      assign BIsSubnormal = (StoredExponentB == 8'h00) && (FractionB != 23'h000000);
      assign BIsNormal = (StoredExponentB != 8'h00) && (StoredExponentB != 8'hFF);
      assign BIsInfinity = (StoredExponentB == 8'hFF) && (FractionB == 23'h000000);
      assign BIsNaN = (StoredExponentB == 8'hFF) && (FractionB != 23'h000000);
      assign BIsQuietNaN = BIsNaN && FractionB[22];
      assign BIsSignalingNaN = BIsNaN && !FractionB[22];
                             
      assign SignificandA = (StoredExponentA == 8'h00) ? {1'b0, FractionA} : {1'b1, FractionA};
      assign SignificandB = (StoredExponentB == 8'h00) ? {1'b0, FractionB} : {1'b1, FractionB};    
      
      assign UnbiasedExponentA = (StoredExponentA == 8'h00) ? FP32_MINIMUM_NORMAL_EXPONENT : $signed({2'b00, StoredExponentA}) - 10'sd127;
      assign UnbiasedExponentB = (StoredExponentB == 8'h00) ? FP32_MINIMUM_NORMAL_EXPONENT : $signed({2'b00, StoredExponentB}) - 10'sd127;
      
      function [FP32_EXTENDED_WIDTH - 1:0] ShiftRightJam27;
        input [FP32_EXTENDED_WIDTH - 1:0] Value;
        input [8:0] ShiftAmount;
        integer BitIndex;
        reg Sticky;
        reg [FP32_EXTENDED_WIDTH - 1:0] Shifted;
        begin
            Sticky  = 1'b0;
            Shifted = {FP32_EXTENDED_WIDTH{1'b0}};
            if (ShiftAmount == 0) begin
                Shifted = Value;
            end
            else
                if (ShiftAmount >= FP32_EXTENDED_WIDTH) begin
                    Shifted = {FP32_EXTENDED_WIDTH{1'b0}};
                    Shifted[0] = |(Value);    
                end
                else
                begin
                    Shifted = Value >> ShiftAmount;
                    for (BitIndex = 0; BitIndex < FP32_EXTENDED_WIDTH; BitIndex = BitIndex + 1) begin
                        if (BitIndex < ShiftAmount) begin
                            Sticky = Sticky | Value[BitIndex];
                        end
                    end
                    
                    Shifted[0] = Shifted[0] | Sticky;
                end
                ShiftRightJam27 = Shifted;
            end
      endfunction  
      
      integer NormalizeIteration;
      
      
      
      always @(*) begin
        Result = FP32_POSITIVE_ZERO;
        InvalidOperation = 1'b0;
        Overflow = 1'b0;
        Underflow = 1'b0;
        Inexact = 1'b0;
        
        ExtendedA = {SignificandA, 3'b000};
        ExtendedB = {SignificandB, 3'b000};
        
        LargerSignificand = {FP32_EXTENDED_WIDTH{1'b0}};
        SmallerSignificand = {FP32_EXTENDED_WIDTH{1'b0}};
        AlignedSmallerSignificand = {FP32_EXTENDED_WIDTH{1'b0}};
        
        LargerSign = 1'b0;
        SmallerSign = 1'b0;
        ResultSign = 1'b0;
        
        LargerExponent  = 10'sd0;
        SmallerExponent = 10'sd0;
        WorkingExponent = 10'sd0;
        
        ExponentDifference = 9'd0;
        
        ArithmeticSignificand = {(FP32_EXTENDED_WIDTH + 1){1'b0}};
        
        WorkingSignificand = {FP32_EXTENDED_WIDTH{1'b0}};

        RetainedSignificand = 24'd0;
        RoundedSignificand = 25'd0;
        
        GuardBit = 1'b0;
        RoundBit = 1'b0;
        StickyBit = 1'b0;
        RoundIncrement = 1'b0;
        
        ResultStoredExponent = 8'h00;
        ResultFraction = 23'h000000;
        
        NaNPayload = 23'h400000;
        
        
        if (AIsNaN || BIsNaN) begin
            InvalidOperation = AIsSignalingNaN || BIsSignalingNaN;
                if (AIsNaN) begin
                    NaNPayload = FractionA;
                end
                else 
                begin
                    NaNPayload = FractionB;
                end
                NaNPayload[22] = 1'b1;
                Result = {1'b0, 8'hFF, NaNPayload};
        end
        else
            if (AIsInfinity && BIsInfinity && (SignA != SignB)) begin
                Result = FP32_CANONICAL_QUIET_NAN;
                InvalidOperation = 1'b1;
            end
            else
                if (AIsInfinity) begin
                    Result = {SignA, 8'hFF, 23'h000000};
                end
                else 
                    if (BIsInfinity) begin
                        Result = {SignB, 8'hFF, 23'h000000};
                    end
                    else
                        if (AIsZero && BIsZero) begin
                            Result = {SignA & SignB, 31'b0};
                        end
                        else
                            if (AIsZero) begin
                                Result = OperandB;
                            end
                            else 
                                if (BIsZero) begin
                                    Result = OperandA;
                                end
                                else 
                                begin
                                    if ((UnbiasedExponentA > UnbiasedExponentB) || ((UnbiasedExponentA == UnbiasedExponentB) && (SignificandA >= SignificandB))) begin
                                        LargerSignificand  = ExtendedA;
                                        SmallerSignificand = ExtendedB;
                                        LargerExponent  = UnbiasedExponentA;
                                        SmallerExponent = UnbiasedExponentB;
                                        LargerSign  = SignA;
                                        SmallerSign = SignB;
                                    end
                                    else
                                    begin
                                        LargerSignificand  = ExtendedB;
                                        SmallerSignificand = ExtendedA;
                                        LargerExponent  = UnbiasedExponentB;
                                        SmallerExponent = UnbiasedExponentA;
                                        LargerSign  = SignB;
                                        SmallerSign = SignA;
                                    end
                                    
                                    ExponentDifference = LargerExponent - SmallerExponent;
                                    AlignedSmallerSignificand = ShiftRightJam27(SmallerSignificand, ExponentDifference);
                                    WorkingExponent = LargerExponent;
                                    ResultSign = LargerSign;
                                    
                                    if(LargerSign == SmallerSign) begin
                                        ArithmeticSignificand = {1'b0, LargerSignificand} + {1'b0, AlignedSmallerSignificand};
                                    end
                                    else
                                    begin
                                        ArithmeticSignificand = {1'b0, LargerSignificand} - {1'b0, AlignedSmallerSignificand};
                                    end
                                    
                                    if (ArithmeticSignificand == {(FP32_EXTENDED_WIDTH + 1){1'b0}})begin
                                        Result = FP32_POSITIVE_ZERO;
                                    end
                                    else 
                                    begin
                                        if(ArithmeticSignificand[FP32_EXTENDED_WIDTH]) begin
                                            WorkingSignificand = ArithmeticSignificand[FP32_EXTENDED_WIDTH:1];
                                            WorkingSignificand[0] = WorkingSignificand[0] | ArithmeticSignificand[0];
                                            WorkingExponent = WorkingExponent + 10'sd1;
                                        end
                                        else 
                                        begin
                                            WorkingSignificand = ArithmeticSignificand[FP32_EXTENDED_WIDTH - 1:0];
                                        end
                                        
                                        for(NormalizeIteration = 0;NormalizeIteration < FP32_EXTENDED_WIDTH; NormalizeIteration = NormalizeIteration + 1) begin
                                            if (!WorkingSignificand[FP32_EXTENDED_WIDTH - 1] && (WorkingSignificand != 0) && (WorkingExponent > FP32_MINIMUM_NORMAL_EXPONENT)) begin
                                                WorkingSignificand = WorkingSignificand << 1;
                                                WorkingExponent = WorkingExponent - 10'sd1;
                                            end    
                                        end
                                        if (WorkingExponent < FP32_MINIMUM_NORMAL_EXPONENT) begin
                                            ExponentDifference = FP32_MINIMUM_NORMAL_EXPONENT - WorkingExponent;
                                            WorkingSignificand = ShiftRightJam27(WorkingSignificand, ExponentDifference);
                                            WorkingExponent = FP32_MINIMUM_NORMAL_EXPONENT;
                                        end
                                        
                                        RetainedSignificand = WorkingSignificand[26:3];
                                        GuardBit = WorkingSignificand[2];    
                                        RoundBit = WorkingSignificand[1];
                                        StickyBit = WorkingSignificand[0];
                                        Inexact = GuardBit | RoundBit | StickyBit;
                                        
                                        RoundIncrement = GuardBit && (RoundBit || StickyBit || RetainedSignificand[0]);
                                        RoundedSignificand = {1'b0, RetainedSignificand} + RoundIncrement;
                                        
                                        if (RoundedSignificand[24]) begin
                                            RetainedSignificand = RoundedSignificand[24:1];
                                            WorkingExponent = WorkingExponent + 10'sd1;
                                        end
                                        else 
                                        begin
                                            RetainedSignificand = RoundedSignificand[23:0];
                                        end
                                        
                                        if (WorkingExponent > FP32_MAXIMUM_NORMAL_EXPONENT) begin
                                            Result = {ResultSign, 8'hFF, 23'h000000};
                                            Overflow = 1'b1;
                                            Inexact  = 1'b1;
                                        end
                                        else
                                        begin
                                            if (RetainedSignificand[23]) begin
                                                ResultStoredExponent = WorkingExponent + FP32_EXPONENT_BIAS;
                                                ResultFraction = RetainedSignificand[22:0];
                                            end
                                            else 
                                            begin
                                                ResultStoredExponent = 8'h00;
                                                ResultFraction = RetainedSignificand[22:0];
                                            end
                                            
                                            Result = {ResultSign, ResultStoredExponent, ResultFraction};
                                            Underflow = (ResultStoredExponent == 8'h00) && Inexact;
                                        end
                                    end
                                end
                end
                
    assign ExceptionVector = {InvalidOperation, 1'b0, Overflow, Underflow, Inexact};
    
endmodule