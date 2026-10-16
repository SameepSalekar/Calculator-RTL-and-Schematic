`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 09:24:50 PM
// Design Name: 
// Module Name: Debouncer
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


module Debouncer
#(parameter CLOCK_FREQUENCY = 100000000,
  parameter DEBOUNCE_TIME_MS = 20)   
(input wire clk,
 input wire reset,
 input wire ButtonIn,
 output reg ButtonOut);

localparam DEBOUNCE_CYCLES = (CLOCK_FREQUENCY / 1000) * DEBOUNCE_TIME_MS;

localparam COUNTER_WIDTH = $clog2(DEBOUNCE_CYCLES);

reg Synchronizer1;
reg Synchronizer2;

reg [COUNTER_WIDTH - 1:0] counter;


always @(posedge clk) begin
    if (reset) begin
        Synchronizer1 <= 1'b0;
        Synchronizer2 <= 1'b0;
    end
    else 
    begin
        Synchronizer1 <= ButtonIn;
        Synchronizer2 <= Synchronizer1;
    end
end

always @(posedge clk) begin
    if (reset) begin
        counter <= 0;
        ButtonOut <= 1'b0;
    end
    else 
    begin
        if (Synchronizer2 == ButtonOut) begin
            counter <= 0;
        end
        else 
        begin
            if (counter == DEBOUNCE_CYCLES - 1) begin
                ButtonOut <= Synchronizer2;
                counter <= 0;
            end
            else 
            begin
                counter <= counter + 1'b1;
            end
        end
    end
end                   
endmodule

