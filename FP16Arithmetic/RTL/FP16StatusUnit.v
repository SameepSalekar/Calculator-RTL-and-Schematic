`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2026 03:23:29 PM
// Design Name: 
// Module Name: FP16StatusUnit
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

module FP16StatusUnit( input wire [`FP16_WIDTH - 1:0] Result,
                       input wire InvalidIn,
                       input wire DivideByZeroIn,
                       input wire OverflowIn,
                       input wire UnderflowIn,
                       input wire InexactIn,
                       output wire [`FP16_CLASS_WIDTH - 1:0] Classification,
                       output wire [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector,
                       output wire ResultSign,
                       output wire Zero,
                       output wire PositiveZero,
                       output wire NegativeZero,
                       output wire Subnormal,
                       output wire Normal,
                       output wire Finite,
                       output wire Infinity,
                       output wire PositiveInfinity,
                       output wire NegativeInfinity,
                       output wire NaN,
                       output wire QuietNaN,
                       output wire SignalingNaN,
                       output wire Negative,
                       output wire Invalid,
                       output wire DivideByZero,
                       output wire Overflow,
                       output wire Underflow,
                       output wire Inexact,
                       output wire AnyException );
       
       FP16Classifier ResultClassifier (.Value(Result), .Sign(ResultSign), .IsZero(Zero), .IsPositiveZero(PositiveZero), .IsNegativeZero(NegativeZero),
                                        .IsSubnormal(Subnormal), .IsNormal(Normal), .IsFinite(Finite), .IsInfinity(Infinity), .IsPositiveInfinity(PositiveInfinity),
                                        .IsNegativeInfinity(NegativeInfinity), .IsNaN(NaN), .IsQuietNaN(QuietNaN), .IsSignalingNaN(SignalingNaN), .Classification(Classification));
                                        
        assign Negative = ResultSign && !NaN;
        assign Invalid = InvalidIn;
        assign DivideByZero = DivideByZeroIn;
        assign Overflow = OverflowIn;
        assign Underflow = UnderflowIn;
        assign Inexact = InexactIn;
        
        assign ExceptionVector[`FP16_EXCEPTION_INVALID_BIT] = Invalid;
        assign ExceptionVector[`FP16_EXCEPTION_DIVZERO_BIT] = DivideByZero;
        assign ExceptionVector[`FP16_EXCEPTION_OVERFLOW_BIT] = Overflow;
        assign ExceptionVector[`FP16_EXCEPTION_UNDERFLOW_BIT] = Underflow;
        assign ExceptionVector[`FP16_EXCEPTION_INEXACT_BIT] = Inexact;                                                 
        
        assign AnyException = |(ExceptionVector);              
                       
endmodule
