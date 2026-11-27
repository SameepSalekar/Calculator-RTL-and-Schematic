`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2026 06:46:27 PM
// Design Name: 
// Module Name: I2CController
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


module I2CController
#(parameter CLOCK_FREQUENCY = 100000000,
  parameter I2C_FREQUENCY = 100000)
( input wire clk,
  input wire reset,
  input wire Start,
  input wire [6:0] SlaveAddress,
  input wire [7:0] DataIn,
  output reg Busy,
  output reg Done,
  output reg AcknowledgeError,
  output wire SCL,
  inout wire SDA);

      localparam integer CLOCK_DIVIDER = CLOCK_FREQUENCY / (I2C_FREQUENCY * 4);
      localparam integer COUNTER_WIDTH = (CLOCK_DIVIDER > 1) ? $clog2(CLOCK_DIVIDER) : 1;

      localparam STATE_IDLE = 4'b0000;
      localparam STATE_START = 4'b0001;
      localparam STATE_SEND_ADDRESS = 4'b0010;
      localparam STATE_ADDRESS_ACK = 4'b0011;
      localparam STATE_SEND_DATA = 4'b0100;
      localparam STATE_DATA_ACK = 4'b0101;
      localparam STATE_STOP = 4'b0110;
      localparam STATE_COMPLETE = 4'b0111;

      reg [3:0] CurrentState;

      reg [COUNTER_WIDTH - 1:0] ClockCounter;
      reg [1:0] PhaseCounter;

      reg [7:0] ShiftRegister;
      reg [7:0] DataRegister;
      reg [2:0] BitCounter;

      reg SCLRelease;
      reg SDARelease;

      reg AddressAcknowledged;
      reg DataAcknowledged;

      wire ClockEnable;

      assign SCL = SCLRelease ? 1'bz : 1'b0;
      assign SDA = SDARelease ? 1'bz : 1'b0;

      assign ClockEnable = (ClockCounter == CLOCK_DIVIDER - 1);

      always @(posedge clk) begin
        if (reset)
            ClockCounter <= {COUNTER_WIDTH{1'b0}};
        else
            if (CurrentState == STATE_IDLE || CurrentState == STATE_COMPLETE)
                ClockCounter <= {COUNTER_WIDTH{1'b0}};
            else
                if (ClockEnable)
                    ClockCounter <= {COUNTER_WIDTH{1'b0}};
                else
                    ClockCounter <= ClockCounter + 1'b1;
      end

      always @(posedge clk) begin
        if (reset) begin
            CurrentState <= STATE_IDLE;
            PhaseCounter <= 2'b00;
            ShiftRegister <= 8'b00000000;
            DataRegister <= 8'b00000000;
            BitCounter <= 3'b000;
            SCLRelease <= 1'b1;
            SDARelease <= 1'b1;
            AddressAcknowledged <= 1'b0;
            DataAcknowledged <= 1'b0;
            Busy <= 1'b0;
            Done <= 1'b0;
            AcknowledgeError <= 1'b0;
        end
        else
        begin
            Done <= 1'b0;

            case (CurrentState)
                STATE_IDLE: begin
                    SCLRelease <= 1'b1;
                    SDARelease <= 1'b1;
                    Busy <= 1'b0;
                    PhaseCounter <= 2'b00;
                    if (Start) begin
                        ShiftRegister <= {SlaveAddress, 1'b0};
                        DataRegister <= DataIn;
                        BitCounter <= 3'b111;
                        AddressAcknowledged <= 1'b0;
                        DataAcknowledged <= 1'b0;
                        AcknowledgeError <= 1'b0;
                        Busy <= 1'b1;
                        CurrentState <= STATE_START;
                    end
                end

                STATE_START: begin
                    if (ClockEnable) begin
                        case (PhaseCounter)
                            2'b00: begin
                                SCLRelease <= 1'b1;
                                SDARelease <= 1'b1;
                                PhaseCounter <= 2'b01;
                            end

                            2'b01: begin
                                SDARelease <= 1'b0;
                                PhaseCounter <= 2'b10;
                            end

                            2'b10: begin
                                SCLRelease <= 1'b0;
                                PhaseCounter <= 2'b11;
                            end

                            2'b11: begin
                                BitCounter <= 3'b111;
                                PhaseCounter <= 2'b00;
                                CurrentState <= STATE_SEND_ADDRESS;
                            end
                        endcase
                    end
                end

                STATE_SEND_ADDRESS: begin
                    if (ClockEnable) begin
                        case (PhaseCounter)
                            2'b00: begin
                                SCLRelease <= 1'b0;
                                SDARelease <= ShiftRegister[BitCounter];
                                PhaseCounter <= 2'b01;
                            end

                            2'b01: begin
                                SCLRelease <= 1'b1;
                                PhaseCounter <= 2'b10;
                            end

                            2'b10:
                                PhaseCounter <= 2'b11;

                            2'b11: begin
                                SCLRelease <= 1'b0;
                                PhaseCounter <= 2'b00;
                                if (BitCounter == 3'b000)
                                    CurrentState <= STATE_ADDRESS_ACK;
                                else
                                    BitCounter <= BitCounter - 1'b1;
                            end
                        endcase
                    end
                end

                STATE_ADDRESS_ACK: begin
                    if (ClockEnable) begin
                        case (PhaseCounter)
                            2'b00: begin
                                SCLRelease <= 1'b0;
                                SDARelease <= 1'b1;
                                PhaseCounter <= 2'b01;
                            end

                            2'b01: begin
                                SCLRelease <= 1'b1;
                                PhaseCounter <= 2'b10;
                            end

                            2'b10: begin
                                AddressAcknowledged <= ~SDA;
                                PhaseCounter <= 2'b11;
                            end

                            2'b11: begin
                                SCLRelease <= 1'b0;
                                PhaseCounter <= 2'b00;
                                if (AddressAcknowledged) begin
                                    ShiftRegister <= DataRegister;
                                    BitCounter <= 3'b111;
                                    CurrentState <= STATE_SEND_DATA;
                                end
                                else
                                begin
                                    AcknowledgeError <= 1'b1;
                                    CurrentState <= STATE_STOP;
                                end
                            end
                        endcase
                    end
                end

                STATE_SEND_DATA: begin
                    if (ClockEnable) begin
                        case (PhaseCounter)
                            2'b00: begin
                                SCLRelease <= 1'b0;
                                SDARelease <= ShiftRegister[BitCounter];
                                PhaseCounter <= 2'b01;
                            end

                            2'b01: begin
                                SCLRelease <= 1'b1;
                                PhaseCounter <= 2'b10;
                            end

                            2'b10:
                                PhaseCounter <= 2'b11;

                            2'b11: begin
                                SCLRelease <= 1'b0;
                                PhaseCounter <= 2'b00;
                                if (BitCounter == 3'b000)
                                    CurrentState <= STATE_DATA_ACK;
                                else
                                    BitCounter <= BitCounter - 1'b1;
                            end
                        endcase
                    end
                end

                STATE_DATA_ACK: begin
                    if (ClockEnable) begin
                        case (PhaseCounter)
                            2'b00: begin
                                SCLRelease <= 1'b0;
                                SDARelease <= 1'b1;
                                PhaseCounter <= 2'b01;
                            end

                            2'b01: begin
                                SCLRelease <= 1'b1;
                                PhaseCounter <= 2'b10;
                            end

                            2'b10: begin
                                DataAcknowledged <= ~SDA;
                                PhaseCounter <= 2'b11;
                            end

                            2'b11: begin
                                SCLRelease <= 1'b0;
                                PhaseCounter <= 2'b00;
                                if (!DataAcknowledged)
                                    AcknowledgeError <= 1'b1;
                                CurrentState <= STATE_STOP;
                            end
                        endcase
                    end
                end

                STATE_STOP: begin
                    if (ClockEnable) begin
                        case (PhaseCounter)
                            2'b00: begin
                                SCLRelease <= 1'b0;
                                SDARelease <= 1'b0;
                                PhaseCounter <= 2'b01;
                            end

                            2'b01: begin
                                SCLRelease <= 1'b1;
                                PhaseCounter <= 2'b10;
                            end

                            2'b10: begin
                                SDARelease <= 1'b1;
                                PhaseCounter <= 2'b11;
                            end

                            2'b11: begin
                                PhaseCounter <= 2'b00;
                                CurrentState <= STATE_COMPLETE;
                            end
                        endcase
                    end
                end

                STATE_COMPLETE: begin
                    SCLRelease <= 1'b1;
                    SDARelease <= 1'b1;
                    Busy <= 1'b0;
                    Done <= 1'b1;
                    CurrentState <= STATE_IDLE;
                end

                default: begin
                    CurrentState <= STATE_IDLE;
                    SCLRelease <= 1'b1;
                    SDARelease <= 1'b1;
                    Busy <= 1'b0;
                    PhaseCounter <= 2'b00;
                end
            endcase
        end
      end
endmodule