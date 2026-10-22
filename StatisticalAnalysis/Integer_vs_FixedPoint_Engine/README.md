# Integer vs Fixed Point Arithmetic Engine
### Resource Utilization

The Fixed-Point Arithmetic Engine required fewer general FPGA resources than the Integer Arithmetic Engine in this implementation. After routing, LUT utilization decreased from 584 to 521, a 10.79% reduction, while occupied slices decreased from 179 to 161, a 10.06% reduction. Register utilization decreased from 203 to 163, corresponding to a 19.70% reduction.

Both engines used the same 51 bonded IOBs and one global clock buffer, while neither implementation used DSP or block RAM resources. The resource difference therefore occurs primarily within the LUT- and register-based implementation rather than through different use of dedicated arithmetic or memory blocks.

The Fixed-Point Engine also showed a larger proportion of dual-output LUT packing, with 22.84% of its physical LUTs using both O5 and O6 compared with 15.07% for the Integer Engine. This is treated as an implementation observation rather than the sole explanation for the overall resource difference.

### Primitive Mapping

The two arithmetic engines produced noticeably different LUT mappings despite targeting the same FPGA. The Integer Engine used 248 LUT6 primitives compared with 161 for the Fixed-Point Engine, a 35.08% reduction in the fixed-point implementation. However, the Fixed-Point Engine used somewhat more LUT2, LUT3, LUT4, and LUT5 primitives and slightly more CARRY4 resources, with 70 compared with 67.

Register mapping also differed, with the Integer Engine using 199 FDRE primitives compared with 159 for the Fixed-Point Engine, while both designs used four FDSE primitives. The Integer Engine additionally required 9 MUXF7 primitives compared with 2 for the Fixed-Point implementation.

These results show that the lower physical LUT count of the Fixed-Point Engine does not result from a uniform reduction across every primitive type. Instead, Vivado mapped the two RTL architectures into different combinations of LUT widths, carry-chain resources, registers, and multiplexers.

### Timing Analysis

Under the same unconstrained routed register-to-register timing methodology, the Integer Arithmetic Engine exhibited a longest reported data-path delay of 4.082 ns, while the Fixed-Point Arithmetic Engine exhibited 4.378 ns, a difference of 0.296 ns or 7.25% relative to the Integer implementation.

The difference was primarily associated with routing rather than logic delay. The Fixed-Point path contained slightly less logic delay, at 1.941 ns versus 1.957 ns, but greater routing delay, at 2.437 ns versus 2.125 ns. This corresponds to a 14.68% increase in routing delay. The Fixed-Point path also traversed six reported logic levels compared with seven for the Integer path.

The longest paths occur in different functional units: the Integer result is associated with the running-product datapath, while the Fixed-Point result occurs within the divider datapath. These measurements therefore characterize the longest reported routed register-to-register paths in each implementation rather than equivalent arithmetic-operation latency.

Because neither design has a defined clock constraint and both reports show an unconstrained path group, maximum clock frequency, timing closure, and an overall engine speed advantage are not claimed.

### Power Analysis

Vivado estimated total on-chip power of 16.077 W for the Integer Arithmetic Engine and 12.463 W for the Fixed-Point Arithmetic Engine, corresponding numerically to a 22.48% lower estimate for the Fixed-Point implementation.

The total-power difference was dominated by estimated I/O power, which decreased from 9.675 W to 5.900 W. I/O represented approximately 60.18% of the Integer estimate and 47.34% of the Fixed-Point estimate. In contrast, the Fixed-Point implementation showed slightly higher estimated slice-logic power, at 3.448 W versus 3.293 W, and signal power, at 2.930 W versus 2.818 W. The lower total estimate therefore should not be attributed simply to the Fixed-Point Engine's lower LUT and register counts.

The power estimates have Low overall confidence. Neither analysis used simulation-derived activity data, clock and I/O activity had Low confidence, and neither implementation contained a defined clock constraint. The reported values are therefore treated as Vivado implementation-level estimates under the specified assumptions rather than measured board-level power consumption.

### Overall Comparison

For these specific RTL implementations on the Artix-7 XC7A35T, the Fixed-Point Arithmetic Engine produced a smaller implemented resource footprint, using 10.79% fewer LUTs, 10.06% fewer slices, and 19.70% fewer registers than the Integer Arithmetic Engine. The primitive-level results further show that this reduction was accompanied by a different FPGA mapping rather than a uniform decrease in every primitive category.

The timing results present a different tradeoff. The Fixed-Point implementation's longest reported register-to-register path was 7.25% longer, despite containing slightly less logic delay and one fewer reported logic level. The increase was primarily associated with routing delay, illustrating that RTL complexity and logic depth alone do not determine the final routed path delay on an FPGA.

Vivado also produced a 22.48% lower total power estimate for the Fixed-Point implementation, but this difference was dominated by estimated I/O power and was generated with Low overall confidence. It is therefore not interpreted as a measured power-efficiency advantage.

Overall, the comparison demonstrates that arithmetic representation alone does not determine FPGA implementation cost. For these two engine architectures, synthesis, LUT packing, register requirements, primitive mapping, placement, routing, and modeled switching activity collectively determined the resulting resource, timing, and power characteristics. The conclusions are therefore specific to these RTL implementations, the Vivado 2026.1 tool flow, and the Artix-7 XC7A35T target used in this project.

## Analysis Limitations

- The Integer and Fixed-Point designs are complete arithmetic engines rather than isolated implementations of a single arithmetic operation, so architectural differences between their internal modules contribute to the results.
- The two engines do not contain an identical set of RTL modules; for example, the Integer Engine includes a separate wide-accumulator implementation.
- Timing measurements use unconstrained routed register-to-register paths. They do not establish maximum clock frequency, timing closure, or equivalent operation latency.
- The longest reported timing paths occur in different functional units and therefore should not be interpreted as a direct operation-to-operation speed comparison.
- Vivado power results have Low overall confidence and do not use simulation-derived switching activity. They should not be interpreted as measured hardware power consumption.
- The power comparison is strongly influenced by modeled I/O activity.
- The results apply to the specific RTL implementations, Vivado 2026.1 flow, and Artix-7 XC7A35T device used in this experiment and should not be generalized to all integer and fixed-point arithmetic architectures.
