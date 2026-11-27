# Multiplier Controller

**MultiplierController** sequences the load, iteration, and completion phases of a sequential multiplier. It accepts a **START** request, tells the datapath when to load its operands and step through the multiplication, and signals completion when the iteration counter asserts **CountDone**.

## Architecture and significance

The controller separates the multiplication into three phases. **LOAD** gives the datapath one cycle to load its operands and initialize its working registers. **RUN** keeps **step** asserted while the datapath builds the product over successive clock cycles. **DONE_STATE** ends the iteration and gives the caller a one-cycle **DONE** signal.

This separation lets the datapath reuse the same arithmetic hardware across iterations. The datapath performs the multiplication, the counter tracks progress, and the controller uses CountDone to decide when to finish. The same controller design can serve multiple multiplier instances.

## FSM type

**Moore-type FSM.** All four outputs are decoded from **CurrentState**. START and CountDone determine the next state. The outputs for a given state are fixed.

| Output | When it is high |
|---|---|
| load | During LOAD |
| step | During RUN |
| BUSY | During LOAD and RUN |
| DONE | During DONE_STATE |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| IDLE | START high → LOAD | Accept a new multiplication request. |
| LOAD | Next rising edge → RUN | Assert load and BUSY so the datapath can initialize. |
| RUN | CountDone high → DONE_STATE | Assert step and BUSY. Stay in RUN while CountDone is low. |
| DONE_STATE | Next rising edge → IDLE | Assert DONE for one cycle with BUSY low. |

Synchronous **reset** takes priority at the rising edge and returns the controller to IDLE. A new request is accepted in IDLE.

## Worked example

For a request to multiply 3 by 5, START takes the controller from IDLE to LOAD. During LOAD, the datapath receives the operands. On the next rising edge, the controller enters RUN and asserts step. The datapath updates the partial product on each rising edge while RUN is active.

On the rising edge that samples CountDone high, the controller leaves RUN and enters DONE_STATE. Step and BUSY go low, and DONE goes high for one cycle. The controller then returns to IDLE, ready for another request.
