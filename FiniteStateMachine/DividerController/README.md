# Sequential Operand Entry

**SequentialOperandEntry** converts one numeric literal into the representation selected by the user. In the expression-capable Proteus calculator, **ExpressionEvaluator** calls it for each literal. The converter accepts a buffer of decimal digits and an optional decimal point, along with the sign and numerical mode. It returns an encoded integer, fixed-point, or FP16 value and its conversion status.

## Architecture and significance

The converter separates decimal parsing from numerical encoding. **DIGIT** reads one token at a time, beginning with the low nibble of the input buffer. **ADD_DIGIT** updates the accumulated decimal magnitude. Digits after the decimal point also increase the divisor by a factor of ten. For example, 2.5 becomes a magnitude of 25 and a divisor of 10.

The selected mode determines how that ratio is encoded. Integer mode requires an exact whole number. Fixed-point mode scales the magnitude by the configured number of fractional bits. For a nonzero FP16 value, the converter searches for the binary exponent before preparing the division.

The division loop uses three states per quotient bit. **DIV_LOW** computes the lower subtraction. **DIV_HIGH** uses the lower subtraction’s borrow to compute the upper subtraction. **DIV_COMMIT** updates the remainder and appends one quotient bit. Splitting the subtraction across clock cycles reduces the amount of arithmetic that must settle in a single cycle. The rounding states then use the remainder to implement round-to-nearest, ties-to-even where rounding applies.

## FSM type

**Moore-style FSM for completion control.** The FSM registers **done** when it executes **PUBLISH**. The pulse is visible for one cycle as the FSM returns to IDLE. Both successful and rejected conversions pass through PUBLISH, giving the evaluator one completion event to wait for.

| Output | What drives it |
|---|---|
| done | Registered high on the edge that leaves PUBLISH. |
| encoded | Holds the numeric representation produced by FORMAT for a successful conversion. |
| valid and error | Indicate whether the conversion produced a usable value. |
| overflow, underflow, and inexact | Report conversion conditions for the selected numerical mode. |

The evaluator samples the encoded value and status when done is high.

## State transitions

| Present state | Condition → next state | Main action |
|---|---|---|
| IDLE | start with a valid request → DIGIT<br>start with an invalid request → PUBLISH | Latch the input buffer, length, sign, and mode. |
| DIGIT | Decimal digit → ADD_DIGIT<br>First decimal point → DIGIT<br>Buffer consumed → PREPARE<br>Invalid symbol → PUBLISH | Consume the next nibble and track whether the decimal point has appeared. |
| ADD_DIGIT | Magnitude fits → DIGIT<br>Magnitude overflow → PUBLISH | Update the decimal magnitude and, for a fractional digit, the divisor. |
| PREPARE | Invalid literal → PUBLISH<br>Nonzero FP16 value → EXP_COMPARE<br>Other valid value → DIV_PREPARE | Check that the literal has digits, validate the sign, and set up scaling. |
| EXP_COMPARE | Next rising edge → EXP_UPDATE | Register the result of the exponent trial comparison. |
| EXP_UPDATE | Another exponent trial needed → EXP_COMPARE<br>Exponent found → DIV_PREPARE<br>FP16 exponent overflow → PUBLISH | Adjust the exponent search or set the final scaling shifts. |
| DIV_PREPARE | Next rising edge → DIV_LOW | Initialize the scaled dividend, denominator, quotient, and remainder. |
| DIV_LOW | Next rising edge → DIV_HIGH | Subtract the lower portion of the denominator. |
| DIV_HIGH | Next rising edge → DIV_COMMIT | Subtract the upper portion using the lower subtraction’s borrow. |
| DIV_COMMIT | More quotient bits → DIV_LOW<br>Last quotient bit → ROUND_COMPARE | Update the remainder and commit one quotient bit. |
| ROUND_COMPARE | Next rising edge → ROUND_ADD | Compare twice the remainder against the denominator. Use the quotient’s low bit to break ties. |
| ROUND_ADD | Next rising edge → FORMAT | Apply the rounding increment. |
| FORMAT | Next rising edge → PUBLISH | Pack the selected numeric representation or report a conversion error. |
| PUBLISH | Next rising edge → IDLE | Assert done for one cycle. |

Synchronous **reset** or **cancel** takes priority from any state and clears the published outputs.

## Worked example

For 2.5 in the default fixed-point format, the parser builds a magnitude of 25 and a divisor of 10. With four fractional bits, the converter scales the dividend by 16 and divides 400 by 10. The quotient is 40 with zero remainder.

FORMAT stores 40 as the raw fixed-point encoding, which is 0x28 in hexadecimal and represents 2.5. PUBLISH then pulses done with valid high, allowing ExpressionEvaluator to push the encoded value onto its value stack.
