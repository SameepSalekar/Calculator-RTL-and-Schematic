`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 11:08:22 PM
// Design Name: 
// Module Name: ParameterizedDivider
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

module ParameterizedDivider
#(parameter WIDTH = 8)
( input wire clk,
  input wire reset,
  input wire START,
  input wire SignedMode,
  input wire [WIDTH - 1:0] Dividend,
  input wire [WIDTH - 1:0] Divisor,
  output wire [WIDTH - 1:0] Quotient,
  output wire [WIDTH - 1:0] Reminder,
  output wire BUSY,
  output wire DONE,
  output wire ERROR);
  
  localparam COUNTER_WIDTH = $clog2(WIDTH + 1);
  
  wire DivideByZero;
  wire [WIDTH - 1:0] MagnitudeDividend;
  wire [WIDTH - 1:0] MagnitudeDivisor;
  wire [WIDTH - 1:0] MagnitudeQuotient;
  wire [WIDTH - 1:0] MagnitudeRemainder;
  wire load;
  wire step;
  wire EffectiveStep;
  reg CountDone;
  wire ControllerError;
  reg [COUNTER_WIDTH - 1:0] counter;
  reg NegativeQuotient;
  reg NegativeRemainder;
  reg ErrorLatched;
  
  assign MagnitudeDividend = (SignedMode && Dividend[WIDTH - 1])?(~Dividend + 1'b1):Dividend;
  assign MagnitudeDivisor = (SignedMode && Divisor[WIDTH - 1])?(~Divisor + 1'b1):Divisor;
  
  DivideByZeroDetector #(.WIDTH(WIDTH))
  ZeroDetector(.Divisor(Divisor), .DivideByZero(DivideByZero));
  
  DividerController DividerControl(.clk(clk), .reset(reset), .START(START), .CountDone(CountDone), .DivideByZero(DivideByZero), .load(load), .step(step), .BUSY(BUSY), .DONE(DONE), .ERROR(ControllerError));
  
  assign EffectiveStep = step & ~CountDone;
  
  UnsignedRestoringDivider #(.WIDTH(WIDTH)) 
  DividerDatapath (.clk(clk), .reset(reset), .load(load), .step(EffectiveStep), .Dividend(MagnitudeDividend), .Divisor(MagnitudeDivisor), .Quotient(MagnitudeQuotient), .Remainder(MagnitudeRemainder));
  
  always @(posedge clk) begin
    if (reset) begin
        counter <= 0;
        CountDone <= 1'b0;
    end
    else
    begin
        if (load) begin
            counter <= 0;
            CountDone <= 1'b0;
        end
        else
            if (EffectiveStep) begin
                if (counter == WIDTH - 1) begin
                    CountDone <= 1'b1;
                end
                else
                begin
                    counter <= counter  + 1'b1;
                    CountDone <= 1'b0;
                end
            end
            else
            begin
                CountDone <= 1'b0;
            end
        end
    end
    
    always@(posedge clk)begin
        if (reset)begin
            NegativeQuotient <= 1'b0;
            NegativeRemainder <= 1'b0;
        end
        else
            if (load) begin
                NegativeQuotient <= SignedMode && (Dividend[WIDTH - 1] ^ Divisor[WIDTH - 1]);
                NegativeRemainder <= SignedMode && Dividend[WIDTH - 1];
            end
        end
        
        always @(posedge clk) begin
            if (reset) begin
                ErrorLatched <= 1'b0;
            end
            else
                if (START) begin
                    ErrorLatched <= DivideByZero;
                end
            end
        
     assign Quotient = (ErrorLatched)?{WIDTH{1'b0}}:
                       (NegativeQuotient)?(~MagnitudeQuotient + 1'b1):
                        MagnitudeQuotient;
                        
     assign Remainder = (ErrorLatched)?{WIDTH{1'b0}}:
                        (NegativeRemainder)?(~MagnitudeRemainder + 1'b1):
                         MagnitudeRemainder;       
                         
     assign ERROR = ErrorLatched;
                                                                                         
endmodule
