# User Interface Controller

`UserInterfaceController` coordinates one calculation in the Proteus FPGA calculator. It handles numerical mode and operation selection, directs the entry and capture of operands A and B, requests arithmetic execution, and waits for the result.

## Architecture and significance

The controller uses separate sequential and combinational logic. The sequential block updates `CurrentState` and the stored control registers on the rising edge of `clk`. The combinational block computes `NextState` and the control outputs from the current state, stored flags, and live inputs.

The key design decision is to give each operand separate **entry** and **capture** states. `EntryConfirmed` means the user has finished entering an operand. The controller then waits in the capture state for the encoder to report `OperandValid`. Only then does it assert `OperandCapture`. This handshake keeps an operand register from capturing a value before the encoder has validated it. `OperandSelect` directs the capture to A or B.

Execution also has two distinct states. `STATE_EXECUTE` asserts `ArithmeticStart` for one cycle. `STATE_WAIT` keeps the interface busy while arithmetic runs, then advances to `STATE_RESULT` when `ArithmeticDone` is observed with `ExecutionStarted` set. In the result state, `#` starts another calculation with the same mode and operation, while `*` returns to mode selection.

## FSM type

**Mealy-type FSM.** Some outputs depend on the present state and live inputs. Other outputs are Moore-style because the present state alone determines them.

| Output | Style | What drives it |
|---|---|---|
| `OperandCapture` | Mealy | In either capture state, it asserts when `OperandValidationPending` and `OperandValid` are high and `OperandEncodingError` is low. |
| `ArithmeticStart` | Moore | It is high while `CurrentState` is `STATE_EXECUTE`. |
| `InterfaceDone` | Moore | It is high while `CurrentState` is `STATE_RESULT`. It stays high until the controller leaves that state. |

## State transitions

A key in the table means `KeyPressed` is high and `KeyCode` matches that key. Conditions within each row are listed in priority order. The controller holds its state when no listed condition applies.

| Present state | Condition → next state | Main action |
|---|---|---|
| `STATE_MODE_SELECT` | `#` → `STATE_OPERATION_SELECT` | A and B change the numerical mode while the controller stays in this menu. |
| `STATE_OPERATION_SELECT` | `#` → `STATE_OPERAND_A`<br>`C` → `STATE_MODE_SELECT` | A and B change the operation. `#` clears the entry buffer before operand A entry. |
| `STATE_OPERAND_A` | `EntryError` → `STATE_ERROR`<br>`EntryConfirmed` → `STATE_OPERAND_A_CAPTURE` | Enable entry for operand A. Set `OperandValidationPending` on confirmation. |
| `STATE_OPERAND_A_CAPTURE` | `OperandEncodingError` → `STATE_ERROR`<br>`OperandValidationPending && OperandValid` → `STATE_OPERAND_B`<br>`C` → `STATE_OPERAND_A` | On valid capture, store operand A and clear the entry buffer. `C` clears the entry and allows a retry. |
| `STATE_OPERAND_B` | `EntryError` → `STATE_ERROR`<br>`EntryConfirmed` → `STATE_OPERAND_B_CAPTURE` | Enable entry for operand B. Set `OperandValidationPending` on confirmation. |
| `STATE_OPERAND_B_CAPTURE` | `OperandEncodingError` → `STATE_ERROR`<br>`OperandValidationPending && OperandValid` → `STATE_EXECUTE`<br>`C` → `STATE_OPERAND_B` | On valid capture, store operand B. `C` clears the entry and allows a retry. |
| `STATE_EXECUTE` | Next rising edge → `STATE_WAIT` | Assert `ArithmeticStart` and set `ExecutionStarted` at the edge. |
| `STATE_WAIT` | `ArithmeticDone && ExecutionStarted` → `STATE_RESULT` | Keep `InterfaceBusy` high while waiting. Clear `ExecutionStarted` on completion. |
| `STATE_RESULT` | `#` → `STATE_OPERAND_A`<br>`*` → `STATE_MODE_SELECT` | Assert `InterfaceDone`. Either key clears the entry and arithmetic state before moving on. |
| `STATE_ERROR` | `#` → `STATE_MODE_SELECT` | Assert `InterfaceError`. `#` clears the entry and arithmetic state and returns to the mode menu. |

Synchronous `reset` or `Clear` takes priority at the rising edge from every state. It returns the controller to `STATE_MODE_SELECT` with integer mode and addition selected.

## Example calculation

For `12 + 4`, select integer addition and advance to operand A entry. Confirm `12` to enter `STATE_OPERAND_A_CAPTURE`. Once the encoder reports a valid value, the controller captures A and clears the entry buffer for B. The same confirmation and validation sequence captures `4`. The controller then issues one `ArithmeticStart` pulse, waits for completion, and enters `STATE_RESULT` once the arithmetic subsystem finishes.
