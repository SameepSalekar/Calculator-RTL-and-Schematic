# Elapsed Time

Elapsed-time counters measure the number of clock cycles
that have passed since the initiation of an operation.

Within Proteus, these counters are used to satisfy timing
requirements by introducing controlled delays between
operations.

## LCD Execution Delay

The LCD execution delay counter allows sufficient time for
the LCD to complete its current operation before another
command or character is transmitted.

The required delay is achieved by counting clock cycles
until a predetermined terminal count is reached.
