`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/30/2026 09:36:31 PM
// Design Name: 
// Module Name: ButtonEdgeDetector
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


module ButtonEdgeDetector(
    input wire clk,
    input wire reset,
    input wire ButtonIn,
    output reg ButtonPulse
    );

reg PreviousButtonState;
    
always @(posedge clk) begin
    if (reset) begin
        PreviousButtonState <= 1'b0;
        ButtonPulse <= 1'b0;
    end
    else begin
        ButtonPulse <= ButtonIn & ~PreviousButtonState;
        PreviousButtonState <= ButtonIn;
    end
end    

endmodule