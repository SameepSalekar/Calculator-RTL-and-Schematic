`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/11/2026 03:39:55 PM
// Design Name: 
// Module Name: UserInterfaceController
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


module UserInterfaceController(
    input wire clk,
    input wire reset,
    input wire Clear,
    input wire KeyPressed,
    input wire [3:0] KeyCode,
    input wire EntryConfirmed,
    input wire EntryError,
    input wire OperandValid,
    input wire OperandEncodingError,
    input wire ArithmeticBusy,
    input wire ArithmeticDone,
    output reg [1:0] NumericalMode,
    output reg [3:0] Operation,
    output reg EntryEnable,
    output reg EntryClear,
    output reg OperandCapture,
    output reg OperandSelect,
    output reg ArithmeticStart,
    output reg ArithmeticClear,
    output reg [3:0] DisplayState,
    output reg InterfaceBusy,
    output reg InterfaceDone,
    output reg InterfaceError
    );
    
    // User Interface State Definitions
    localparam [3:0] STATE_MODE_SELECT = 4'b0000;
    localparam [3:0] STATE_OPERATION_SELECT = 4'b0001;
    localparam [3:0] STATE_OPERAND_A = 4'b0010;
    localparam [3:0] STATE_OPERAND_A_CAPTURE = 4'b0011;
    localparam [3:0] STATE_OPERAND_B = 4'b0100;
    localparam [3:0] STATE_OPERAND_B_CAPTURE = 4'b0101;
    localparam [3:0] STATE_EXECUTE = 4'b0110;
    localparam [3:0] STATE_WAIT = 4'b0111;
    localparam [3:0] STATE_RESULT = 4'b1000;
    localparam [3:0] STATE_ERROR = 4'b1001;
    
    // Numerical Mode Definitions
    localparam [1:0] MODE_INTEGER = 2'b00;
    localparam [1:0] MODE_FIZED_POINT = 2'b01;
    localparam [1:0] MODE_FP16 = 2'b11;
    
    // Arithmetic Operation Definitions
    localparam [3:0] OP_ADD = 4'b0000;
    localparam [3:0] OP_SUBTRACT = 4'b0001;
    localparam [3:0] OP_COMPARE = 4'b0010;
    localparam [3:0] OP_MULTIPLY = 4'b0011;
    localparam [3:0] OP_DIVIDE = 4'b1000;
    
    // Keypad Defintions
    localparam [3:0] KEY_A = 4'b0011;
    localparam [3:0] KEY_B = 4'b0111;
    localparam [3:0] KEY_C = 4'b1011;
    localparam [3:0] KEY_STAR = 4'b1100;
    localparam [3:0] KEY_HASH = 4'b1110;
    
    // State and Control Registers
    reg [3:0] CurrentState;
    reg [3:0] NextState;
    reg [1:0] NextNumericalMode;
    reg [3:0] NextOperation;
    reg [2:0] OperationIndex;
    reg [2:0] NextOperationIndex;
    reg ExecutionStarted;
    reg NextExecutionStarted;
    reg EntryErrorPending;
    reg NextEntryErrorPending;
    reg OperandValidationPending;
    reg NextOperandValidationPending;
    
    // Arithmetic Operation Decoder
    function [3:0] DecodeOperation;
        input [2:0] Index;
        begin
            case (Index)
                3'b000: DecodeOperation = OP_ADD;
                3'b001: DecodeOperation = OP_SUBTRACT;
                3'b010: DecodeOperation = OP_COMPARE;
                3'b011: DecodeOperation = OP_MULTIPLY;
                3'b100: DecodeOperation = OP_DIVIDE;
                default: DecodeOperation = OP_ADD;
            endcase
        end
    endfunction
    
    // Combinational Next-State Logic
    always @(*) begin
        NextState = CurrentState;
        NextNumericalMode = NumericalMode;
        NextOperation = Operation;
        NextOperationIndex = OperationIndex;
        NextExecutionStarted = ExecutionStarted;
        NextEntryErrorPending = EntryErrorPending;
        NextOperandValidationPending = OperandValidationPending;
        
        EntryEnable = 1'b0;
        EntryClear = 1'b0;
        OperandCapture = 1'b0;
        OperandSelect = 1'b0;
        ArithmeticStart = 1'b0;
        ArithmeticClear = 1'b0;
        DisplayState = CurrentState;
        DisplayState = CurrentState;
        InterfaceBusy = 1'b0;
        InterfaceDone = 1'b0;
        InterfaceError = 1'b0;
        
        // Main User Interface State Machine
        case (CurrentState)
            // Numerical Mode Selection
            STATE_MODE_SELECT: begin
                NextExecutionStarted = 1'b0;
                NextEntryErrorPending = 1'b0;
                NextOperandValidationPending = 1'b0;
                if (KeyPressed) begin
                    case (KeyCode)
                        KEY_A: begin
                            if (NumericalMode == MODE_INTEGER) begin
                                NextNumericalMode = MODE_FP16;
                            end
                            else
                            begin
                                NextNumericalMode = NumericalMode - 1'b1;
                            end    
                        end
                        
                        KEY_B: begin
                            if (NumericalMode == MODE_FP16) begin
                                NextNumericalMode = MODE_INTEGER;
                            end
                            else
                            begin
                                NextNumericalMode = NumericalMode + 1'b1;
                            end    
                        end
                        
                        KEY_HASH: begin
                            NextState = STATE_OPERATION_SELECT;    
                        end
                        
                        default: begin
                        end
                    endcase
                end
            end
            
            // Arithmetic Operation Selection
            STATE_OPERATION_SELECT: begin
                if (KeyPressed) begin
                    case (KeyCode)
                        KEY_A: begin
                            if (OperationIndex == 3'b000)
                                NextOperationIndex = 3'b100;
                            else
                                NextOperationIndex = OperationIndex - 1'b1;          
                        end
                        
                        KEY_B: begin
                            if (OperationIndex == 3'b100)
                                NextOperationIndex = 3'b000;
                            else
                                NextOperationIndex = OperationIndex + 1'b1;
                        end
                        
                        KEY_HASH: begin
                            EntryClear = 1'b1;
                            NextEntryErrorPending = 1'b0;
                            NextOperandValidationPending = 1'b0;
                            NextState = STATE_OPERAND_A;
                        end
                        
                        KEY_C: begin
                            NextState = STATE_MODE_SELECT;
                        end
                        
                        default: begin
                        end
                        
                    endcase
                end
            end
            
            // Operand A Entry
            STATE_OPERAND_A: begin
                EntryEnable = 1'b1;
                OperandSelect = 1'b0;
                if (EntryError) begin
                    InterfaceError = 1'b1;
                    NextEntryErrorPending = 1'b1;
                    NextOperandValidationPending = 1'b0;
                    NextState = STATE_ERROR;
                end
                else
                    if (EntryConfirmed) begin
                        NextOperandValidationPending = 1'b1;
                        NextEntryErrorPending = 1'b0;
                        NextState = STATE_OPERAND_A_CAPTURE;
                    end
            end
            
            // Operand A Validation and Capture
            STATE_OPERAND_A_CAPTURE: begin
                OperandSelect = 1'b0;
                InterfaceBusy = 1'b1;
                if (OperandEncodingError) begin
                    InterfaceError = 1'b1;
                    NextEntryErrorPending = 1'b1;
                    NextOperandValidationPending = 1'b0;
                    NextState = STATE_ERROR;
                end
                else
                    if (OperandValidationPending && OperandValid) begin
                        OperandCapture = 1'b1;
                        EntryClear = 1'b1;
                        NextEntryErrorPending = 1'b0;
                        NextOperandValidationPending = 1'b0;
                        NextState = STATE_OPERAND_B;
                    end
                    else
                        if (KeyPressed && KeyCode == KEY_C) begin
                            EntryClear = 1'b1;
                            NextEntryErrorPending = 1'b0;
                            NextOperandValidationPending = 1'b0;
                            NextState = STATE_OPERAND_A;
                        end
            end
            
            // Operand B Entry
            STATE_OPERAND_B: begin
                EntryEnable = 1'b1;
                OperandSelect = 1'b1;
                if (EntryError) begin
                    InterfaceError = 1'b1;
                    NextEntryErrorPending = 1'b1;
                    NextOperandValidationPending = 1'b0;
                    NextState = STATE_ERROR;
                end
                else 
                    if (EntryConfirmed) begin
                        NextOperandValidationPending = 1'b1;
                        NextEntryErrorPending = 1'b0;
                        NextState = STATE_OPERAND_B_CAPTURE;
                    end
            end
            
            // Operand B Validation and Capture
            STATE_OPERAND_B_CAPTURE: begin
                OperandSelect = 1'b1;
                InterfaceBusy = 1'b1;
                if (OperandEncodingError) begin
                    InterfaceError = 1'b1;
                    NextEntryErrorPending = 1'b1;
                    NextOperandValidationPending = 1'b0;
                    NextState = STATE_ERROR;
                end
                else
                    if (OperandValidationPending && OperandValid) begin
                        OperandCapture = 1'b1;
                        NextEntryErrorPending = 1'b0;
                        NextOperandValidationPending = 1'b0;
                        NextState = STATE_EXECUTE;
                    end
                    else
                        if (KeyPressed && KeyCode == KEY_C) begin
                            EntryClear = 1'b1;
                            NextEntryErrorPending = 1'b0;
                            NextOperandValidationPending = 1'b0;
                            NextState = STATE_OPERAND_B;
                        end
            end
            
            // Arithmetic Execution Request
            STATE_EXECUTE: begin
                InterfaceBusy = 1'b1;
                // Generate a one-cycle Start pulse.
                // The next state waits for completion.
                ArithmeticStart = 1'b1;
                NextExecutionStarted = 1'b1;
                NextState = STATE_WAIT; 
            end
            
            // Wait for Arithmetic Completion
            STATE_WAIT: begin
                InterfaceBusy = 1'b1;
                if (ArithmeticDone && ExecutionStarted) begin
                    NextExecutionStarted = 1'b0;
                    NextState = STATE_RESULT;
                end
                else
                    if (ArithmeticBusy) begin
                        NextExecutionStarted = 1'b1;
                    end
            end
            
            // Result Display State
            STATE_RESULT: begin
                InterfaceDone = 1'b1;
                if (KeyPressed) begin
                    case (KeyCode)
                        KEY_HASH: begin
                            // Start a new calculation using the selected mode and operation.
                            EntryClear = 1'b1;
                            ArithmeticClear = 1'b1;
                            NextExecutionStarted = 1'b0;
                            NextEntryErrorPending = 1'b0;
                            NextOperandValidationPending = 1'b0;
                            NextState = STATE_OPERAND_A;
                        end
                        
                        KEY_STAR: begin
                            // Return to mode selection.
                            EntryClear = 1'b1;
                            ArithmeticClear = 1'b1;
                            NextExecutionStarted = 1'b0;
                            NextEntryErrorPending = 1'b0;
                            NextOperandValidationPending = 1'b0;
                            NextState = STATE_MODE_SELECT;
                        end
                        
                        default: begin
                        end
                        
                    endcase
                end
            end
            
            // Error State
            STATE_ERROR: begin
                InterfaceError = 1'b1;
                NextExecutionStarted = 1'b0;
                NextOperandValidationPending = 1'b0;
                // No operand is captured and no arithmetic request is generated while an error is active.
                // Press # to clear the failed entry and return to mode selection.
                if (KeyPressed && KeyCode == KEY_HASH) begin
                    EntryClear = 1'b1;
                    ArithmeticClear = 1'b1;
                    NextEntryErrorPending = 1'b0;
                    NextOperandValidationPending = 1'b0;
                    NextState = STATE_MODE_SELECT;
                end    
            end
            
            // Invalid State Recovery
            default: begin
                InterfaceError = 1'b1;
                NextExecutionStarted = 1'b0;
                NextEntryErrorPending = 1'b0;
                NextOperandValidationPending = 1'b0;
                NextState = STATE_MODE_SELECT;
            end
        endcase
        
        // Update Selected Arithmetic Operation
        NextOperation = DecodeOperation(NextOperationIndex);
    end
    
    // Sequential State and Register Updates
    always @(posedge clk) begin
        if (reset || Clear) begin
            CurrentState <= STATE_MODE_SELECT;
            NumericalMode <= MODE_INTEGER;
            Operation <= OP_ADD;
            OperationIndex <= 3'b000;
            ExecutionStarted <= 1'b0;
            EntryErrorPending <= 1'b0;
            OperandValidationPending <= 1'b0;
        end
        else
        begin
            CurrentState <= NextState;
            NumericalMode <= NextNumericalMode;
            Operation <= NextOperation;
            OperationIndex <= NextOperationIndex;
            ExecutionStarted <= NextExecutionStarted;
            EntryErrorPending <= NextEntryErrorPending;
            OperandValidationPending <= NextOperandValidationPending;
        end    
    end 
endmodule
