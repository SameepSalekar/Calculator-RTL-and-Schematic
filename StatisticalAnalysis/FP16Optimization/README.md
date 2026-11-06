
## Engineering Conclusions

### 1. Overview

The optimization of `FP16ArithmeticEngine.v` was evaluated across three development stages: **Original**, **Revised**, and **Optimized**.

The investigation focused on reducing FPGA resource utilization, eliminating unintended sequential logic, and evaluating the resulting implementation using Vivado synthesis, implementation, timing, and power reports.

The final architecture achieved:

- **13.06% reduction in implemented LUT utilization**, saving 475 LUTs.
- **14.75% reduction in occupied FPGA slices**, saving 159 slices.
- **Complete elimination of 20 inferred latches.**
- **No increase in total slice register utilization.**
- **No increase in DSP48E1 block utilization.**

These results demonstrate measurable improvements in FPGA resource efficiency, particularly in the combinational logic and physical slice utilization of the FP16 arithmetic engine.

### 2. FPGA Resource Utilization

The following measurements were obtained from Vivado implementation utilization reports.

| Resource | Original | Revised | Optimized | Overall Change |
|---|---:|---:|---:|---:|
| Implemented LUTs | 3,638 | 3,637 | 3,163 | -13.06% |
| Occupied Slices | 1,078 | 1,066 | 919 | -14.75% |
| Slice Registers | 446 | 446 | 446 | 0.00% |
| Flip-Flops | 426 | 446 | 446 | +4.69% |
| Inferred Latches | 20 | 0 | 0 | -100.00% |
| LUT6 Primitives | 1,784 | 1,784 | 1,571 | -11.94% |
| LUT5 Primitives | 1,003 | 1,003 | 755 | -24.73% |
| CARRY4 Primitives | 173 | 173 | 178 | +2.89% |
| DSP48E1 Blocks | 2 | 2 | 2 | 0.00% |

The reduction in implemented LUTs indicates that the optimized architecture requires fewer configurable logic resources.

Similarly, the reduction in occupied slices indicates that the implementation occupies fewer physical FPGA logic slices.

Although these measurements are related, LUT count and occupied slice count are not interchangeable. Slice utilization also depends on logic packing, register placement, carry-chain organization, and other implementation constraints.

Consequently, the larger percentage reduction in occupied slices does not necessarily imply an equivalent reduction in every category of FPGA resource.

### 3. Sequential Logic and Latch Elimination

The original implementation contained 20 inferred latches.

During the revision stage, these latches were eliminated, while the total number of slice registers remained constant at 446.

| Sequential Resource | Original | Revised | Optimized |
|---|---:|---:|---:|
| Flip-Flops | 426 | 446 | 446 |
| Latches | 20 | 0 | 0 |
| Total Slice Registers | 446 | 446 | 446 |

The results indicate that the revised architecture eliminated unintended level-sensitive storage without increasing the total number of sequential storage elements.

This distinction is important because latches and flip-flops have different timing behavior:

- **Latches** are level-sensitive and can remain transparent while their enable condition is active.
- **Flip-flops** are edge-triggered and capture data at a designated clock transition.

Unintended latch inference commonly occurs when combinational procedural logic does not assign outputs along every execution path.

Eliminating unintended latches improves the structural predictability of the RTL and simplifies reasoning about sequential timing.

However, the utilization reports alone do not establish a one-to-one replacement of each latch with a flip-flop or prove functional equivalence between revisions.

### 4. Combinational Logic Optimization

The most substantial resource reductions occurred between the Revised and Optimized stages.

| Resource | Revised | Optimized | Change |
|---|---:|---:|---:|
| Implemented LUTs | 3,637 | 3,163 | -13.03% |
| Occupied Slices | 1,066 | 919 | -13.79% |
| LUT6 Primitives | 1,784 | 1,571 | -11.94% |
| LUT5 Primitives | 1,003 | 755 | -24.73% |

The reductions in LUT5 and LUT6 primitive counts are consistent with the decrease in overall implemented LUT utilization.

Potential contributors to lower LUT utilization include:

- Simplification of combinational expressions.
- Removal of redundant logic.
- Sharing of common arithmetic or control operations.
- Reduction of unnecessary multiplexing.
- More efficient synthesis mapping.

These are possible optimization mechanisms rather than confirmed causes of the measured reductions.

Determining the exact contribution of individual RTL modifications would require examining the source changes alongside synthesis schematics, mapped netlists, and implementation reports.

### 5. Arithmetic Primitive Mapping

Not every FPGA resource decreased during optimization.

| Primitive | Original | Optimized | Change |
|---|---:|---:|---:|
| CARRY4 | 173 | 178 | +2.89% |
| DSP48E1 | 2 | 2 | 0.00% |

CARRY4 primitives implement dedicated carry-chain structures used in arithmetic operations such as addition, subtraction, and related carry-dependent logic.

The increase from 173 to 178 CARRY4 primitives indicates a change in arithmetic resource mapping.

An increase in one primitive category is not necessarily evidence of an inferior implementation. FPGA optimization involves trade-offs among configurable logic, dedicated arithmetic resources, sequential storage, routing, and timing.

The optimized architecture uses fewer LUTs and occupied slices despite requiring five additional CARRY4 primitives.

Meanwhile, DSP48E1 utilization remained constant at two blocks, indicating that the optimized implementation did not require additional dedicated DSP resources.

The reports do not establish whether the additional CARRY4 primitives directly contributed to the LUT reductions.

### 6. Timing Performance

Vivado timing analysis was used to evaluate setup timing and identify critical-path characteristics.

The final optimized implementation reported:

| Timing Metric | Value |
|---|---:|
| Clock Period Constraint | 40.000 ns |
| Worst Negative Slack (WNS) | +0.367 ns |
| Critical Data Path Delay | 39.571 ns |
| Logic Delay | 13.101 ns |
| Routing Delay | 26.470 ns |

The positive setup slack indicates that the optimized implementation satisfied the reported setup timing requirement under the analyzed clock constraints.

The critical data path consisted of approximately:

- **33.1% logic delay**
- **66.9% routing delay**

This distinction is important because reducing combinational logic does not automatically produce a proportional reduction in path delay.

FPGA timing depends on both logic propagation and the physical interconnect between mapped resources.

The relatively large routing contribution demonstrates that placement and routing remain important factors in the performance of the optimized arithmetic engine.

Earlier timing reports used different clock constraints. Therefore, they cannot establish a controlled improvement in maximum operating frequency.

A valid timing comparison would require equivalent constraints, implementation conditions, and timing-analysis assumptions across all development stages.

### 7. Power Estimation

Vivado estimated the following power consumption for the optimized implementation:

| Power Component | Estimated Power |
|---|---:|
| Dynamic Power | 0.017 W |
| Static Power | 0.070 W |
| Total On-Chip Power | 0.087 W |

Static power accounts for approximately 80.5% of the estimated total, while dynamic power accounts for approximately 19.5%.

Dynamic power depends on factors such as switching activity, clock frequency, capacitance, and operating voltage.

Static power primarily reflects leakage-related consumption under the modeled operating conditions.

The reported values are tool-generated estimates rather than direct measurements from physical hardware.

Because equivalent power estimates for the Original and Revised architectures were unavailable, the analysis does not claim a reduction in power consumption.

### 8. MATLAB-Based Engineering Analysis

MATLAB was used to establish a reproducible workflow for processing and visualizing Vivado resource measurements.

The workflow consists of two scripts:

**`FP16OptimizationData.m`**

- Organizes FPGA resource measurements into structured datasets.
- Calculates percentage changes between development stages.
- Exports resource utilization and rate-of-change data to CSV files.

**`FP16OptimizationAnalysis.m`**

- Imports the generated CSV datasets.
- Calculates resource reductions and optimization trends.
- Generates seven engineering comparison figures.
- Exports a consolidated results report.

The visualizations include absolute resource comparisons, primitive composition, sequential resource classification, cumulative reductions, normalized resource progression, and stage-to-stage percentage changes.

These measurements represent discrete architecture revisions rather than changes over equal time intervals.

Therefore, the reported percentage changes should not be interpreted as time-based optimization rates.

### 9. Engineering Limitations

The following limitations are recognized:

1. Resource utilization measurements are based on Vivado implementation reports.
2. Functional equivalence between RTL revisions is not established by utilization reports alone.
3. Timing reports used different clock constraints, preventing a controlled performance comparison.
4. Power estimates are available only for the final optimized implementation.
5. Changes in FPGA primitive mapping cannot be attributed to individual RTL modifications without additional evidence.
6. Synthesis and implementation results may depend on tool settings, constraints, directives, and FPGA target selection.

These limitations distinguish experimentally supported conclusions from interpretations that require further investigation.

### 10. Final Engineering Assessment

The FP16 arithmetic engine optimization demonstrates that RTL development involves more than implementing mathematically correct operations.

Efficient FPGA design also requires attention to unintended storage inference, combinational logic complexity, arithmetic primitive mapping, and physical implementation characteristics.

The most significant findings are:

- **475 fewer implemented LUTs**, representing a 13.06% reduction.
- **159 fewer occupied slices**, representing a 14.75% reduction.
- **20 inferred latches eliminated** during the revision stage.
- **446 total slice registers maintained** across all three architectures.
- **Two DSP48E1 blocks maintained** throughout optimization.
- **Positive setup timing slack** under the final 40 ns clock constraint.

The primary demonstrated achievement is improved FPGA resource efficiency.

By combining Verilog RTL development, Vivado implementation analysis, MATLAB data processing, and quantitative visualization, the project establishes a structured methodology for evaluating and documenting hardware architecture improvements.

**The central engineering conclusion is that an optimized FPGA architecture should be evaluated through measured hardware implementation results, not solely through RTL code complexity or functional simulation.**

