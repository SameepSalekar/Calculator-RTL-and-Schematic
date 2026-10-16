`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2026 02:00:54 AM
// Design Name: 
// Module Name: DividerController
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


module DividerController(
    input wire clk,
    input wire reset,
    input wire START,
    input wire CountDone,
    input wire DivideByZero,
    output reg load,
    output reg step,
    output reg BUSY,
    output reg DONE,
    output reg ERROR
    );
    
    localparam IDLE = 2'b00;
    localparam LOAD = 2'b01;
    localparam RUN = 2'b10;
    localparam DONE_STATE = 2'b11;
    
    reg [1:0] CurrentState;
    reg [1:0] NextState;
    
    always @(*) begin
        NextState = CurrentState;
        case (CurrentState)
            IDLE: begin
                if (START) begin
                    if (DivideByZero)
                        NextState = DONE_STATE;
                    else
                        NextState = LOAD;
                end 
            end
            LOAD: begin
                NextState = RUN;
            end
            RUN: begin
                if (CountDone)
                    NextState = DONE_STATE;
            end
            DONE_STATE: begin
                NextState = IDLE;
            end
            default: begin
                NextState = IDLE;
            end
        endcase
    end                                            

    always @(posedge clk) begin
        if (reset)
            CurrentState <= IDLE;
        else
            CurrentState <= NextState;
    end
    
    always@(*)begin
        load = 1'b0;
        step = 1'b0;
        BUSY = 1'b0;
        DONE = 1'b0;
        ERROR = 1'b0;
        
        case (CurrentState)
            IDLE: begin
                BUSY = 1'b0;
                if(START && DivideByZero)
                    ERROR = 1'b1;
            end
            LOAD: begin
                load = 1'b1;
                BUSY = 1'b1;
            end    
            RUN: begin
                step = 1'b1;
                BUSY = 1'b1;
            end
            DONE_STATE: begin
                DONE = 1'b1;
                BUSY = 1'b0;
            end        
        endcase
    end
          
endmodule
