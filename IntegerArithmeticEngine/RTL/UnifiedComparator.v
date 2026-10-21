`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:18:13 PM
// Design Name: 
// Module Name: UnifiedComparator
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

module UnifiedComparator
# (parameter WIDTH = 8)
(input wire [WIDTH - 1:0] A,
 input wire [WIDTH - 1:0] B,
 input wire SignedMode,
 output wire Greater,
 output wire Equal,
 output wire Lesser);
 
wire [WIDTH - 1:0] great;
wire [WIDTH - 1:0] less;
wire [WIDTH - 1:0] equal;

wire SignDifference;
wire SignedGreater;
wire SignedLesser;

reg unsignedGreater;
reg unsignedLesser;
reg equalSoFar;

integer j;
genvar i;

generate
for (i = 0; i < WIDTH; i = i + 1) begin: Comparator_Block
    SingleBitComparator Singlebittercompare(.A(A[i]), .B(B[i]), .IsGreater(great[i]), .IsLesser(less[i]), .IsEqual(equal[i]));
end
endgenerate

assign Equal = &(equal);

always@(*) begin
    unsignedGreater = 1'b0;
    unsignedLesser = 1'b0;
    equalSoFar = 1'b1;

    for (j = WIDTH - 1; j >= 0; j = j - 1) begin
        if (equalSoFar && great[j])
            unsignedGreater = 1'b1;
        if (equalSoFar && less[j])
            unsignedLesser = 1'b1;
        equalSoFar = equalSoFar && equal[j];
    end
end

assign SignDifference = A[WIDTH - 1] ^ B[WIDTH - 1];
assign SignedGreater = (SignDifference)?B[WIDTH - 1]:unsignedGreater;
assign SignedLesser = (SignDifference)?A[WIDTH - 1]:unsignedLesser;
assign Greater = (SignedMode)?SignedGreater:unsignedGreater;
assign Lesser = (SignedMode)?SignedLesser:unsignedLesser;

endmodule 