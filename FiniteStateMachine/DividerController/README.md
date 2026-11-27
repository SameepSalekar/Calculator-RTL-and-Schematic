# Divider Controller

**DividerController** sequences the load, iteration, and completion phases of the parameterized divider used by the integer and fixed-point arithmetic engines in Proteus. It accepts a **START** request, checks for a zero divisor, and waits for **CountDone** when the datapath performs a division.

## Architecture and significance

The normal path separates operand loading from iteration. **LOAD** gives the divider datapath one cycle to initialize its working registers. **RUN** asserts **step** so the datapath can update the quotient and remainder on successive rising edges. The controller stays in RUN until CountDone is high, then enters **DONE_STATE** to signal completion.

The divide-by-zero path goes directly from **IDLE** to DONE_STATE. It asserts **ERROR** while the invalid request is present in IDLE and skips both loading and iteration. The enclosing divider can latch that error at the same edge that takes the controller into DONE_STATE. Both paths use the same one-cycle **DONE** signal.

## FSM type

**Mealy-type FSM.** ERROR depends on both the present state and the live START and DivideByZero inputs. The other control outputs are Moore-style.

| Output | Style | When it is high |
|---|---|---|
| ERROR | Mealy | In IDLE when START and DivideByZero are both high. |
| load | Moore | During LOAD. |
| step | Moore | During RUN. |
| BUSY | Moore | During LOAD and RUN. |
| DONE | Moore | During DONE_STATE. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| IDLE | START with DivideByZero low → LOAD<br>START with DivideByZero high → DONE_STATE | Accept a normal request or assert ERROR for a zero divisor. |
| LOAD | Next rising edge → RUN | Assert load and BUSY while the datapath initializes. |
| RUN | CountDone high → DONE_STATE | Assert step and BUSY. Stay in RUN while CountDone is low. |
| DONE_STATE | Next rising edge → IDLE | Assert DONE for one cycle with BUSY low. |

Synchronous **reset** takes priority on the rising edge and returns the controller to IDLE. IDLE holds while START is low.

## Worked example

For 13 ÷ 3 in integer mode, START takes the controller from IDLE to LOAD. The datapath loads the operands, then updates the quotient and remainder during RUN. When CountDone is sampled high, the controller enters DONE_STATE and pulses DONE. The integer datapath produces a quotient of 4 and a remainder of 1.

For 13 ÷ 0, ERROR asserts in IDLE as soon as START and DivideByZero are both high. At the next rising edge, the controller enters DONE_STATE and asserts DONE without running the division loop. The controller’s ERROR output goes low in DONE_STATE, so the enclosing divider latches the error to carry it through completion.
