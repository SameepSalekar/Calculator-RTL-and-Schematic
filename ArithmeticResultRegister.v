`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2026 08:36:10 PM
// Design Name: 
// Module Name: ArithmeticResultRegister
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

module ArithmeticResultRegister
#(parameter RESULT_WIDTH = 32)
( input wire clk,
  input wire reset,
  input wire CaptureResult,
  input wire ClearResult,
  input wire [RESULT_WIDTH - 1:0] ResultIn,
  output reg [RESULT_WIDTH - 1:0] Result,
  output reg ResultValid);
  
       always@(posedge clk)begin
       if (reset) begin
        Result <= {RESULT_WIDTH{1'b0}};
        ResultValid <= 1'b0;
       end
       else
        if (CaptureResult) begin
            Result <= ResultIn;
            ResultValid <= 1'b1;
        end
        else
            if (ClearResult)begin
                Result <= {RESULT_WIDTH{1'b0}};
                ResultValid <= 1'b0;
            end
       end
endmodule
