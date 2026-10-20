`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2026 12:45:53 AM
// Design Name: 
// Module Name: MultiplierLatencyCounter
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


module MultiplierLatencyCounter
#(parameter WIDTH = 8)
( input wire clk,
  input wire reset,
  input wire clear,
  input wire step,
  output reg CountDone);
  
  localparam COUNTER_WIDTH = $clog2(WIDTH + 1);
  
  reg [COUNTER_WIDTH - 1:0] counter;
  
  always@(posedge clk)begin
    if(reset)begin
        counter <= 0;
        CountDone <= 1'b0;
    end
    else
    begin
        if (clear) begin
            counter <= 0;
            CountDone <= 1'b0;
        end
        else
            if (step && !CountDone) begin
                if (counter == WIDTH - 1)begin
                    CountDone <= 1'b1;
                end
                else
                begin
                    counter <= counter + 1'b1;
                    CountDone <= 1'b0;
                end
            end
        end   
    end                            
endmodule
