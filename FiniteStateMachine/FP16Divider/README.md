# FP16 Divider

**FP16Divider** divides two half-precision operands in Proteus. The FP16 arithmetic engine starts it when it receives a division request. The divider returns the packed FP16 quotient and its exception flags with a completion pulse.

## Architecture and significance

When **START** is high in STATE_IDLE, the divider checks **InputSpecialCaseDetected**. If the special-case resolver supplies a result, the divider registers it and asserts DONE directly from STATE_IDLE. Otherwise, it loads the normalized input significands, initializes the quotient and remainder registers, and stores the result sign and exponent.

**STATE_DIVIDE** builds the quotient one bit per cycle. Each iteration updates the dividend, quotient, and remainder. The final iteration commits those updates before **STATE_NORM** starts the clocked normalizer. This sequencing lets the divider reuse the same arithmetic logic across iterations and ensures the normalizer receives the completed quotient.

The controller waits for **NormDone** before storing the rounded fields and rounding flags. The final state publishes the packed result and exception flags together, so the parent engine can capture both during the same completion cycle.

## FSM type

**Mealy-type FSM.** The special-case path has registered Mealy behavior. In STATE_IDLE, the live START input and the operand-dependent InputSpecialCaseDetected signal determine whether **DONE** asserts on the next rising edge. The normalizer start is Moore-style because it depends only on the current state.

| Control | What drives it |
|---|---|
| DONE | Registers high when STATE_IDLE accepts a special case or STATE_FINALIZE publishes a regular result. |
| BUSY | Registers high when a regular division starts and remains high until finalization. |
| Normalizer start | Asserts during STATE_NORM. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | START with a special case → STATE_IDLE<br>START with regular operands → STATE_DIVIDE | Publish the special-case result and pulse DONE, or initialize the division registers and assert BUSY. |
| STATE_DIVIDE | More quotient bits → STATE_DIVIDE<br>Final quotient bit → STATE_NORM | Update the dividend, quotient, and remainder. Commit the last division step before normalization. |
| STATE_NORM | Next rising edge → STATE_WAIT_NORM | Start normalization using the completed quotient. |
| STATE_WAIT_NORM | NormDone high → STATE_ROUND | Wait for the normalized significand and exponent. |
| STATE_ROUND | Next rising edge → STATE_FINALIZE | Register the rounded fields and rounding flags. |
| STATE_FINALIZE | Next rising edge → STATE_IDLE | Publish the packed quotient and flags, deassert BUSY, and pulse DONE. |

Synchronous **reset** takes priority from any state and returns the controller to STATE_IDLE. STATE_IDLE holds while START is low, and STATE_WAIT_NORM holds while NormDone is low.

## Worked example

For 6.0 ÷ 4.0, both operands take the regular path. The divider stores a positive result sign and initializes the working registers. STATE_DIVIDE builds the quotient bit by bit, then the controller normalizes and rounds it.

STATE_FINALIZE publishes **1.5**, encoded as 0x3E00 in FP16. The quotient is exact, so Inexact stays low. The parent engine can sample the result and flags during the DONE pulse.
