# FP16 Sequential Multiplier

**FP16SequentialMultiplier** multiplies two half-precision operands in Proteus. The FP16 arithmetic engine uses it for multiplication and the product stage of multiply-accumulate. A separate instance supplies the multiplication step for the FP16 running product.

## Architecture and significance

On **START**, the controller checks whether the operands require a special-case result. When **InputSpecialCaseDetected** is high, it registers the result and its flags directly from STATE_IDLE. The regular path initializes the product register, loads the operand significands, and stores the product sign and exponent.

In **STATE_MULTIPLY**, the datapath examines one multiplier bit per cycle. If that bit is 1, it adds the shifted multiplicand to **ProductRegister**. It then shifts the multiplicand left and the multiplier right. The same adder handles all 11 significand iterations, spreading the partial-product work across clock cycles.

The controller commits the final partial product before launching the clocked normalizer. **STATE_WAIT_NORMALIZE** holds until **NormalizationDone** asserts. The following states register the rounded fields and publish the packed FP16 result together with its exception flags.

## FSM type

**Mealy-type FSM.** The special-case path has registered Mealy behavior. In STATE_IDLE, the live START signal and the operand-dependent InputSpecialCaseDetected signal determine whether the controller asserts **DONE** on the next rising edge. The normalizer start is Moore-style because it depends only on the current state.

| Control | What drives it |
|---|---|
| DONE | Registers high when STATE_IDLE accepts a special case or when STATE_FINALIZE publishes the regular result. |
| BUSY | Registers high when the controller accepts a regular multiplication and stays high through processing until finalization. |
| Normalizer start | Asserts whenever the controller is in STATE_NORMALIZE. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | START with a special case → STATE_IDLE<br>START with regular operands → STATE_MULTIPLY | Publish the special-case result and pulse DONE, or initialize the working registers and assert BUSY. |
| STATE_MULTIPLY | More significand bits → STATE_MULTIPLY<br>Final significand bit → STATE_NORMALIZE | Apply one shift-and-add iteration. Commit the updated product on the final iteration. |
| STATE_NORMALIZE | Next rising edge → STATE_WAIT_NORMALIZE | Start normalization using the completed product. |
| STATE_WAIT_NORMALIZE | NormalizationDone high → STATE_ROUND | Wait for the normalized significand and exponent. |
| STATE_ROUND | Next rising edge → STATE_FINALIZE | Register the rounded fields and rounding flags. |
| STATE_FINALIZE | Next rising edge → STATE_IDLE | Publish the packed result and flags, deassert BUSY, and pulse DONE. |

Synchronous **reset** takes priority from any state and returns the controller to STATE_IDLE. STATE_IDLE holds while START is low, and STATE_WAIT_NORMALIZE holds while NormalizationDone is low.

## Worked example

For 1.5 × 2.0, both operands take the regular path. The controller loads their significands, stores a positive result sign, and adds their unbiased exponents. STATE_MULTIPLY then builds the significand product across 11 iterations.

After the final iteration, the controller normalizes and rounds the product. STATE_FINALIZE publishes **3.0**, encoded as 0x4200 in FP16. The result is exact, so Inexact stays low. The parent engine can sample the result and flags during the DONE pulse.
