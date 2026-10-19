`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2026 05:12:02 AM
// Design Name: 
// Module Name: IntegerArithmeticEngine
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

`include "ArithmeticDefinitions.vh"

module IntegerArithmeticEngine
#(parameter WIDTH = 8)
(input wire clk,
 input wire reset,
 input wire Start,
 input wire Clear,
 input wire [`ARITHMETIC_OPERATION_WIDTH - 1:0] Operation,
 input wire SignedMode,
 input wire [WIDTH - 1:0] OperandA,
 input wire [WIDTH - 1:0] OperandB,
 output reg [(2 * WIDTH) - 1:0] Result,
 output reg Busy,
 output reg Done,
 output reg Error,
 output reg ZeroFlag,
 output reg NegativeFlag,
 output reg CarryFlag,
 output reg OverflowFlag,
 output reg Greater,
 output reg Equal,
 output reg Lesser);

 localparam ADD_OPERATION = 4'd0;
 localparam SUBTRACT_OPERATION = 4'd1;
 localparam COMPARE_OPERATION = 4'd2;
 localparam MULTIPLY_OPERATION = 4'd3;
 localparam SEQUENTIAL_MULTIPLY_OPERATION = 4'd4;
 localparam DIVIDE_OPERATION = 4'd5;
 localparam SQUARE_ROOT_OPERATION = 4'd6;
 localparam ACCUMULATE_OPERATION = 4'd7;
 localparam WIDE_ACCUMULATE_OPERATION = 4'd8;
 localparam MAC_OPERATION = 4'd9;
 localparam RUNNING_PRODUCT_OPERATION = 4'd10;

 localparam ROOT_WIDTH = (WIDTH + 1) / 2;

 wire Subtractor;
 wire [WIDTH - 1:0] AddSubtractResult;
 wire AddSubtractZero;
 wire AddSubtractNegative;
 wire AddSubtractCarry;
 wire AddSubtractOverflow;

 wire ComparatorGreater;
 wire ComparatorEqual;
 wire ComparatorLesser;

 wire [(2 * WIDTH) - 1:0] CombinationalProduct;

 wire SequentialMultiplierStart;
 wire [(2 * WIDTH) - 1:0] SequentialProduct;
 wire SequentialMultiplierBusy;
 wire SequentialMultiplierDone;

 wire DividerStart;
 wire [WIDTH - 1:0] Quotient;
 wire [WIDTH - 1:0] Remainder;
 wire DividerBusy;
 wire DividerDone;
 wire DividerError;

 wire [ROOT_WIDTH - 1:0] SquareRoot;
 wire [WIDTH - 1:0] SquareRootRemainder;

 wire AccumulatorEnable;
 wire [WIDTH - 1:0] AccumulatorSum;

 wire WideAccumulatorEnable;
 wire [(2 * WIDTH) - 1:0] WideAccumulatorSum;

 wire MACEnable;
 wire [(2 * WIDTH) - 1:0] MACSum;

 wire RunningProductStart;
 wire RunningProductClear;
 wire [(2 * WIDTH) - 1:0] RunningProductResult;
 wire RunningProductBusy;
 wire RunningProductDone;

 assign Subtractor = (Operation == SUBTRACT_OPERATION);
 
 assign SequentialMultiplierStart = Start && (Operation == SEQUENTIAL_MULTIPLY_OPERATION) && ~SequentialMultiplierBusy;
 
 assign DividerStart = Start && (Operation == DIVIDE_OPERATION) && ~DividerBusy;
 
 assign AccumulatorEnable = Start && (Operation == ACCUMULATE_OPERATION);
 
 assign WideAccumulatorEnable = Start && (Operation == WIDE_ACCUMULATE_OPERATION);
 
 assign MACEnable = Start && (Operation == MAC_OPERATION);
 
 assign RunningProductStart = Start && (Operation == RUNNING_PRODUCT_OPERATION) && ~RunningProductBusy;
 
 assign RunningProductClear = Clear && (Operation == RUNNING_PRODUCT_OPERATION);
 
 CLA_AdderSubtractor #(.WIDTH(WIDTH)) AdderSubtractor (.A(OperandA), .B(OperandB), .Subtractor(Subtractor), 
                                                       .result(AddSubtractResult), .zero(AddSubtractZero),
                                                       .negative(AddSubtractNegative), .carry(AddSubtractCarry),
                                                       .overflow(AddSubtractOverflow));

 UnifiedComparator #(.WIDTH(WIDTH)) Comparator (.A(OperandA), .B(OperandB), .SignedMode(SignedMode), .Greater(ComparatorGreater), 
                                                .Equal(ComparatorEqual), .Lesser(ComparatorLesser));

 CombinationalMultiplier #(.WIDTH(WIDTH)) CombinationalMultiplyUnit (.A(OperandA), .B(OperandB), .SignedMode(SignedMode),
                                                                     .Product(CombinationalProduct));

 SequentialMultiplier #(.WIDTH(WIDTH)) SequentialMultiplyUnit (.clk(clk), .reset(reset), .START(SequentialMultiplierStart),
                                                               .SignedMode(SignedMode), .A(OperandA), .B(OperandB),
                                                               .Product(SequentialProduct), .BUSY(SequentialMultiplierBusy),
                                                               .DONE(SequentialMultiplierDone));

 ParameterizedDivider #(.WIDTH(WIDTH)) DividerUnit (.clk(clk), .reset(reset), .START(DividerStart), .SignedMode(SignedMode), 
                                                    .Dividend(OperandA), .Divisor(OperandB), .Quotient(Quotient), 
                                                    .Reminder(Remainder), .BUSY(DividerBusy), .DONE(DividerDone), 
                                                    .ERROR(DividerError));

 IntegerSquareRoot #(.WIDTH(WIDTH)) SquareRootUnit (.Radicand(OperandA), .Root(SquareRoot), .Remainder(SquareRootRemainder));

 Accumulator #(.WIDTH(WIDTH)) AccumulatorUnit (.clk(clk), .reset(reset), .enable(AccumulatorEnable), .X(OperandA), 
                                               .Sum(AccumulatorSum));

 WideAccumulator #(.INPUT_WIDTH(WIDTH), .ACC_WIDTH(2 * WIDTH)) WideAccumulatorUnit (.clk(clk), .reset(reset), 
                                                                                    .enable(WideAccumulatorEnable),
                                                                                    .X(OperandA), .Sum(WideAccumulatorSum));

 MultiplyAccumulateUnit #(.WIDTH(WIDTH), .ACC_WIDTH(2 * WIDTH)) MACUnit (.clk(clk), .reset(reset), .enable(MACEnable),
                                                                         .SignedMode(SignedMode), .A(OperandA), .B(OperandB),
                                                                         .Sum(MACSum));

 IntegerRunningProduct #(.WIDTH(WIDTH)) RunningProductUnit (.clk(clk), .reset(reset), .Start(RunningProductStart),
                                                            .Clear(RunningProductClear), .SignedMode(SignedMode),
                                                            .OperandIn(OperandA), .RunningProduct(RunningProductResult),
                                                            .Busy(RunningProductBusy), .Done(RunningProductDone));
 
 always @(*) begin
    Result = {(2 * WIDTH){1'b0}};
    Busy = 1'b0;
    Done = 1'b0;
    Error = 1'b0;
    ZeroFlag = 1'b0;
    NegativeFlag = 1'b0;
    CarryFlag = 1'b0;
    OverflowFlag = 1'b0;
    Greater = 1'b0;
    Equal = 1'b0;
    Lesser = 1'b0;

    case (Operation)
        ADD_OPERATION: begin
            Result[WIDTH - 1:0] = AddSubtractResult;
            ZeroFlag = AddSubtractZero;
            NegativeFlag = AddSubtractNegative;
            CarryFlag = AddSubtractCarry;
            OverflowFlag = AddSubtractOverflow;
            Done = Start;
        end

        SUBTRACT_OPERATION: begin
            Result[WIDTH - 1:0] = AddSubtractResult;
            ZeroFlag = AddSubtractZero;
            NegativeFlag = AddSubtractNegative;
            CarryFlag = AddSubtractCarry;
            OverflowFlag = AddSubtractOverflow;
            Done = Start;
        end

        COMPARE_OPERATION: begin
            Greater = ComparatorGreater;
            Equal = ComparatorEqual;
            Lesser = ComparatorLesser;
            Result[0] = ComparatorLesser;
            Result[1] = ComparatorEqual;
            Result[2] = ComparatorGreater;
            Done = Start;
        end

        MULTIPLY_OPERATION: begin
            Result = CombinationalProduct;
            Done = Start;
        end

        SEQUENTIAL_MULTIPLY_OPERATION: begin
            Result = SequentialProduct;
            Busy = SequentialMultiplierBusy;
            Done = SequentialMultiplierDone;
        end

        DIVIDE_OPERATION: begin
            Result[WIDTH - 1:0] = Quotient;
            Result[(2 * WIDTH) - 1:WIDTH] = Remainder;
            Busy = DividerBusy;
            Done = DividerDone;
            Error = DividerError;
        end

        SQUARE_ROOT_OPERATION: begin
            Result[ROOT_WIDTH - 1:0] = SquareRoot;
            Result[(2 * WIDTH) - 1:WIDTH] = SquareRootRemainder;
            Done = Start;
        end

        ACCUMULATE_OPERATION: begin
            Result[WIDTH - 1:0] = AccumulatorSum;
            Done = Start;
        end

        WIDE_ACCUMULATE_OPERATION: begin
            Result = WideAccumulatorSum;
            Done = Start;
        end

        MAC_OPERATION: begin
            Result = MACSum;
            Done = Start;
        end

        RUNNING_PRODUCT_OPERATION: begin
            Result = RunningProductResult;
            Busy = RunningProductBusy;
            Done = RunningProductDone;
        end

        default: begin
            Result = {(2 * WIDTH){1'b0}};
        end
    endcase
 end
endmodule
