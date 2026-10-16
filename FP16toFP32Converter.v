`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2026 12:35:05 AM
// Design Name: 
// Module Name: FP16toFP32Converter
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

`include "FP16Definitions.vh"

module FP16toFP32Converter( input wire [`FP16_WIDTH - 1:0] FP16Value,
                            output reg [31:0] FP32Value);
                            
      wire FP16Sign;
      wire [`FP16_EXPONENT_WIDTH - 1:0] FP16StoredExponent;
      wire [`FP16_FRACTION_WIDTH - 1:0] FP16Fraction;
      
      wire [`FP16_SIGNIFICAND_WIDTH - 1:0] FP16SubnormalSignificand;
      wire [3:0] SubnormalLeadingZeros;
      wire [`FP16_SIGNIFICAND_WIDTH - 1:0] NormalizedSubnormalSignificand;
      
      reg [7:0] FP32StoredExponent;
      reg [22:0] FP32Fraction;
      
      reg signed [7:0] SubnormalUnbiasedExponent;
      reg signed [8:0] BiasedFP32Exponent;
      
      assign FP16Sign = FP16Value[`FP16_SIGN_BIT];
      assign FP16StoredExponent = FP16Value[`FP16_EXPONENT_RANGE];
      assign FP16Fraction = FP16Value[`FP16_FRACTION_RANGE];
      
      function [3:0] LeadingZeroCount11;
        input [`FP16_SIGNIFICAND_WIDTH - 1:0] Value;
        integer BitIndex;
        reg FoundOne;
        begin
            LeadingZeroCount11 = 4'd0;
            FoundOne = 1'b0;
            for ( BitIndex = `FP16_SIGNIFICAND_WIDTH - 1; BitIndex >= 0; BitIndex = BitIndex - 1) begin
                if (!FoundOne) begin
                    if (Value[BitIndex]) begin
                        FoundOne = 1'b1;
                    end
                    else 
                    begin
                        LeadingZeroCount11 = LeadingZeroCount11 + 1'b1;
                    end
                end
            end
        end
      endfunction
      
      assign FP16SubnormalSignificand = {1'b0, FP16Fraction};                  
      assign SubnormalLeadingZeros = LeadingZeroCount11(FP16SubnormalSignificand);      
      assign NormalizedSubnormalSignificand = FP16SubnormalSignificand << SubnormalLeadingZeros;
      
      always@(*) begin   
        FP32Value = 32'h00000000;
        FP32StoredExponent = 8'h00;
        FP32Fraction = 23'h000000;
        SubnormalUnbiasedExponent = 8'sd0;
        BiasedFP32Exponent = 9'sd0;
        if (FP16StoredExponent == {`FP16_EXPONENT_WIDTH{1'b0}}) begin
            if (FP16Fraction == {`FP16_FRACTION_WIDTH{1'b0}}) begin
                FP32StoredExponent = 8'h00;
                FP32Fraction = 23'h000000;
            end
            else
            begin
                SubnormalUnbiasedExponent = -8'sd14 - $signed({4'b0000, SubnormalLeadingZeros});
                BiasedFP32Exponent = SubnormalUnbiasedExponent + 9'sd127;
                FP32StoredExponent = BiasedFP32Exponent[7:0];
                FP32Fraction = {NormalizedSubnormalSignificand[9:0], 13'b0000000000000};
            end               
        end
        else 
            if (FP16StoredExponent == {`FP16_EXPONENT_WIDTH{1'b1}}) begin
                FP32StoredExponent = 8'hFF;
                if (FP16Fraction == {`FP16_FRACTION_WIDTH{1'b0}}) begin
                    FP32Fraction = 23'h000000;
                end
                else
                begin
                    FP32Fraction = {FP16Fraction, 13'b0000000000000};
                end
            end
            else 
            begin
                FP32StoredExponent = {3'b000, FP16StoredExponent} + 8'd112;
                FP32Fraction = {FP16Fraction, 13'b0000000000000};
            end
        FP32Value = {FP16Sign, FP32StoredExponent, FP32Fraction};
      end                                
endmodule
