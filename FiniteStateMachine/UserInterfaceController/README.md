# User Interface Controller

The **UserInterfaceController** guides a calculation on the Proteus FPGA calculator. It handles numerical mode and operation selection, controls the entry and capture of operands A and B, starts the arithmetic operation, and waits for completion.

## Architecture and significance

The controller separates operand entry from operand capture. **EntryConfirmed** indicates that the user has finished entering a number. The controller then waits for the encoder to assert **OperandValid**. Once the value is ready and there is no encoding error, the controller asserts **OperandCapture**. This separation gives the encoder time to finish and ensures that the operand register receives a validated value. **OperandSelect** directs the capture to operand A or B.

The execution path has separate start and wait states. **STATE_EXECUTE** asserts **ArithmeticStart** for one clock cycle. **STATE_WAIT** keeps the interface busy until the arithmetic subsystem signals completion. In **STATE_RESULT**, the user can start another calculation with the same mode and operation or return to mode selection.

## FSM type

**Mealy-type FSM.** Some outputs depend on the present state and live inputs. Others are Moore-style because the present state alone determines them.

| Output | Style | What drives it |
|---|---|---|
| OperandCapture | Mealy | In either capture state, it asserts when OperandValidationPending and OperandValid are high and OperandEncodingError is low. |
| ArithmeticStart | Moore | It is high during STATE_EXECUTE. |
| InterfaceDone | Moore | It remains high while the controller is in STATE_RESULT. |

## State transitions

A key in the table means KeyPressed is high and KeyCode matches that key. Conditions within a row are listed in priority order. The controller holds its state when no listed condition applies.

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_MODE_SELECT | # → STATE_OPERATION_SELECT | Keys A and B change the numerical mode while the controller stays in this menu. |
| STATE_OPERATION_SELECT | # → STATE_OPERAND_A<br>C → STATE_MODE_SELECT | Keys A and B change the operation. Pressing # clears the entry buffer before operand A entry. |
| STATE_OPERAND_A | EntryError → STATE_ERROR<br>EntryConfirmed → STATE_OPERAND_A_CAPTURE | Enable entry for A. Set OperandValidationPending on confirmation. |
| STATE_OPERAND_A_CAPTURE | OperandEncodingError → STATE_ERROR<br>OperandValidationPending and OperandValid → STATE_OPERAND_B<br>C → STATE_OPERAND_A | Capture A and clear the entry buffer on valid encoding. Pressing C clears the buffer and allows a retry. |
| STATE_OPERAND_B | EntryError → STATE_ERROR<br>EntryConfirmed → STATE_OPERAND_B_CAPTURE | Enable entry for B. Set OperandValidationPending on confirmation. |
| STATE_OPERAND_B_CAPTURE | OperandEncodingError → STATE_ERROR<br>OperandValidationPending and OperandValid → STATE_EXECUTE<br>C → STATE_OPERAND_B | Capture B on valid encoding. Pressing C clears the buffer and allows a retry. |
| STATE_EXECUTE | Next rising edge → STATE_WAIT | Assert ArithmeticStart during this state and set ExecutionStarted at the rising edge. |
| STATE_WAIT | ArithmeticDone and ExecutionStarted → STATE_RESULT | Keep InterfaceBusy high while waiting. Clear ExecutionStarted on completion. |
| STATE_RESULT | # → STATE_OPERAND_A<br>\* → STATE_MODE_SELECT | Assert InterfaceDone. Either key clears the entry and arithmetic state before moving on. |
| STATE_ERROR | # → STATE_MODE_SELECT | Assert InterfaceError. Pressing # clears the entry and arithmetic state and returns to mode selection. |

Synchronous reset or Clear takes priority from any state. On the rising edge, it returns the controller to STATE_MODE_SELECT with integer mode and addition selected.

## Example calculation

To calculate 12 + 4, select integer addition and enter 12 as operand A. After confirmation, the controller waits in **STATE_OPERAND_A_CAPTURE** until the encoder reports a valid value. It captures A and clears the entry buffer for B. After the same sequence validates and captures 4, the controller issues one ArithmeticStart pulse. It then waits for **ArithmeticDone** with ExecutionStarted set before entering STATE_RESULT.
