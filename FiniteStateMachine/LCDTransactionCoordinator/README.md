# LCD Transaction Coordinator

**LCDTransactionCoordinator** initializes the Proteus LCD and writes one 20-character row at a time. It receives live expression updates while the user types and displays the final arithmetic result or an error when evaluation finishes. It sends each LCD command or character to **TextDisplayInterface**.

## Architecture and significance

The coordinator keeps a pending update and a separate active snapshot. **ExpressionUpdate** queues a copy of the current expression row. A rising edge on **ArithmeticDone** queues the final result or error. If both events arrive in the same cycle, the final result takes priority. If more edits arrive while a row is being written, the pending slot keeps the latest update.

When the coordinator starts a row, it copies the pending update into its active registers. The active snapshot stays stable through all 20 character writes, so typing during a transfer cannot mix characters from two versions of the expression. Expression and result updates share the same cursor-address and character-write states. The active update type selects the character source.

For each request, the coordinator waits until **TextBusy** is low, pulses **TextStart**, then waits for TextBusy to go high before checking **TextDone**. This handshake confirms that the text interface accepted the request before the coordinator waits for completion. The coordinator checks **TextError** when the transfer finishes.

## FSM type

**Mealy-type FSM.** TextStart has registered Mealy behavior because the current request state and the live TextBusy input determine whether it asserts on the next rising edge. The row completion pulse is state-driven.

| Output | What drives it |
|---|---|
| TextStart | Registers high in an initialization, address, or character request state when TextBusy is low. |
| TextData | Carries the cursor command or the character selected from the active expression or result. |
| Done | Pulses on the edge leaving STATE_COMPLETE. It marks a completed LCD row write for either an expression or a result. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_INIT_START | TextBusy low → STATE_INIT_WAIT_BUSY | Pulse TextStart with TextInitialize asserted. |
| STATE_INIT_WAIT_BUSY | TextBusy high → STATE_INIT_WAIT_DONE | Wait for the text interface to accept initialization. |
| STATE_INIT_WAIT_DONE | TextDone without TextError → STATE_IDLE<br>TextDone with TextError → STATE_ERROR | Mark initialization complete or record a failure. |
| STATE_IDLE | PendingValid high and NewDisplayEvent low → STATE_ADDRESS_START | Move the pending update into the active registers and reset the character index. |
| STATE_ADDRESS_START | TextBusy low → STATE_ADDRESS_WAIT_BUSY | Send the command that positions the cursor at the start of the row. |
| STATE_ADDRESS_WAIT_BUSY | TextBusy high → STATE_ADDRESS_WAIT_DONE | Wait for the cursor command to be accepted. |
| STATE_ADDRESS_WAIT_DONE | TextDone without TextError → STATE_CHARACTER_START<br>TextDone with TextError → STATE_ERROR | Begin writing characters or record a failure. |
| STATE_CHARACTER_START | TextBusy low → STATE_CHARACTER_WAIT_BUSY | Send the character at the active row index. |
| STATE_CHARACTER_WAIT_BUSY | TextBusy high → STATE_CHARACTER_WAIT_DONE | Wait for the character write to be accepted. |
| STATE_CHARACTER_WAIT_DONE | Successful write with more characters remaining → STATE_CHARACTER_START<br>Successful write of the final character → STATE_COMPLETE<br>TextDone with TextError → STATE_ERROR | Advance the character index, finish the row, or record a failure. |
| STATE_COMPLETE | Next rising edge → STATE_IDLE | Pulse Done for one cycle. |
| STATE_ERROR | PendingValid or NewDisplayEvent → STATE_INIT_START | Retry LCD initialization when a display update is available. |

**NewDisplayEvent** indicates a new result or expression update. A successful write requires TextDone high and TextError low. The FSM holds its state when no transition applies. Synchronous reset takes priority and returns it to STATE_INIT_START.

## Worked example

While the user types (10+2)×3, the LCD shows (10+2)\*3. If a row write is already underway when the user enters 3, the coordinator finishes that write and then displays the latest pending snapshot. Spaces after the expression clear leftover characters when the user deletes a token.

Pressing HASH submits the expression. Once evaluation finishes, ArithmeticDone queues the result. The coordinator moves the cursor to the start of the row and writes **RESULT: 00000024**, which is decimal 36 shown in hexadecimal.
