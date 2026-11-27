# Arithmetic Execution Controller

**ArithmeticExecutionController** coordinates one arithmetic request inside the Proteus arithmetic core. It starts the selected engine, waits for completion when needed, and tells the result and status registers when to capture their inputs.

In the expression-capable calculator, ExpressionEvaluator submits one operation at a time. This controller handles each operation separately. For example, evaluating (10 + 2) × 3 uses one request for the addition and another for the multiplication.

## Architecture and significance

The controller separates launching an operation from waiting for it. **STATE_START** asserts **EngineStart** while Clear is low. If the selected engine asserts **EngineDone** during that state, the controller can capture the result on the same rising edge that returns it to idle. Otherwise, it advances to **STATE_WAIT**, where it waits for EngineDone with EngineStart deasserted.

Both completion paths use the same **ExecutionComplete** signal to assert **CaptureResult** and **CaptureStatus** together. That lets the result and its status flags register on the same edge. The controller also clears the consumed request and registers **Done**, so the caller can read the captured outputs during the completion cycle.

## FSM type

**Mealy-type FSM.** The capture outputs depend on both the current state and the live EngineDone and Clear inputs. Busy is a Moore-style output.

| Output | Style | What drives it |
|---|---|---|
| EngineStart | Mealy | Asserts in STATE_START while Clear is low. |
| CaptureResult and CaptureStatus | Mealy | Assert in STATE_START or STATE_WAIT when EngineDone is high and Clear is low. |
| Busy | Moore | Asserts whenever the controller is outside STATE_IDLE. |
| Done | Registered completion | Latches ExecutionComplete on the rising edge. Reset or Clear takes priority. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | Start and RequestValid → STATE_START | Begin execution of the queued request. |
| STATE_START | EngineDone high → STATE_IDLE<br>EngineDone low → STATE_WAIT | Assert EngineStart while Clear is low. Capture the result and status if the engine completes in this state. |
| STATE_WAIT | EngineDone high → STATE_IDLE | Keep Busy high while waiting. Capture the result and status when the engine completes and Clear is low. |

The controller holds its state when no transition applies. Although the interface includes EngineBusy, the RTL uses EngineDone to decide when execution has finished. Synchronous reset or Clear returns the FSM to STATE_IDLE and clears Done. Clear also drives EngineClear, ClearResult, ClearStatus, and ClearRequest.

## Worked example

Consider a division request that takes several cycles. Once Start and RequestValid are high, the controller enters STATE_START and asserts EngineStart. If the engine has yet to finish, the controller advances to STATE_WAIT. Busy stays high while the divider runs.

When EngineDone goes high, CaptureResult and CaptureStatus assert together. At the next rising edge, the result and status registers capture their inputs, the FSM returns to STATE_IDLE, and Done goes high for one cycle. ExpressionEvaluator can then use the captured result in the next arithmetic step.
