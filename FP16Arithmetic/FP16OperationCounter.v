`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2026 05:24:28 AM
// Design Name: 
// Module Name: FP16OperationCounter
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

module FP16OperationCounter
#(parameter ITERATIONS = `FP16_SIGNIFICAND_WIDTH,
  parameter COUNT_WIDTH = (ITERATIONS <= 1)?1:$clog2(ITERATIONS + 1))
( input wire clk,
  input wire reset,
  input wire clear,
  input wire step,
  output reg [COUNT_WIDTH - 1:0] Count,
  output reg CountDone,
  output wire LastIteration );
  
  localparam [COUNT_WIDTH - 1:0] LAST_COUNT = ITERATIONS - 1;
  
  assign LastIteration = step && !CountDone && (Count == LAST_COUNT);
  
  always@(posedge clk) begin
    if(reset) begin
        Count <= {COUNT_WIDTH{1'b0}};
        CountDone <= 1'b0;
    end
    else if (clear) begin
        Count <= {COUNT_WIDTH{1'b0}};
        CountDone <= 1'b0;
    end
    else if (step && !CountDone) begin
        if (Count == LAST_COUNT) begin
            Count <= Count;
            CountDone <= 1'b1;
        end
        else begin
            Count <= Count + 1'b1;
            CountDone <= 1'b0;
        end
    end
  end                  
endmodule
