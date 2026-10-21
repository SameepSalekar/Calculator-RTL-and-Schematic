`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 10:51:49 PM
// Design Name: 
// Module Name: IntegerSquareRoot
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

module IntegerSquareRoot
#(parameter WIDTH = 8)
( input wire [WIDTH - 1:0] Radicand,
  output reg [((WIDTH + 1) / 2) - 1:0] Root,
  output reg [WIDTH - 1:0] Remainder);

localparam ROOT_WIDTH = (WIDTH + 1) / 2;
localparam PADDED_WIDTH = 2 * ROOT_WIDTH;
reg [PADDED_WIDTH - 1:0] PaddedRadicand;
reg [PADDED_WIDTH + 1:0] WorkingRemainder;
reg [ROOT_WIDTH - 1:0] WorkingRoot;
reg [PADDED_WIDTH + 1:0] TrialValue;

integer i;

always @(*) begin
    PaddedRadicand = {{(PADDED_WIDTH - WIDTH){1'b0}}, Radicand};
    WorkingRemainder = {(PADDED_WIDTH + 2){1'b0}};
    WorkingRoot = {ROOT_WIDTH{1'b0}};
    TrialValue = {(PADDED_WIDTH + 2){1'b0}};
    for (i = ROOT_WIDTH - 1; i >= 0; i = i - 1) begin
        WorkingRemainder = WorkingRemainder << 2;
        WorkingRemainder[1:0] = PaddedRadicand[(2 * i) +: 2];
        TrialValue = ({{(PADDED_WIDTH + 2 - ROOT_WIDTH){1'b0}}, WorkingRoot} << 2) | 1'b1;
        if (WorkingRemainder >= TrialValue) begin
            WorkingRemainder = WorkingRemainder - TrialValue;
            WorkingRoot = (WorkingRoot << 1) | 1'b1;
        end
        else 
        begin
            WorkingRoot = WorkingRoot << 1;
        end
    end
    Root = WorkingRoot;
    Remainder = WorkingRemainder[WIDTH - 1:0];
end
endmodule
