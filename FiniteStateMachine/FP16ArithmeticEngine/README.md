# FP16 Arithmetic Engine

**FP16ArithmeticEngine** coordinates half-precision arithmetic in Proteus. Its internal FSM schedules operations that use the clocked adder and sequential multiplier, including addition, subtraction, multiplication, accumulation, and multiply-accumulate (MAC).

In the expression-capable calculator, ExpressionEvaluator applies BODMAS and submits individual operations through the arithmetic core. This FSM handles the sequencing inside a single FP16 operation.

## Architecture and significance

In **IDLE**, the FSM accepts a supported operation when **Start** is high and saves the operation code and operands. Addition, subtraction, and accumulation begin with the adder. Multiplication and MAC begin with the multiplier.

Each arithmetic unit has a dedicated start state and wait state. **START_ADD** and **START_MUL** assert their respective start signals for one cycle. **WAIT_ADD** and **WAIT_MUL** let each unit take the cycles it needs and advance when it signals completion.

MAC uses both units in sequence. When the multiplier finishes, the controller saves the FP16 product and its exception flags, then starts the adder with the saved product and the current MAC accumulator value. When the adder finishes, the controller updates the accumulator and combines the exception flags from both stages. The product is rounded to FP16 before addition, so the operation has two rounding steps.

Comparison, division, square root, wide accumulation, and running product use separate paths in the engine. Their control behavior is outside the scope of this state diagram.

## FSM type

**Moore-type FSM.** For the internal FSM shown here, the multiplier start, adder start, and busy controls depend only on **State**. The completion inputs determine when the controller can advance.

| Control | What drives it |
|---|---|
| Multiplier start | High during START_MUL. |
| Adder start | High during START_ADD. |
| TransactionBusy | High whenever State is outside IDLE. |
| TransactionDone | Registered on the edge that captures the final result and returns the FSM to IDLE. |

The engine’s public outputs also depend on the selected operation. In compare mode, for example, the engine’s public Done follows Start through the separate comparison path.

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| IDLE | Start with addition, subtraction, or accumulation → START_ADD<br>Start with multiplication, sequential multiplication, or MAC → START_MUL | Save the requested operation and operands. |
| START_ADD | Next rising edge → WAIT_ADD | Assert the adder start signal for one cycle. |
| WAIT_ADD | AddDone high → IDLE | Capture the result and flags. Update the accumulator for accumulation or MAC, then assert TransactionDone. |
| START_MUL | Next rising edge → WAIT_MUL | Assert the multiplier start signal for one cycle. |
| WAIT_MUL | SequentialMultiplierDone high for MAC → START_ADD<br>SequentialMultiplierDone high for standalone multiplication → IDLE | For MAC, save the product and flags for the addition stage. For standalone multiplication, publish the product and assert TransactionDone. |

The FSM holds its state when no transition applies. Synchronous **reset** or **Clear** returns it to IDLE and clears the pending completion pulse. Reset clears both accumulators. Clear resets the accumulator associated with the selected accumulation or MAC operation.

## Worked example

Suppose the MAC accumulator holds 5 and the next request supplies operands 2 and 3. The controller saves the operands in IDLE, enters START_MUL, and waits in WAIT_MUL until the multiplier produces 6.

Because the operation is MAC, the controller saves 6 and its exception flags and proceeds to START_ADD. The adder computes 5 + 6. When AddDone asserts, the controller stores 11 in the MAC accumulator, captures the combined exception flags, and pulses TransactionDone as it returns to IDLE.
