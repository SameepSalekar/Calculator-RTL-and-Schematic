
## Engineering Conclusions

### Resource Utilization

The three arithmetic engines exhibited substantial differences in FPGA resource utilization after implementation. The Integer Arithmetic Engine required 584 LUTs, 179 slices, and 203 registers, while the Fixed-Point Arithmetic Engine required 521 LUTs, 161 slices, and 163 registers. Relative to the Integer implementation, the Fixed-Point Engine reduced LUT utilization by **10.79%**, occupied slices by **10.06%**, and register utilization by **19.70%**.

The optimized FP16 Arithmetic Engine required considerably more resources, using 3,163 LUTs, 919 slices, and 446 registers. Compared with the Integer Engine, this represents approximately 5.42 times as many LUTs, 5.13 times as many slices, and 2.20 times as many registers. Relative to the Fixed-Point Engine, FP16 required approximately 6.07 times as many LUTs and 5.71 times as many slices.

The difference also extended to dedicated FPGA resources. Both the Integer and Fixed-Point engines used no DSP blocks, while the FP16 implementation used two. The FP16 Engine additionally required 104 bonded IOBs compared with 51 for each of the 8-bit engines. All three implementations used one global clock buffer.

These results demonstrate that the optimized FP16 architecture has a substantially larger implemented hardware footprint. However, this difference should not be interpreted as the resource overhead of floating-point representation alone. The FP16 Engine operates on a wider datapath and implements IEEE 754 floating-point functionality, including exponent handling, significand alignment, normalization, rounding, and exception processing. The three engines therefore do not represent functionally identical arithmetic implementations.

### Primitive Mapping

The three arithmetic architectures produced noticeably different FPGA primitive compositions.

The Integer Engine used 248 LUT6 primitives, compared with 161 for the Fixed-Point Engine and 1,571 for the FP16 Engine. The Fixed-Point implementation therefore reduced LUT6 usage by **35.08%** relative to Integer, despite using slightly more LUT2, LUT3, LUT4, and LUT5 primitives.

The FP16 implementation exhibited substantially greater utilization across most LUT primitive categories, including 755 LUT5, 603 LUT4, 551 LUT3, and 405 LUT2 primitives. However, its reported LUT1 usage was only two primitives, compared with 75 for Integer and 71 for Fixed-Point.

Carry-chain utilization also increased with architectural complexity. The Integer Engine used 67 CARRY4 primitives, the Fixed-Point Engine used 70, and the FP16 Engine used 178. Register mapping followed a similar pattern, with 199 FDRE primitives for Integer, 159 for Fixed-Point, and 442 for FP16. All three architectures used four FDSE primitives.

MUXF7 utilization differed less substantially, with nine primitives in the Integer implementation, two in Fixed-Point, and five in FP16.

These measurements show that differences in overall resource utilization do not correspond to uniform increases or decreases across every primitive category. Instead, Vivado mapped the arithmetic architectures into different combinations of LUT functions, carry-chain resources, registers, and multiplexers.

The primitive-level results also demonstrate that physical FPGA resource requirements depend on the synthesized Boolean structure and technology mapping of each RTL implementation, rather than solely on datapath width or the number of arithmetic operations supported.

### Timing Analysis

The Integer and Fixed-Point engines were evaluated using unconstrained routed register-to-register timing paths. Under this methodology, the Integer Engine exhibited a longest reported data-path delay of **4.082 ns**, while the Fixed-Point Engine exhibited **4.378 ns**, corresponding to a 7.25% longer path for the Fixed-Point implementation.

The Fixed-Point Engine contained slightly less logic delay, at 1.941 ns compared with 1.957 ns for Integer, but greater routing delay, at 2.437 ns compared with 2.125 ns. The increase in routing delay outweighed the reduction in logic delay, despite the Fixed-Point path traversing six reported logic levels compared with seven for Integer.

The optimized FP16 Engine exhibited a considerably longer reported setup data-path delay of **39.571 ns**, consisting of 13.101 ns of logic delay and 26.470 ns of routing delay across 56 logic levels.

Routing accounted for approximately 66.89% of the FP16 path delay, compared with 52.06% for Integer and 55.66% for Fixed-Point. This indicates that routing contributed substantially to the reported critical timing behavior of the FP16 implementation.

The FP16 path originated within the wide-accumulator datapath and terminated at an underflow register. Its substantial logic depth and routing contribution identify the wide-accumulator implementation as an important timing bottleneck in the optimized FP16 architecture.

Unlike the Integer and Fixed-Point engines, the FP16 implementation was evaluated with a defined **40.000 ns clock constraint**, corresponding to a target frequency of 25 MHz. Vivado reported a worst setup slack of +0.367 ns and a worst hold slack of +0.123 ns, with no failing setup or hold endpoints. The implementation therefore satisfied its specified internal clock timing constraints.

However, the timing results are not directly equivalent across all three architectures. The Integer and Fixed-Point measurements represent unconstrained routed register-to-register paths, whereas the FP16 measurement represents the worst-slack setup path under a defined clock constraint.

Consequently, the substantially longer FP16 path should not be interpreted as proof of a proportional reduction in arithmetic throughput or operation-level performance. The engines differ in datapath width, functional complexity, internal arithmetic units, and potentially the number of clock cycles required to complete individual operations.

The results characterize the reported timing behavior of each implementation rather than establishing a controlled maximum-frequency or arithmetic-latency ranking.

### Power Analysis

Vivado estimated total on-chip power of **16.077 W** for the Integer Arithmetic Engine, **12.463 W** for the Fixed-Point Arithmetic Engine, and **0.087 W** for the optimized FP16 Arithmetic Engine.

The Fixed-Point implementation produced a numerically 22.48% lower total power estimate than Integer. However, the difference was dominated by modeled I/O power, which decreased from 9.675 W to 5.900 W.

Despite its lower total estimate, the Fixed-Point Engine exhibited slightly higher slice-logic power, at 3.448 W compared with 3.293 W for Integer, and higher signal power, at 2.930 W compared with 2.818 W. The reduction in total estimated power therefore cannot be attributed directly to lower LUT and register utilization.

The FP16 Engine produced a substantially smaller total power estimate, consisting of 0.017 W dynamic power and 0.070 W device static power. Its estimated slice-logic and signal power were each 0.006 W, while I/O power was 0.003 W.

However, the FP16 estimate was generated under different timing and activity assumptions from the earlier Integer and Fixed-Point studies. The FP16 implementation used a defined 40 ns clock constraint, whereas the Integer and Fixed-Point implementations did not contain equivalent clock constraints.

All three power estimates were generated without sufficiently specified simulation-derived switching activity, and the FP16 report explicitly identified its overall estimation confidence as Low.

The large numerical difference between FP16 and the other two engines therefore should not be interpreted as evidence that FP16 arithmetic consumes substantially less physical power despite requiring more FPGA resources.

Instead, the results demonstrate the sensitivity of Vivado power estimation to clock constraints, switching-activity assumptions, I/O modeling, and implementation conditions. A meaningful three-way power-efficiency comparison would require consistent operating conditions and representative switching activity across all architectures.

### Overall Architectural Comparison

The three arithmetic engines demonstrate distinct FPGA implementation characteristics associated with their respective arithmetic representations and internal architectures.

The Fixed-Point Engine produced the smallest resource footprint, requiring 10.79% fewer LUTs, 10.06% fewer slices, and 19.70% fewer registers than Integer. Its lower resource utilization was accompanied by a different primitive composition rather than a uniform reduction across all LUT and carry-chain categories.

The Integer Engine exhibited a slightly shorter longest reported routed register-to-register path than Fixed-Point, although both implementations contained different functional units along their respective longest paths. The timing difference was primarily associated with routing rather than logic depth.

The optimized FP16 Engine required substantially more FPGA resources, including approximately 5.42 times the LUTs and 5.13 times the slices of Integer. Its greater resource requirements reflect a wider datapath and more extensive floating-point arithmetic functionality, including normalization, rounding, exponent processing, and exception handling.

The FP16 implementation also exhibited a considerably deeper reported setup path, particularly within its wide-accumulator datapath. Nevertheless, it satisfied its specified 40 ns clock constraint, demonstrating successful timing closure for the evaluated internal clock domain.

The power results present a different picture numerically, with FP16 reporting the lowest estimated total power despite having the largest resource footprint. However, differences in clock constraints and switching-activity assumptions prevent this observation from supporting a reliable power-efficiency ranking.

Overall, the comparison demonstrates that **arithmetic representation, datapath width, functional complexity, and RTL architecture collectively influence FPGA resource utilization, primitive mapping, and routed timing behavior**. The final implementation also depends on synthesis optimization, LUT packing, placement, routing, and the assumptions used for power estimation.

No single arithmetic architecture can be identified as universally superior from these measurements. The appropriate implementation depends on the required numerical representation, precision, supported operations, resource budget, throughput, latency, and power constraints.

The conclusions are therefore specific to these RTL implementations, the Vivado 2026.1 synthesis and implementation flow, and the Artix-7 XC7A35T FPGA target evaluated in this project.

## Analysis Limitations

- The Integer and Fixed-Point engines use 8-bit arithmetic datapaths, whereas the FP16 Engine uses the 16-bit IEEE 754 half-precision format. The comparison is therefore not normalized for datapath width or numerical precision.
- The three engines do not implement identical sets of arithmetic operations or internal RTL modules. Differences in supported functionality and architectural organization contribute to their resource requirements.
- Resource utilization measurements describe the implemented hardware footprint of each complete engine rather than the isolated hardware cost of a single arithmetic operation.
- Primitive-level counts reflect Vivado technology mapping and should not be interpreted as a direct measure of algorithmic complexity or arithmetic throughput.
- The Integer and Fixed-Point timing results use unconstrained routed register-to-register paths, whereas FP16 uses a constrained setup path under a 40 ns clock period. These measurements do not establish a controlled maximum-frequency comparison.
- The longest reported paths occur in different functional units. The Integer path is associated with the running-product datapath, the Fixed-Point path with the divider datapath, and the FP16 path with the wide-accumulator datapath.
- The FP16 timing report identifies 39 input ports and 60 output ports without specified input/output delays. Its successful timing closure therefore does not establish complete timing compliance for every external interface.
- Timing-path delay does not represent complete arithmetic-operation latency. Multi-cycle operations, control sequencing, and operation-specific execution requirements must be considered separately.
- The Vivado power estimates have Low overall confidence and do not use sufficiently specified simulation-derived switching activity. They should not be interpreted as measured FPGA board power.
- The Integer and Fixed-Point power estimates are strongly influenced by modeled I/O activity, while the FP16 estimate uses different clock and activity assumptions. Direct three-way power-efficiency conclusions are therefore unsupported.
- The results apply to the specific RTL implementations, Vivado 2026.1 tool flow, and Artix-7 XC7A35T device used in this study. Relative behavior may change with FPGA family, datapath width, synthesis settings, timing constraints, placement, routing, or operating conditions.
