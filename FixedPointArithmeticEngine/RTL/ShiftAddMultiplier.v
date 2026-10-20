`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2026 12:16:37 AM
// Design Name: 
// Module Name: ShiftAddMultiplier
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


module ShiftAddMultiplier
# (parameter WIDTH = 8)
( input wire clk,
  input wire reset,
  input wire load,
  input wire step,
  input wire [WIDTH - 1:0] A,
  input wire [WIDTH - 1:0] B,
  output reg [(2 * WIDTH) - 1:0] Product,
  output wire MultiplierBit);
reg [(2 * WIDTH) - 1:0] MultiplicandRegister;
reg [WIDTH - 1:0] MultiplierRegister;
reg [(2 * WIDTH) - 1:0] Accumulator;

assign MultiplierBit = MultiplierRegister[0];
always@(posedge clk)begin
    if (reset)begin
        MultiplicandRegister <= {(2 * WIDTH){1'b0}};
        MultiplierRegister <= {WIDTH{1'b0}};
        Accumulator <= {(2 * WIDTH){1'b0}};
        Product <= {(2 * WIDTH){1'b0}};
    end
    else
    begin
        if (load) begin
            MultiplicandRegister <= {{WIDTH{1'b0}}, A};
            MultiplierRegister <= B;
            Accumulator <= {(2 * WIDTH){1'b0}};
            Product <= {(2 * WIDTH){1'b0}};
        end
        else
            if (step) begin
                if (MultiplierRegister[0]) begin
                    Accumulator <= Accumulator + MultiplicandRegister;
                    Product <= Accumulator + MultiplicandRegister;
                end
                else 
                begin
                    Accumulator <= Accumulator; 
                    Product <= Accumulator;
                end
        
        MultiplicandRegister <= MultiplicandRegister << 1;
        MultiplierRegister <= MultiplierRegister >> 1;
        end
      end
end    
endmodule
