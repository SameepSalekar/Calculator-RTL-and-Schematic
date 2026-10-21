`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2026 04:05:00 AM
// Design Name: 
// Module Name: topModule
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

module topModule
#(parameter WIDTH = 4)
(
    input wire [WIDTH - 1:0] A,
    input wire [WIDTH - 1:0] B,
    input wire Subtractor,

    output wire [WIDTH - 1:0] result,
    output wire zero,
    output wire negative,
    output wire carry,
    output wire overflow
);

    wire [WIDTH - 1:0] B_new;
    wire [WIDTH:0] carrier;

    assign carrier[0] = Subtractor;

    assign B_new = B ^ {WIDTH{Subtractor}};

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : OPERATION_BITS
            FullAdder FullAdd
            (
                .A(A[i]),
                .B(B_new[i]),
                .c_in(carrier[i]),
                .sum(result[i]),
                .c_out(carrier[i + 1])
            );
        end
    endgenerate

    ArithmeticStatusUnit
    #(
        .WIDTH(WIDTH)
    )
    StatusUnit
    (
        .Result(result),
        .CarryOut(carrier[WIDTH]),
        .CarryIntoMSB(carrier[WIDTH - 1]),
        .Zero(zero),
        .Negative(negative),
        .Carry(carry),
        .Overflow(overflow)
    );

endmodule