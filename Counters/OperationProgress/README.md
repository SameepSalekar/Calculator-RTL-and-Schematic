# Operation Progress

Operation-progress counters track the execution of operations
that require multiple clock cycles to complete.

Within Proteus, these counters are used to coordinate
communication sequences and iterative arithmetic operations.

## I2C Bit and Phase Sequencing

These counters track the transmission of individual bits
and the progression through different phases of I2C
communication.

## Multiply and Divide Iterations

These counters track the number of iterations performed
during sequential multiplication and division operations,
allowing the arithmetic units to determine when an
operation is complete.
