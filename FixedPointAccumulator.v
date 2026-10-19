`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 07:35:43 PM
// Design Name: 
// Module Name: FixedPointAccumulator
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


module FixedPointAccumulator
#(parameter WIDTH = 8)
(input wire clk,
 input wire reset,
 input wire enable,
 input wire Clear,
 input wire [WIDTH - 1:0] X,
 output reg [WIDTH - 1:0] Sum);
 
 always@(posedge clk) begin
    if(reset)begin
        Sum <= {WIDTH{1'b0}};
    end
    else
        if (Clear) begin
            Sum <= {WIDTH{1'b0}};
        end
        else
            if (enable) begin
                Sum <= Sum + X;
            end
 end
endmodule
