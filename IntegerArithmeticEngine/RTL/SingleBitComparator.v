`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:16:39 PM
// Design Name: 
// Module Name: SingleBitComparator
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

module SingleBitComparator(
    input A,
    input B,
    output IsGreater,
    output IsLesser,
    output IsEqual
    );
    
    assign IsGreater = A & ~B;
    assign IsLesser = ~A & B;
    assign IsEqual = ~(A ^ B);    
    
endmodule