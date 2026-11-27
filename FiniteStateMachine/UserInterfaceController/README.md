# User Interface Controller

The **UserInterfaceController** manages the keypad workflow for the Proteus FPGA calculator. It lets the user select a numerical mode, enter and edit an expression, submit it for evaluation, and start a new expression after a result or error.

## Architecture and significance

The controller stores the expression in **ExpressionTokens** and tracks its length with **TokenCount**. Each digit or symbol occupies one token, and the buffer holds up to 32 tokens. The physical keypad has 16 keys, so the controller uses **SymbolPending** to indicate that the next digit key selects a symbol. This makes parentheses, arithmetic operators, and comparison symbols available through the existing keypad.

The controller separates expression entry from evaluation. In **STATE_START**, it waits until the evaluator can accept the expression, then asserts **EvaluateStart**. Once the request is accepted, **STATE_WAIT** holds the expression and numerical mode stable until **EvaluatorDone** arrives. The evaluator handles syntax, BODMAS, and the limits of six numeric operands and three parenthesis pairs.

**ExpressionEntryActive** tells ProteusSystemIntegration when to send live edits to the LCD. The LCD shows up to 20 characters at once and follows the newest tokens as the expression grows. Pressing C removes the last token or cancels a pending symbol prefix. Pressing # submits the expression and leaves it visible while evaluation runs.

## FSM type

**Mealy-type FSM.** EvaluateStart depends on the present state and the live evaluator busy and clear signals. Several interface outputs are Moore-style because they depend only on CurrentState.

| Output | Style | What drives it |
|---|---|---|
| EvaluateStart | Mealy | Asserts in STATE_START when EvaluatorBusy and EvaluateClear are both low. |
| ExpressionEntryActive | Moore | Asserts while the controller is in STATE_EXPRESSION_ENTRY. |
| InterfaceBusy | Moore | Asserts in STATE_START and STATE_WAIT. |
| InterfaceDone | Moore | Remains high while the controller is in STATE_RESULT. |

## State transitions

A key label represents a KeyPressed event with the corresponding KeyCode. The controller holds its current state when no transition applies.

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_MODE_SELECT | HASH → STATE_EXPRESSION_ENTRY | A and B cycle through integer, fixed-point, and FP16 modes. HASH confirms the selection. |
| STATE_EXPRESSION_ENTRY | HASH with a nonempty buffer, no pending symbol prefix, and no entry error → STATE_START | Digit keys enter numbers or symbols. D toggles symbol selection. C cancels symbol selection or deletes the last token. |
| STATE_START | EvaluateStart → STATE_WAIT | Submit the expression once the evaluator is available. |
| STATE_WAIT | EvaluatorDone with EvaluatorError low → STATE_RESULT<br>EvaluatorDone with EvaluatorError high → STATE_ERROR | Wait for the evaluator to finish the whole expression. |
| STATE_RESULT | HASH → STATE_EXPRESSION_ENTRY | Clear the token buffer and start a new expression in the same numerical mode. |
| STATE_ERROR | HASH → STATE_EXPRESSION_ENTRY | Clear the token buffer and allow a fresh entry in the same numerical mode. |

Synchronous reset or Clear returns the controller to STATE_MODE_SELECT and selects integer mode. Pressing STAR outside the mode menu also clears the expression and returns to mode selection. It preserves the selected numerical mode and asserts EvaluateClear to cancel any evaluation in progress.

## Worked example

To enter (10 + 2) × 3, select integer mode with HASH. Use D followed by 5 for the opening parenthesis, D followed by 1 for addition, D followed by 6 for the closing parenthesis, and D followed by 3 for multiplication. The LCD shows (10+2)*3 as the tokens are entered.

Press HASH to submit the expression. The controller waits while the evaluator adds 10 and 2, then multiplies the sum by 3. When EvaluatorDone arrives without an error, the controller enters STATE_RESULT. The final value is 36 in decimal, displayed as 00000024 on the LCD in hexadecimal with the default 32-bit result width.
