# Combinational Multiplier vs Sequential Multiplier

### Resource Utilization

The sequential multiplier substantially reduced combinational FPGA resource usage relative to the combinational multiplier. After implementation, LUT utilization decreased from 126 to 63, a **50.00% reduction**, while occupied slices decreased from 38 to 20, a **47.37% reduction**.

This reduction was achieved by reusing arithmetic hardware across multiple clock cycles rather than realizing the complete multiplication operation as a single combinational datapath. The tradeoff was the introduction of state and control hardware: the sequential implementation used 50 registers and one global clock buffer, while the combinational implementation required neither.

Neither architecture used dedicated DSP blocks, allowing the comparison to focus on LUT-, carry-chain-, register-, and routing-based FPGA implementation.

### Primitive Mapping

The architectures produced substantially different primitive-level implementations. The combinational multiplier relied more heavily on wide LUT functions and carry-chain resources, including 56 LUT6, 35 LUT5, 31 LUT4, and 14 CARRY4 primitives.

The sequential implementation reduced these to 19 LUT6, 3 LUT5, 3 LUT4, and 8 CARRY4 primitives while introducing 49 FDRE and 1 FDSE flip-flops. CARRY4 usage therefore decreased by **42.86%**.

The mapping illustrates the architectural space-for-time tradeoff: the combinational design realizes more arithmetic logic concurrently, whereas the sequential design stores intermediate state and reuses a smaller arithmetic datapath across multiple cycles.

### Timing and Latency

The combinational multiplier exhibited a worst routed input-to-output propagation delay of **19.436 ns**, consisting of 7.282 ns of logic delay and 12.154 ns of routing delay across 15 logic levels.

The sequential implementation's longest reported register/control path was **3.343 ns**, consisting of 0.580 ns of logic delay and 2.763 ns of routing delay across 2 logic levels. However, these values are not equivalent operation-latency measurements. The combinational value represents propagation through the complete multiplier, while the sequential value represents only one reported path between state/control elements.

For an 8-bit multiplication, the sequential architecture performs **8 arithmetic iterations**, in addition to separate load and completion states. Because no clock constraint was defined for the sequential implementation, neither a valid maximum clock frequency nor an absolute START-to-DONE execution time is claimed.

The results therefore demonstrate that sequentialization substantially reduces the amount of combinational logic traversed within an individual cycle, but does so by distributing the multiplication operation across multiple cycles.

### Power Estimation

Vivado estimated total on-chip power of **20.719 W** for the combinational multiplier and **9.843 W** for the sequential multiplier, corresponding numerically to a **52.49% lower estimate** for the sequential implementation.

The sequential implementation also showed lower estimated slice-logic power (0.270 W versus 1.043 W) and signal power (0.338 W versus 1.003 W), consistent with its smaller combinational implementation.

These figures should not be interpreted as measured hardware power or as evidence of a definitive 52.49% power-efficiency advantage. Both Vivado reports have **Low overall confidence**, lack simulation-derived activity information, and are dominated by estimated I/O power. I/O represents approximately **87.79%** of the combinational estimate and **92.44%** of the sequential estimate. The sequential design additionally lacks a defined clock constraint, limiting the reliability of its clock-dependent dynamic-power estimate.

The power results are therefore retained as implementation-level estimates under Vivado's assumptions rather than measurements of real board-level consumption.

### Overall Architectural Tradeoff

The FPGA implementation demonstrates a clear **space-for-time tradeoff** between the two multiplier architectures.

The combinational multiplier uses substantially more LUT and carry-chain resources to realize multiplication concurrently and produces its result through a single combinational propagation path. The sequential multiplier approximately halves LUT and slice utilization by reusing arithmetic hardware, but introduces registers, control logic, clocking, and multiple execution cycles.

Neither architecture is universally superior. The preferable implementation depends on the system objective: a combinational multiplier favors single-pass combinational execution at greater area cost, while the sequential multiplier favors reduced combinational area at the cost of state, control complexity, and multi-cycle latency.

Most importantly, the experiment demonstrates that an RTL architectural choice directly affects FPGA primitive mapping, physical resource utilization, routed timing behavior, and estimated power characteristics after synthesis and implementation.
