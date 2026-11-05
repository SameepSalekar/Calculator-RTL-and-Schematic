`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/26/2026 04:27:18 PM
// Design Name: 
// Module Name: FP16ArithmeticEngine
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

module FP16ArithmeticEngine( input wire clk,
                             input wire reset,
                             input wire Start,
                             input wire Clear,
                             input wire [`FP16_OPERATION_WIDTH - 1:0] Operation,
                             input wire [`FP16_WIDTH - 1:0] OperandA,
                             input wire [`FP16_WIDTH - 1:0] OperandB,
                             output reg [`FP16_WIDTH - 1:0] Result,
                             output reg [31:0] WideResult,
                             output reg Busy,
                             output reg Done,
                             output reg InvalidOperation,
                             output reg DivideByZero,
                             output reg Overflow,
                             output reg Underflow,
                             output reg Inexact,
                             output reg [`FP16_EXCEPTION_WIDTH - 1:0] ExceptionVector,
                             output reg Greater,
                             output reg Equal,
                             output reg Lesser,
                             output reg Unordered );

      wire Subtract;
      wire [`FP16_WIDTH - 1:0] AddSubResult;
      wire AddSubInvalidOperation;
      wire AddSubOverflow;
      wire AddSubUnderflow;
      wire AddSubInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] AddSubExceptionVector;

      wire [`FP16_WIDTH - 1:0] CombinationalMultiplierResult;
      wire CombinationalMultiplierInvalidOperation;
      wire CombinationalMultiplierOverflow;
      wire CombinationalMultiplierUnderflow;
      wire CombinationalMultiplierInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] CombinationalMultiplierExceptionVector;

      wire SequentialMultiplierStart;
      wire [`FP16_WIDTH - 1:0] SequentialMultiplierResult;
      wire SequentialMultiplierBusy;
      wire SequentialMultiplierDone;
      wire SequentialMultiplierInvalidOperation;
      wire SequentialMultiplierOverflow;
      wire SequentialMultiplierUnderflow;
      wire SequentialMultiplierInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] SequentialMultiplierExceptionVector;

      wire ComparatorGreater;
      wire ComparatorEqual;
      wire ComparatorLesser;
      wire ComparatorUnordered;
      wire ComparatorInvalidOperation;

      wire AccumulatorEnable;
      wire AccumulatorReset;
      wire [`FP16_WIDTH - 1:0] AccumulatorSum;
      wire AccumulatorInvalidOperation;
      wire AccumulatorOverflow;
      wire AccumulatorUnderflow;
      wire AccumulatorInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] AccumulatorExceptionVector;

      wire WideAccumulatorEnable;
      wire WideAccumulatorReset;
      wire [31:0] WideAccumulatorSum;
      wire WideAccumulatorInvalidOperation;
      wire WideAccumulatorOverflow;
      wire WideAccumulatorUnderflow;
      wire WideAccumulatorInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] WideAccumulatorExceptionVector;

      wire MACEnable;
      wire MACReset;
      wire [`FP16_WIDTH - 1:0] MACSum;
      wire MACInvalidOperation;
      wire MACOverflow;
      wire MACUnderflow;
      wire MACInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] MACExceptionVector;

      wire DividerStart;
      wire [`FP16_WIDTH - 1:0] DividerResult;
      wire DividerBusy;
      wire DividerDone;
      wire DividerInvalidOperation;
      wire DividerDivideByZero;
      wire DividerOverflow;
      wire DividerUnderflow;
      wire DividerInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] DividerExceptionVector;

      wire SquareRootStart;
      wire [`FP16_WIDTH - 1:0] SquareRootResult;
      wire SquareRootBusy;
      wire SquareRootDone;
      wire SquareRootInvalidOperation;
      wire SquareRootOverflow;
      wire SquareRootUnderflow;
      wire SquareRootInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] SquareRootExceptionVector;

      wire RunningProductStart;
      wire RunningProductClear;
      wire [`FP16_WIDTH - 1:0] RunningProductResult;
      wire RunningProductBusy;
      wire RunningProductDone;
      wire RunningProductInvalidOperation;
      wire RunningProductOverflow;
      wire RunningProductUnderflow;
      wire RunningProductInexact;
      wire [`FP16_EXCEPTION_WIDTH - 1:0] RunningProductExceptionVector;

      assign Subtract = (Operation == `FP16_OP_SUBTRACT);
      assign SequentialMultiplierStart = Start && (Operation == `FP16_OP_SEQUENTIAL_MULTIPLY) && ~SequentialMultiplierBusy;
      assign AccumulatorEnable = Start && (Operation == `FP16_OP_ACCUMULATE);
      assign AccumulatorReset = reset || (Clear && (Operation == `FP16_OP_ACCUMULATE));
      assign WideAccumulatorEnable = Start && (Operation == `FP16_OP_WIDE_ACCUMULATE);
      assign WideAccumulatorReset = reset || (Clear && (Operation == `FP16_OP_WIDE_ACCUMULATE));
      assign MACEnable = Start && (Operation == `FP16_OP_MAC);
      assign MACReset = reset || (Clear && (Operation == `FP16_OP_MAC));
      assign DividerStart = Start && (Operation == `FP16_OP_DIVIDE) && ~DividerBusy;
      assign SquareRootStart = Start && (Operation == `FP16_OP_SQUARE_ROOT) && ~SquareRootBusy;
      assign RunningProductStart = Start && (Operation == `FP16_OP_RUNNING_PRODUCT) && ~RunningProductBusy;
      assign RunningProductClear = Clear && (Operation == `FP16_OP_RUNNING_PRODUCT);

      FP16AddSub AddSubtractUnit (.OperandA(OperandA), .OperandB(OperandB), .Subtract(Subtract),
                                  .Result(AddSubResult), .InvalidOperation(AddSubInvalidOperation),
                                  .Overflow(AddSubOverflow), .Underflow(AddSubUnderflow),
                                  .Inexact(AddSubInexact), .ExceptionVector(AddSubExceptionVector));

      FP16CombinationalMultiplier CombinationalMultiplierUnit (.OperandA(OperandA), .OperandB(OperandB),
                                                               .Result(CombinationalMultiplierResult),
                                                               .InvalidOperation(CombinationalMultiplierInvalidOperation),
                                                               .Overflow(CombinationalMultiplierOverflow),
                                                               .Underflow(CombinationalMultiplierUnderflow),
                                                               .Inexact(CombinationalMultiplierInexact),
                                                               .ExceptionVector(CombinationalMultiplierExceptionVector));

      FP16SequentialMultiplier SequentialMultiplierUnit (.clk(clk), .reset(reset),
                                                         .START(SequentialMultiplierStart),
                                                         .OperandA(OperandA), .OperandB(OperandB),
                                                         .Result(SequentialMultiplierResult),
                                                         .BUSY(SequentialMultiplierBusy),
                                                         .DONE(SequentialMultiplierDone),
                                                         .InvalidOperation(SequentialMultiplierInvalidOperation),
                                                         .Overflow(SequentialMultiplierOverflow),
                                                         .Underflow(SequentialMultiplierUnderflow),
                                                         .Inexact(SequentialMultiplierInexact),
                                                         .ExceptionVector(SequentialMultiplierExceptionVector));

      FP16Comparator ComparatorUnit (.OperandA(OperandA), .OperandB(OperandB),
                                     .Greater(ComparatorGreater), .Equal(ComparatorEqual),
                                     .Lesser(ComparatorLesser), .Unordered(ComparatorUnordered),
                                     .InvalidOperation(ComparatorInvalidOperation));

      FP16Accumulator AccumulatorUnit (.clk(clk), .reset(AccumulatorReset), .enable(AccumulatorEnable),
                                       .X(OperandA), .Sum(AccumulatorSum),
                                       .InvalidOperation(AccumulatorInvalidOperation),
                                       .Overflow(AccumulatorOverflow), .Underflow(AccumulatorUnderflow),
                                       .Inexact(AccumulatorInexact), .ExceptionVector(AccumulatorExceptionVector));

      FP16WideAccumulator WideAccumulatorUnit (.clk(clk), .reset(WideAccumulatorReset),
                                               .enable(WideAccumulatorEnable), .X(OperandA),
                                               .Sum(WideAccumulatorSum),
                                               .InvalidOperation(WideAccumulatorInvalidOperation),
                                               .Overflow(WideAccumulatorOverflow),
                                               .Underflow(WideAccumulatorUnderflow),
                                               .Inexact(WideAccumulatorInexact),
                                               .ExceptionVector(WideAccumulatorExceptionVector));

      FP16MultiplyAccumulate MACUnit (.clk(clk), .reset(MACReset), .enable(MACEnable),
                                      .OperandA(OperandA), .OperandB(OperandB), .Sum(MACSum),
                                      .InvalidOperation(MACInvalidOperation),
                                      .Overflow(MACOverflow), .Underflow(MACUnderflow),
                                      .Inexact(MACInexact), .ExceptionVector(MACExceptionVector));

      FP16Divider DividerUnit (.clk(clk), .reset(reset), .START(DividerStart),
                               .OperandA(OperandA), .OperandB(OperandB), .Result(DividerResult),
                               .BUSY(DividerBusy), .DONE(DividerDone),
                               .InvalidOperation(DividerInvalidOperation),
                               .DivideByZero(DividerDivideByZero),
                               .Overflow(DividerOverflow), .Underflow(DividerUnderflow),
                               .Inexact(DividerInexact), .ExceptionVector(DividerExceptionVector));

      FP16SquareRoot SquareRootUnit (.clk(clk), .reset(reset), .START(SquareRootStart),
                                     .Radicand(OperandA), .Result(SquareRootResult),
                                     .BUSY(SquareRootBusy), .DONE(SquareRootDone),
                                     .InvalidOperation(SquareRootInvalidOperation),
                                     .Overflow(SquareRootOverflow), .Underflow(SquareRootUnderflow),
                                     .Inexact(SquareRootInexact), .ExceptionVector(SquareRootExceptionVector));

      FP16RunningProduct RunningProductUnit (.clk(clk), .reset(reset),
                                             .Start(RunningProductStart), .Clear(RunningProductClear),
                                             .OperandIn(OperandA), .RunningProduct(RunningProductResult),
                                             .Busy(RunningProductBusy), .Done(RunningProductDone),
                                             .InvalidOperation(RunningProductInvalidOperation),
                                             .Overflow(RunningProductOverflow),
                                             .Underflow(RunningProductUnderflow),
                                             .Inexact(RunningProductInexact),
                                             .ExceptionVector(RunningProductExceptionVector));

      always@(*)begin
        Result = `FP16_POSITIVE_ZERO;
        WideResult = 32'b0;
        Busy = 1'b0;
        Done = 1'b0;
        InvalidOperation = 1'b0;
        DivideByZero = 1'b0;
        Overflow = 1'b0;
        Underflow = 1'b0;
        Inexact = 1'b0;
        ExceptionVector = `FP16_NO_EXCEPTIONS;
        Greater = 1'b0;
        Equal = 1'b0;
        Lesser = 1'b0;
        Unordered = 1'b0;

        case (Operation)
            `FP16_OP_ADD: begin
                Result = AddSubResult;
                Done = Start;
                InvalidOperation = AddSubInvalidOperation;
                Overflow = AddSubOverflow;
                Underflow = AddSubUnderflow;
                Inexact = AddSubInexact;
                ExceptionVector = AddSubExceptionVector;
            end

            `FP16_OP_SUBTRACT: begin
                Result = AddSubResult;
                Done = Start;
                InvalidOperation = AddSubInvalidOperation;
                Overflow = AddSubOverflow;
                Underflow = AddSubUnderflow;
                Inexact = AddSubInexact;
                ExceptionVector = AddSubExceptionVector;
            end

            `FP16_OP_COMPARE: begin
                Greater = ComparatorGreater;
                Equal = ComparatorEqual;
                Lesser = ComparatorLesser;
                Unordered = ComparatorUnordered;
                InvalidOperation = ComparatorInvalidOperation;
                Result[0] = ComparatorLesser;
                Result[1] = ComparatorEqual;
                Result[2] = ComparatorGreater;
                Result[3] = ComparatorUnordered;
                ExceptionVector[`FP16_EXCEPTION_INVALID_BIT] = ComparatorInvalidOperation;
                Done = Start;
            end

            `FP16_OP_MULTIPLY: begin
                Result = CombinationalMultiplierResult;
                Done = Start;
                InvalidOperation = CombinationalMultiplierInvalidOperation;
                Overflow = CombinationalMultiplierOverflow;
                Underflow = CombinationalMultiplierUnderflow;
                Inexact = CombinationalMultiplierInexact;
                ExceptionVector = CombinationalMultiplierExceptionVector;
            end

            `FP16_OP_SEQUENTIAL_MULTIPLY: begin
                Result = SequentialMultiplierResult;
                Busy = SequentialMultiplierBusy;
                Done = SequentialMultiplierDone;
                InvalidOperation = SequentialMultiplierInvalidOperation;
                Overflow = SequentialMultiplierOverflow;
                Underflow = SequentialMultiplierUnderflow;
                Inexact = SequentialMultiplierInexact;
                ExceptionVector = SequentialMultiplierExceptionVector;
            end

            `FP16_OP_ACCUMULATE: begin
                Result = AccumulatorSum;
                Done = Start;
                InvalidOperation = AccumulatorInvalidOperation;
                Overflow = AccumulatorOverflow;
                Underflow = AccumulatorUnderflow;
                Inexact = AccumulatorInexact;
                ExceptionVector = AccumulatorExceptionVector;
            end

            `FP16_OP_WIDE_ACCUMULATE: begin
                WideResult = WideAccumulatorSum;
                Done = Start;
                InvalidOperation = WideAccumulatorInvalidOperation;
                Overflow = WideAccumulatorOverflow;
                Underflow = WideAccumulatorUnderflow;
                Inexact = WideAccumulatorInexact;
                ExceptionVector = WideAccumulatorExceptionVector;
            end

            `FP16_OP_MAC: begin
                Result = MACSum;
                Done = Start;
                InvalidOperation = MACInvalidOperation;
                Overflow = MACOverflow;
                Underflow = MACUnderflow;
                Inexact = MACInexact;
                ExceptionVector = MACExceptionVector;
            end

            `FP16_OP_DIVIDE: begin
                Result = DividerResult;
                Busy = DividerBusy;
                Done = DividerDone;
                InvalidOperation = DividerInvalidOperation;
                DivideByZero = DividerDivideByZero;
                Overflow = DividerOverflow;
                Underflow = DividerUnderflow;
                Inexact = DividerInexact;
                ExceptionVector = DividerExceptionVector;
            end

            `FP16_OP_SQUARE_ROOT: begin
                Result = SquareRootResult;
                Busy = SquareRootBusy;
                Done = SquareRootDone;
                InvalidOperation = SquareRootInvalidOperation;
                Overflow = SquareRootOverflow;
                Underflow = SquareRootUnderflow;
                Inexact = SquareRootInexact;
                ExceptionVector = SquareRootExceptionVector;
            end

            `FP16_OP_RUNNING_PRODUCT: begin
                Result = RunningProductResult;
                Busy = RunningProductBusy;
                Done = RunningProductDone;
                InvalidOperation = RunningProductInvalidOperation;
                Overflow = RunningProductOverflow;
                Underflow = RunningProductUnderflow;
                Inexact = RunningProductInexact;
                ExceptionVector = RunningProductExceptionVector;
            end

            default: begin
                Result = `FP16_POSITIVE_ZERO;
                WideResult = 32'b0;
            end
        endcase
      end
endmodule
