# Text Display Interface

**TextDisplayInterface** translates LCD requests into byte transfers for the I²C backpack. It accepts initialization, command, and character requests from LCDTransactionCoordinator and reports when the request finishes or an acknowledgment error occurs. The coordinator supplies the characters for both live expression echo and final result display.

## Architecture and significance

The LCD receives regular commands and characters in 4-bit mode. The interface sends the upper nibble first, then the lower nibble. For each nibble, it sends an enable-high backpack byte followed by an enable-low backpack byte. The falling edge of the LCD enable signal latches the nibble. **TransferPhase** and **LowerNibblePending** track which part of the byte still needs to be sent.

The main FSM reuses the same **prepare → send → wait for busy → wait for done** sequence for each backpack byte. **STATE_NEXT** selects the next enable phase or nibble. After the last nibble, **STATE_DELAY** gives the LCD time to execute the command or write the character.

Initialization uses a separate **InitializationStep** register to select the next startup nibble or command once the required delay has elapsed. The main FSM sends each step through the same I²C handshake used for regular writes. This keeps the LCD startup sequence separate from the logic that transfers a byte and checks its acknowledgment.

## FSM type

**Mealy-type FSM.** **I2CStart** has registered Mealy behavior. In STATE_SEND, the live **I2CBusy** input determines whether the interface registers a start pulse at the next rising edge.

| Output | What drives it |
|---|---|
| I2CStart | Pulses when STATE_SEND sees I2CBusy low. |
| I2CData | Holds the backpack byte assembled in STATE_PREPARE. |
| Done | Pulses when the FSM leaves STATE_COMPLETE or STATE_ERROR. |
| Error | Indicates that the request ended through STATE_ERROR. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | Start with Initialize high → STATE_DELAY<br>Start with Initialize low → STATE_PREPARE | Accept the request. Begin the startup delay or prepare the first nibble of a command or character. |
| STATE_PREPARE | Next rising edge → STATE_SEND | Assemble the backpack byte for the current nibble and enable phase. |
| STATE_SEND | I2CBusy low → STATE_WAIT_BUSY | Pulse I2CStart. |
| STATE_WAIT_BUSY | I2CBusy high → STATE_WAIT_DONE | Wait for the I²C controller to accept the transfer. |
| STATE_WAIT_DONE | I2CDone without I2CAcknowledgeError → STATE_NEXT<br>I2CDone with I2CAcknowledgeError → STATE_ERROR | Check whether the backpack acknowledged the transfer. |
| STATE_NEXT | Enable-low phase or lower nibble still pending → STATE_PREPARE<br>Current LCD transfer finished → STATE_DELAY | Advance the enable phase or nibble, or begin the LCD execution delay. |
| STATE_DELAY | Delay elapsed and another initialization step remains → STATE_PREPARE<br>Delay elapsed and the request is finished → STATE_COMPLETE | Select the next startup transfer or finish the current request. |
| STATE_COMPLETE | Next rising edge → STATE_IDLE | Pulse Done for a successful request. |
| STATE_ERROR | Next rising edge → STATE_IDLE | Pulse Done with Error asserted. |

The controller holds its current state when no transition applies. Synchronous **reset** returns it to STATE_IDLE.

## Worked example

To display the character 5, LCDTransactionCoordinator submits ASCII 0x35 with RS high. TextDisplayInterface sends the upper nibble, 0x3, using an enable-high transfer followed by an enable-low transfer. It then repeats the sequence for the lower nibble, 0x5.

Each of the four backpack byte transfers goes through the I²C handshake. After the final enable-low transfer succeeds, the interface waits for the LCD execution delay and pulses Done. The coordinator can then request the next character.
