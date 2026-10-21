## Engineering Conclusions

The 4-bit ripple-carry and carry-lookahead adder/subtractor implementations produced identical overall FPGA resource utilization after implementation, with both designs requiring 8 LUTs and 2 slices. Neither architecture therefore demonstrated a physical resource-utilization advantage at the evaluated datapath width.

Despite identical physical utilization, the two designs exhibited different logical LUT primitive compositions. This indicates that Vivado mapped the RTL architectures into different underlying Boolean structures while ultimately packing them into the same physical FPGA resource footprint.

The carry-lookahead implementation reduced the logic portion of its reported worst path by approximately 11.25% relative to the ripple-carry implementation. However, its routing delay was approximately 19.34% higher. The additional routing overhead outweighed the reduction in logic delay, resulting in a whole-module worst routed path of 8.456 ns for the CLA compared with 8.178 ns for the RCA, approximately 3.40% higher for this implementation.

The two architectures also produced effectively equivalent Vivado power estimates. Total estimated on-chip power was 6.132 W for the RCA and 6.134 W for the CLA, a difference of only 2 mW, or approximately 0.033%.

Overall, the experiment demonstrates that theoretical architectural differences do not necessarily translate directly into superior implemented FPGA metrics. Synthesis optimization, technology mapping, LUT packing, placement, and routing all influence the final hardware implementation. At this small datapath width, the FPGA implementation process largely equalized the resource cost of the two architectures, while routing effects played a substantial role in the observed timing behavior.

### Limitations

The timing results represent routed combinational input-to-output paths rather than clock-based maximum-frequency measurements. The reported worst paths also terminate at different outputs, so the observed whole-module timing difference should not be interpreted as evidence that ripple-carry architecture is inherently faster than carry-lookahead architecture.

The power values are low-confidence Vivado estimates rather than measured board power. Switching activity was not fully specified, and the estimates were dominated by I/O power. The small estimated power difference therefore should not be interpreted as a significant real-world power advantage for either architecture.

Finally, this comparison evaluates 4-bit implementations on a specific Artix-7 FPGA target. Relative behavior may change with datapath width, FPGA family, synthesis settings, placement, or routing.
