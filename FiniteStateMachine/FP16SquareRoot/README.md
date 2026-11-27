# FP16 Square Root

**FP16SquareRoot** computes the square root of one half-precision operand. In the expression-capable Proteus calculator, ExpressionEvaluator reduces the operand first if it is a grouped expression, then sends a square-root request through the arithmetic core.

## Architecture and significance

When **START** is high in STATE_IDLE, the controller checks **InputSpecialCaseDetected**. If the special-case resolver supplies a result, the controller registers that result and its invalid-operation status directly from STATE_IDLE. For a regular operand, it loads the integer radicand, clears the working root and remainder, and stores the result exponent.

**STATE_SQUARE_ROOT** builds the root iteratively. Each cycle updates the radicand, partial root, and remainder. The controller commits the final iteration before entering **STATE_NORM**, so the clocked normalizer receives the completed root. Reusing the same datapath across iterations spreads the square-root computation across clock cycles.

**STATE_WAIT_NORM** holds until **NormDone** asserts. The remaining states store the rounded fields, then publish the packed FP16 result and its exception flags together.

## FSM type

**Mealy-type FSM.** The special-case path has registered Mealy behavior. In STATE_IDLE, START and the operand-dependent InputSpecialCaseDetected signal determine whether **DONE** asserts on the next rising edge. The normalizer start is Moore-style because it depends only on the current state.

| Control | What drives it |
|---|---|
| DONE | Registers high when STATE_IDLE accepts a special case or STATE_FINALIZE publishes a regular result. |
| BUSY | Registers high when a regular square root starts and stays high until finalization. |
| Normalizer start | Asserts during STATE_NORM. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | START with a special case → STATE_IDLE<br>START with a regular operand → STATE_SQUARE_ROOT | Publish the special-case result and pulse DONE, or initialize the working registers and assert BUSY. |
| STATE_SQUARE_ROOT | More iterations → STATE_SQUARE_ROOT<br>Final iteration → STATE_NORM | Update the radicand, root, and remainder. Commit the final root step before normalization. |
| STATE_NORM | Next rising edge → STATE_WAIT_NORM | Start normalization using the completed root. |
| STATE_WAIT_NORM | NormDone high → STATE_ROUND | Wait for the normalized significand and exponent. |
| STATE_ROUND | Next rising edge → STATE_FINALIZE | Register the rounded fields and rounding flags. |
| STATE_FINALIZE | Next rising edge → STATE_IDLE | Publish the packed result and flags, deassert BUSY, and pulse DONE. |

Synchronous **reset** takes priority from any state and returns the controller to STATE_IDLE. STATE_IDLE holds while START is low, and STATE_WAIT_NORM holds while NormDone is low.

## Worked example

For √(9 + 16) in FP16 mode, ExpressionEvaluator first evaluates 9 + 16 and submits 25.0 as the square-root operand. FP16SquareRoot takes the regular path, initializes the radicand and working registers, and builds the root across successive clock cycles.

After normalization and rounding, STATE_FINALIZE publishes **5.0**, encoded as 0x4500 in FP16. The result is exact, so Inexact stays low. The parent engine can sample the result and flags during the DONE pulse.
