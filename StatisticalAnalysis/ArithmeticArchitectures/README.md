# Arithmetic Architecture Comparison

Comparative hardware analysis of three Verilog arithmetic engines implemented on the Xilinx Artix-7 FPGA.

## Arithmetic Engines

- **IntegerArithmeticEngine:** 8-bit integer arithmetic.
- **FixedPointArithmeticEngine:** 8-bit fixed-point arithmetic.
- **FP16ArithmeticEngine:** 16-bit IEEE 754 half-precision floating-point arithmetic (optimized).

## Evaluation Metrics

LUT utilization, flip-flops, occupied slices, DSP usage, critical-path delay, timing performance, and estimated power consumption.

## Methodology

Hardware measurements are obtained from Vivado synthesis and implementation reports. MATLAB is used for comparative analysis and visualization, accounting for differences in operand width and timing constraints.

## Repository Structure

- `Data/` - Vivado reports and measurements.
- `MATLAB/` - Analysis and visualization scripts.
- `Results/` - Generated graphs and comparison tables.
