`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2026 12:58:15 AM
// Design Name: 
// Module Name: SequentialMultiplier
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


module SequentialMultiplier
# (parameter WIDTH = 8)
( input wire clk,
  input wire reset,
  input wire START,
  input wire SignedMode,
  input wire [WIDTH - 1:0] A,
  input wire [WIDTH - 1:0] B,
  output wire [(2 * WIDTH) - 1:0] Product,
  output wire BUSY,
  output wire DONE);
  
  wire [WIDTH - 1:0] MagnitudeA;
  wire [WIDTH - 1:0] MagnitudeB;
  wire [(2 * WIDTH) - 1:0] MagnitudeProduct;
  wire load;
  wire step;
  wire EffectiveStep;
  wire CountDone;
  wire MultiplierBit;
  reg NegativeProduct;
  
  assign MagnitudeA = (SignedMode && A[WIDTH - 1])?(~A + 1'b1):A;
  assign MagnitudeB = (SignedMode && B[WIDTH - 1])?(~B + 1'b1):B;
  
  always @(posedge clk) begin
    if (reset) begin
        NegativeProduct <= 1'b0;
    end
    else 
        if (load) begin
            NegativeProduct <= SignedMode && (A[WIDTH - 1] ^ B[WIDTH - 1]);
        end
  end
  
  assign EffectiveStep = step & ~CountDone;
  
  ShiftAddMultiplier # (.WIDTH(WIDTH))
  MultiplierDatapath (.clk(clk), .reset(reset), .load(load), .step(EffectiveStep), .A(MagnitudeA), .B(MagnitudeB), .Product(MagnitudeProduct), .MultiplierBit(MultiplierBit));
  
  MultiplierLatencyCounter # (.WIDTH(WIDTH))
  LatencyCounter (.clk(clk), .reset(reset), .clear(load), .step(EffectiveStep), .CountDone(CountDone));
  
  MultiplierController
  MuliplierControl (.clk(clk), .reset(reset), .START(START), .CountDone(CountDone), .load(load), .step(step), .BUSY(BUSY), .DONE(DONE));          
  
  assign Product = (NegativeProduct)?(~MagnitudeProduct + 1'b1):MagnitudeProduct;      

endmodule