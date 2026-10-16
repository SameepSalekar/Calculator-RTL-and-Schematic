`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 12:20:56 AM
// Design Name: 
// Module Name: ArithmeticRequestRegister
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

module ArithmeticRequestRegister
#(parameter OPERAND_WIDTH = 16)
(input wire clk,
 input wire reset,
 input wire CaptureRequest,
 input wire ClearRequest,
 input wire [OPERAND_WIDTH - 1:0] OperandAIn,
 input wire [OPERAND_WIDTH - 1:0] OperandBIn,
 input wire [`ARITHMETIC_OPERATION_WIDTH - 1:0] OperationIn,
 input wire [`NUMERICAL_MODE_WIDTH - 1:0] NumericalModeIn,
 input wire SignedModeIn,
 output reg [OPERAND_WIDTH - 1:0] OperandA,
 output reg [OPERAND_WIDTH - 1:0] OperandB,
 output reg [`ARITHMETIC_OPERATION_WIDTH - 1:0] Operation,
 output reg [`NUMERICAL_MODE_WIDTH - 1:0] NumericalMode,
 output reg SignedMode,
 output reg RequestValid);
 
 always @(posedge clk) begin
    if (reset) begin
        OperandA <= {OPERAND_WIDTH{1'b0}};
        OperandB <= {OPERAND_WIDTH{1'b0}};
        Operation <= {`ARITHMETIC_OPERATION_WIDTH{1'b0}};
        NumericalMode <= `MODE_INTEGER;
        SignedMode    <= 1'b0;
        RequestValid  <= 1'b0;
    end
    else
        if(CaptureRequest) begin
            OperandA <= OperandAIn;
            OperandB <= OperandBIn;
            Operation <= OperationIn;
            NumericalMode <= NumericalModeIn;
            SignedMode <= SignedModeIn;
            RequestValid <= 1'b1;
        end
        else
            if (ClearRequest) begin
                RequestValid <= 1'b0;
            end
    end                    
endmodule
