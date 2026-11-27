# Clocked FP16 Adder and Subtractor

**FP16AddSubClocked** performs half-precision addition and subtraction in Proteus. The FP16 arithmetic engine calls it for standalone addition and subtraction, running accumulation, and the addition stage of multiply-accumulate.

## Architecture and significance

The controller captures both operands and the **subtract** control when it accepts **start**. The datapath then works from those stored values throughout the operation. In **DECODE**, the special-case resolver can supply a result immediately. That path publishes the result and flags without going through significand alignment and arithmetic.

The regular path first orders the operands by magnitude, then computes their exponent difference. **ALIGN** shifts the smaller significand to match the larger operand’s exponent and preserves discarded information in a sticky bit for rounding. **SUM** adds or subtracts the aligned significands according to their effective signs. For a subtraction request, the controller reverses the second operand’s sign on the regular path, so both operations use the same significand hardware.

The remaining states launch normalization, wait for it to finish, round the normalized result, and pack the final FP16 value. The registers between stages split the work across clock cycles. The separate wait state lets the normalizer signal when its output is ready.

## FSM type

**Mealy-type FSM.** The completion logic has registered Mealy behavior. In DECODE, the live **special** signal from the datapath determines whether **done** is asserted on the next rising edge. The busy and normalizer start controls are Moore-style.

| Control | Style | What drives it |
|---|---|---|
| done | Registered Mealy behavior on the special-case path | Asserted on the edge leaving DECODE when special is high, or on the edge leaving PACK for a regular result. |
| busy | Moore | High whenever the FSM is outside IDLE. |
| Normalizer start | Moore | High during NORMALIZE. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| IDLE | start high → DECODE | Capture both operands and the subtraction control. |
| DECODE | special high → IDLE<br>special low → ORDER | Publish the special-case result and flags, or register the unpacked exponents, significands, and effective signs. |
| ORDER | Next rising edge → DIFF | Store the larger and smaller operands by magnitude. |
| DIFF | Next rising edge → ALIGN | Register the exponent difference. |
| ALIGN | Next rising edge → SUM | Shift and store the smaller significand with sticky-bit information. |
| SUM | Next rising edge → NORMALIZE | Register the significand sum or difference and its sign. |
| NORMALIZE | Next rising edge → WAIT_NORM | Start the clocked normalizer. |
| WAIT_NORM | norm_done high → ROUND | Wait for the normalized significand and exponent. |
| ROUND | Next rising edge → PACK | Register the rounded fields and exception flags. |
| PACK | Next rising edge → IDLE | Publish the packed FP16 result and flags, then pulse done. |

Synchronous reset takes priority from any state. It returns the controller to IDLE and clears done, result, and flags. IDLE holds while start is low, and WAIT_NORM holds while norm_done is low.

## Worked example

For 1.5 − 0.5, the controller captures both operands with subtract asserted. DECODE reverses the effective sign of 0.5 for the regular arithmetic path. The operands have different exponents, so ALIGN right-shifts the smaller significand by one bit. SUM then subtracts the aligned smaller significand from the larger one.

After normalization and rounding, PACK publishes **1.0**, encoded as 0x3C00 in FP16. The result is exact, so the inexact flag stays low. The parent engine can sample the result and flags during the done pulse.
