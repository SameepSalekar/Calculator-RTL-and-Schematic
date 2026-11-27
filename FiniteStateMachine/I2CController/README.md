# I²C Controller

**I2CController** sends one byte to the LCD backpack over the I²C bus. It accepts a **Start** request from TextDisplayInterface, sends the slave address and write bit, checks the acknowledgments, and reports completion. The same controller carries LCD initialization commands, characters from live expression entry, and final result text.

## Architecture and significance

The controller tracks a transfer at three levels. **CurrentState** identifies the part of the bus transaction, such as sending the address, checking an acknowledgment, or generating STOP. **BitCounter** tracks the bit being sent within a byte. **PhaseCounter** sequences the SCL and SDA changes for each bit or bus condition.

The bus states advance their phases when **ClockEnable** is high. This lets the controller use the system clock for its registers while spacing the bus transitions at the configured I²C rate. During an acknowledgment phase, the controller releases SDA so the backpack can pull it low to acknowledge the byte.

An address NACK sends the FSM directly to **STATE_STOP**, skipping the data byte. Once the data byte has been sent, either acknowledgment outcome leads to STATE_STOP. The controller records a NACK in **AcknowledgeError**, and both successful and failed transfers use the same completion state. TextDisplayInterface checks AcknowledgeError when it observes **Done**.

## FSM type

**Mealy-type FSM.** AcknowledgeError has registered Mealy behavior. The acknowledgment state and the SDA value sampled during that phase determine whether the controller records an error. Done is state-driven and registers on the edge that leaves STATE_COMPLETE.

| Output | What drives it |
|---|---|
| AcknowledgeError | Records an address or data NACK for the current transfer. |
| Busy | Goes high when the controller accepts Start and goes low when the transfer completes. |
| Done | Pulses on the rising edge that returns the FSM from STATE_COMPLETE to STATE_IDLE. |

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| STATE_IDLE | Start high → STATE_START | Accept the request and assert Busy. |
| STATE_START | START condition complete → STATE_SEND_ADDRESS | Generate the I²C START condition. |
| STATE_SEND_ADDRESS | Last address-byte bit sent → STATE_ADDRESS_ACK | Shift out the slave address and write bit. |
| STATE_ADDRESS_ACK | Address ACK → STATE_SEND_DATA<br>Address NACK → STATE_STOP | Sample the acknowledgment. Record an error and skip the data byte on NACK. |
| STATE_SEND_DATA | Last data bit sent → STATE_DATA_ACK | Shift out the backpack data byte. |
| STATE_DATA_ACK | Acknowledgment phase complete → STATE_STOP | Record an error if the backpack returns NACK. |
| STATE_STOP | STOP condition complete → STATE_COMPLETE | Generate the I²C STOP condition. |
| STATE_COMPLETE | Next rising edge → STATE_IDLE | Deassert Busy and pulse Done. |

Synchronous **reset** returns the FSM to STATE_IDLE. During a bus transfer, the FSM holds its main state while PhaseCounter sequences the bus activity needed to satisfy the next transition.

## Worked example

Suppose TextDisplayInterface requests a backpack write to the 7-bit address 0x27. The controller generates START and sends the address byte 0x4E, which contains 0x27 followed by the write bit.

If the backpack acknowledges the address, the controller sends the data byte and checks its acknowledgment. It then generates STOP and pulses Done. If the backpack returns NACK on the address, the controller skips the data byte, generates STOP, and pulses Done with AcknowledgeError high so TextDisplayInterface can report the failed write.
