`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2026 01:46:04 AM
// Design Name: 
// Module Name: UnsignedRestoringDivider
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


module UnsignedRestoringDivider
#(parameter WIDTH = 8)
( input wire clk,
  input wire reset,
  input wire load,
  input wire step,
  input wire [WIDTH - 1:0] Dividend,
  input wire [WIDTH - 1:0] Divisor,
  output wire [WIDTH - 1:0] Quotient,
  output wire [WIDTH - 1:0] Remainder);
  
  reg [WIDTH - 1:0] QuotientRegister;
  reg [WIDTH:0] RemainderRegister;
  reg [WIDTH - 1:0] DivisorRegister;
  reg [WIDTH:0] ShiftedRemainder;
  reg [WIDTH - 1:0] ShiftedQuotient;
  reg [WIDTH:0] TrialRemainder;
  
  always@(*)begin
    ShiftedRemainder = {RemainderRegister[WIDTH - 1:0], QuotientRegister[WIDTH - 1]};
    ShiftedQuotient = QuotientRegister << 1;
    TrialRemainder = ShiftedRemainder - {1'b0, DivisorRegister};
  end
  
  always @(posedge clk) begin
    if (reset) begin
        QuotientRegister  <= {WIDTH{1'b0}};
        RemainderRegister <= {(WIDTH + 1){1'b0}};
        DivisorRegister   <= {WIDTH{1'b0}};
    end        
    else
    begin
        if (load) begin
            QuotientRegister <= Dividend;
            RemainderRegister <= {(WIDTH + 1){1'b0}};
            DivisorRegister <= Divisor;
        end
        else
            if (step) begin
                if (ShiftedRemainder >= {1'b0, DivisorRegister}) begin
                    RemainderRegister <= TrialRemainder;
                    QuotientRegister  <= ShiftedQuotient;
                    QuotientRegister[0] <= 1'b1;
                end
                else
                begin
                    RemainderRegister <= ShiftedRemainder;
                    QuotientRegister <= ShiftedQuotient;
                end
            end            
        end
    end
    
    assign Quotient = QuotientRegister;
    assign Remainder = RemainderRegister[WIDTH - 1:0];
    
endmodule
