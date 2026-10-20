`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 08:17:38 PM
// Design Name: 
// Module Name: FixedPointArithmeticEngine
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

module FixedPointArithmeticEngine
#(parameter WIDTH = 8,
  parameter FRACTIONAL_BITS = 4)
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
  
  localparam ADD_OPERATION = 4'b0000;
  localparam SUBTRACT_OPERATION = 4'b0001;
  localparam COMPARE_OPERATION = 4'b0010;
  localparam MULTIPLY_OPERATION = 4'b0011;
  localparam SEQUENTIAL_MULTIPLY_OPERATION = 4'b0100;
  localparam DIVIDE_OPERATION = 4'b0101;
  localparam SQUARE_ROOT_OPERATION = 4'b0110;
  localparam ACCUMULATE_OPERATION = 4'b0111;
  localparam MAC_OPERATION = 4'b1001;
  localparam RUNNING_PRODUCT_OPERATION = 4'b1010;
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
  
  wire [(2 * WIDTH) - 1:0] RawCombinationalProduct;
  wire [(2 * WIDTH) - 1:0] ScaledCombinationalProduct;
  
  wire SequentialMultiplierStart;
  wire [(2 * WIDTH) - 1:0] RawSequentialProduct;
  wire [(2 * WIDTH) - 1:0] ScaledSequentialProduct;
  wire SequentialMultiplierBusy;
  wire SequentialMultiplierDone;
  
  wire DividerStart;
  wire [(2 * WIDTH) - 1:0] ScaledDividend;
  wire [(2 * WIDTH) - 1:0] DividerQuotient;
  wire [(2 * WIDTH) - 1:0] DividerRemainder;
  wire DividerBusy;
  wire DividerDone;
  wire DividerError;
  
  wire [(2 * WIDTH) - 1:0] SquareRootRadicand;
  wire [WIDTH - 1:0] SquareRoot;
  wire [(2 * WIDTH) - 1:0] SquareRootRemainder;
  
  wire AccumulatorEnable;
  wire [WIDTH - 1:0] AccumulatorSum;

  wire MACEnable;
  wire [WIDTH - 1:0] MACSum;
  
  wire RunningProductStart;
  wire RunningProductClear;
  wire [WIDTH - 1:0] RunningProductResult;
  wire RunningProductBusy;
  wire RunningProductDone;
  
  assign Subtractor = (Operation == SUBTRACT_OPERATION);
  
  assign ScaledCombinationalProduct = (SignedMode) ? $signed(RawCombinationalProduct) >>> FRACTIONAL_BITS : RawCombinationalProduct >> FRACTIONAL_BITS;
  
  assign ScaledSequentialProduct =  (SignedMode) ? $signed(RawSequentialProduct) >>> FRACTIONAL_BITS : RawCombinationalProduct >> FRACTIONAL_BITS;
  
  assign SequentialMultiplierStart = Start && (Operation == SEQUENTIAL_MULTIPLY_OPERATION) && ~SequentialMultiplierBusy;
  
  assign ScaledDividend = (SignedMode) ? $signed({{WIDTH{OperandA[WIDTH - 1]}}, OperandA}) <<< FRACTIONAL_BITS : {{WIDTH{1'b0}}, OperandA} << FRACTIONAL_BITS;
  
  assign DividerStart = Start && (Operation == DIVIDE_OPERATION) && ~DividerBusy;
  
  assign SquareRootRadicand = {{WIDTH{1'b0}}, OperandA} << FRACTIONAL_BITS;
  
  assign AccumulatorEnable = Start && (Operation == ACCUMULATE_OPERATION);
  
  assign MACEnable = Start && (Operation == MAC_OPERATION);
  
  assign RunningProductStart = Start && (Operation == RUNNING_PRODUCT_OPERATION) && ~RunningProductBusy;
  
  CLA_AdderSubtractor #(.WIDTH(WIDTH)) AdderSubtractor(.A(OperandA), .B(OperandB), .Subtractor(Subtractor), 
                        .result(AddSubtractResult), .zero(AddSubtractZero), .negative(AddSubtractNegative),
                        .carry(AddSubtractCarry), .overflow(AddSubtractOverflow));
  
  UnifiedComparator #(.WIDTH(WIDTH)) Comparator(.A(OperandA), .B(OperandB), .SignedMode(SignedMode), 
                      .Greater(ComparatorGreater), .Equal(ComparatorEqual), .Lesser(ComparatorLesser));
                      
  CombinationalMultiplier #(.WIDTH(WIDTH)) CombinationalMultiplyUnit (.A(OperandA), .B(OperandB), .SignedMode(SignedMode),
                            .Product(RawCombinationalProduct));
                            
  SequentialMultiplier #(.WIDTH(WIDTH)) SequentialMultilplyUnit (.clk(clk), .reset(reset), .START(SequentialMultiplierStart),
                         .SignedMode(SignedMode), .A(OperandA), .B(OperandB), .Product(RawSequentialProduct), 
                         .BUSY(SequentialMultiplierBusy), .DONE(SequentialMultiplierDone));
                         
  ParameterizedDivider #(.WIDTH(2 * WIDTH)) DividerUnit (.clk(clk), .reset(reset), .START(DividerStart), 
                         .SignedMode(SignedMode), .Dividend(ScaledDividend), 
                         .Divisor((SignedMode) ? {{WIDTH{OperandB[WIDTH - 1]}}, OperandB} : {{WIDTH{1'b0}}, OperandB}), 
                         .Quotient(DividerQuotient), .Reminder(DividerRemainder), .BUSY(DividerBusy), .DONE(DividerDone),
                         .ERROR(DividerError));
  
  IntegerSquareRoot #(.WIDTH(2 * WIDTH)) SquareRootUnit(.Radicand(SquareRootRadicand), .Root(SquareRoot), 
                                                        .Remainder(SquareRootRemainder));
                                                        
  FixedPointAccumulator #(.WIDTH(WIDTH), .FRACTIONAL_BITS(FRACTIONAL_BITS)) 
  AccumulatorUnit(.clk(clk), .reset(reset), .enable(MACEnable), .Clear(RunningProductClear), .SignedMode(SignedMode),
                  .A(OperandA), .B(OperandB), .Sum(MACSum));
                  
  FixedPointRunningProduct #(.WIDTH(WIDTH), .FRACTIONAL_BITS(FRACTIONAL_BITS))
  RunningProductUnit(.clk(clk), .reset(reset), .Start(RunningProductStart), .Clear(RunningProductClear), 
                     .SignedMode(SignedMode), .OperandIn(OperandA), .RunningProduct(RunningProductResult),
                     .Busy(RunningProductBusy), .Done(RunningProductDone));
                     
 always@(*)begin
    Result = {(2 * WIDTH){1'b0}};
    Busy = 1'b0;
    Done = 1'b0;
    Error = 1'b0;
    ZeroFlag = 1'b0;
    NegativeFlag = 1'b0;
    CarryFlag = 1'b0;
    OverflowFlag = 1'b0;
    Greater = 1'b0;
    Lesser = 1'b0;
    Equal = 1'b0;
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
            Result[WIDTH - 1:0] = ScaledCombinationalProduct[WIDTH - 1:0];
            Done = Start;
        end
        
        SEQUENTIAL_MULTIPLY_OPERATION: begin
            Result[WIDTH - 1:0] = ScaledSequentialProduct[WIDTH - 1:0];
            Busy = SequentialMultiplierBusy;
            Done = SequentialMultiplierDone;
        end
        
        DIVIDE_OPERATION: begin
            Result[WIDTH - 1:0] = DividerQuotient[WIDTH - 1:0];
            Busy = DividerBusy;
            Done = DividerDone;
            Error = DividerError;
        end
        
        SQUARE_ROOT_OPERATION: begin
            Result[WIDTH - 1:0] = SquareRoot;
            Done = Start;
        end
        
        ACCUMULATE_OPERATION: begin
            Result[WIDTH - 1:0] = AccumulatorSum;
            Done = Start;
        end
        
        MAC_OPERATION: begin
            Result[WIDTH - 1:0] = MACSum;
            Done = Start;
        end
        
        RUNNING_PRODUCT_OPERATION: begin
            Result[WIDTH - 1:0] = RunningProductResult;
            Busy = RunningProductBusy;
            Done = RunningProductDone;
        end
        
        default: begin
            Result = {(2 * WIDTH){1'b0}};
        end
    endcase
 end    
endmodule