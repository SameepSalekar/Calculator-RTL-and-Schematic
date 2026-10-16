`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2026 01:22:28 AM
// Design Name: 
// Module Name: WideAccumulator
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


module WideAccumulator
# (parameter INPUT_WIDTH = 8,
   parameter ACC_WIDTH = 16)
   
( input wire clk,
  input wire reset,
  input wire enable,
  input wire [INPUT_WIDTH - 1:0] X,
  output reg [ACC_WIDTH - 1:0] Sum);
  
  wire [ACC_WIDTH - 1:0] ExtendedX;
  
  assign ExtendedX = {{(ACC_WIDTH - INPUT_WIDTH){1'b0}}, X};
  
  always @(posedge clk) begin
    if (reset) begin
        Sum <= {ACC_WIDTH{1'b0}};
    end    
    else
    begin
        if (enable) begin
            Sum <= Sum + ExtendedX;
        end
    end
  end          
endmodule