# Expression Evaluator

**ExpressionEvaluator** evaluates one keypad expression in the Proteus FPGA calculator. It accepts the tokens collected by UserInterfaceController, converts numeric literals into the selected integer, fixed-point, or FP16 format, and sends individual arithmetic requests to ProteusArithmeticCore. It publishes one result or error for the whole expression.

## Architecture and significance

The evaluator uses a **value stack** for encoded operands and intermediate results, and an **operator stack** for pending operators and opening parentheses. **STATE_SCAN** decides whether to read a number, push an operator, close a group, or apply a pending operator. Applying a pending operator is called a reduction. A binary reduction replaces two stack values with one result. Square root replaces one stack value with its root.

The stack rules implement **BODMAS** for the supported operators. Parentheses control grouping, then square root has the highest operator precedence. Multiplication and division share a precedence level, as do addition and subtraction. Operators at the same binary precedence level evaluate from left to right. An optional top-level **greater-than or less-than comparison** has the lowest precedence, so each side reduces to one value before the core compares them.

The evaluator reuses **SequentialOperandEntry** to convert each literal and the existing arithmetic core to execute each reduction. After requesting an operation, it waits for **CoreDone** before using the result. This lets a single state machine coordinate operations with different latencies and keeps intermediate results out of the LCD result display.

An expression can contain up to **six numeric literals** and **three pairs of parentheses**, including nested pairs. Intermediate results do not count toward the six-literal limit. The keypad buffer also limits the complete expression to 32 tokens, including digits, decimal points, operators, and parentheses.

## FSM type

**Mealy-type FSM.** **CoreStart** depends on the present state and the live CoreBusy, reset, and Clear inputs. **Busy** is Moore-style because it depends only on the present state.

| Output | Style | What drives it |
|---|---|---|
| CoreStart | Mealy | Asserts in STATE_ISSUE when the stack supplies the required operands, the core is available, and reset and Clear are low. |
| Busy | Moore | Asserts whenever the evaluator is outside STATE_IDLE. |
| Done | Registered completion | Pulses on the edge leaving STATE_COMPLETE or STATE_ERROR. ResultValid and Error indicate the outcome during the pulse. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | Start with a valid request → STATE_SCAN<br>Start with an invalid request → STATE_ERROR | Latch the expression, token count, numerical mode, and signed mode. |
| STATE_SCAN | Begin a literal → STATE_NUMBER<br>Operator reduction needed → STATE_ISSUE<br>Input exhausted with one value and no pending operators → STATE_COMPLETE<br>Syntax or limit error → STATE_ERROR | Decide what to do with the current token. Pushing an operator or consuming a matching closing parenthesis keeps the FSM in STATE_SCAN. |
| STATE_NUMBER | Digit or decimal point → STATE_NUMBER<br>Literal ends → STATE_CONVERT<br>Empty or oversized literal → STATE_ERROR | Collect the literal for conversion. |
| STATE_CONVERT | Next rising edge → STATE_WAIT_CONVERSION | Start the literal converter. |
| STATE_WAIT_CONVERSION | Valid conversion completes → STATE_SCAN<br>Conversion fails → STATE_ERROR | Push the encoded operand onto the value stack or record an encoding error. |
| STATE_ISSUE | CoreStart asserted → STATE_WAIT_CORE<br>Required stack values unavailable → STATE_ERROR | Present the operation and operands. Wait here while the core is busy. |
| STATE_WAIT_CORE | CoreDone with a usable result → STATE_SCAN<br>CoreDone with an error, overflow, or invalid result → STATE_ERROR | Replace the consumed stack values with the result and remove the applied operator. |
| STATE_COMPLETE | Next rising edge → STATE_IDLE | Publish the final value with ResultValid and Done high. |
| STATE_ERROR | Next rising edge → STATE_IDLE | Publish Error with Done high and ResultValid low. |

Synchronous **reset** or **Clear** cancels the current evaluation and returns the FSM to STATE_IDLE. STATE_WAIT_CONVERSION and STATE_WAIT_CORE hold until their respective completion signals arrive.

## Worked example

Consider **(10 + 2) × 3 > (5 + 6) × 2** in integer mode. The expression uses six numeric literals and two pairs of parentheses.

The evaluator reduces the left side to 36 and the right side to 22. It then sends a single comparison request with 36 as operand A and 22 as operand B. The core asserts its Greater flag, and the evaluator converts that flag to the final value 1. STATE_COMPLETE publishes the value and pulses Done so the LCD can display the result.
