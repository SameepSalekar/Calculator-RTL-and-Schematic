%% Combinational vs Sequential Multiplier Analysis
% Quantitative comparison of two 8-bit multiplier architectures
% implemented on the same Artix-7 FPGA using Vivado.
%
% IMPORTANT:
% The timing measurements represent different architectural quantities:
%   Combinational = worst routed input-to-output propagation delay
%   Sequential    = longest reported register/control path delay
%
% Therefore, these values are NOT treated as equivalent operation
% latencies and are not used to calculate a "speed improvement."
%
% Power values are Vivado estimates under incomplete activity
% information and should not be interpreted as measured board power.

clear;
clc;
close all;

%% 1. Import Raw Data

dataFile = "Combinational_vs_Sequential_Multiplier_Data.csv";

data = readtable(dataFile, "TextType", "string");

fprintf("Dataset loaded successfully.\n");
fprintf("Number of metrics: %d\n\n", height(data));

%% 2. Create Output Directory

figuresDir = fullfile(pwd, "Figures");

if ~isfolder(figuresDir)
    mkdir(figuresDir);
end

fprintf("Figures will be saved to:\n%s\n\n", figuresDir);

%% 3. Helper Function for Extracting Metrics

getMetric = @(name) data(data.Metric == name, :);

%% 4. Resource Utilization Analysis

implLUTs = getMetric("Implementation LUTs");
slices   = getMetric("Implementation Slices");
registers = getMetric("Registers");
iobs     = getMetric("Bonded IOBs");

lutDifference = ...
    implLUTs.Sequential - implLUTs.Combinational;

lutPercentChange = ...
    (lutDifference / implLUTs.Combinational) * 100;

sliceDifference = ...
    slices.Sequential - slices.Combinational;

slicePercentChange = ...
    (sliceDifference / slices.Combinational) * 100;

iobDifference = ...
    iobs.Sequential - iobs.Combinational;

iobPercentChange = ...
    (iobDifference / iobs.Combinational) * 100;

%% 5. Primitive-Level Analysis

carry4 = getMetric("CARRY4");

carryDifference = ...
    carry4.Sequential - carry4.Combinational;

carryPercentChange = ...
    (carryDifference / carry4.Combinational) * 100;

%% 6. Timing Analysis

worstPath = getMetric("Worst Routed Path Delay");
logicDelay = getMetric("Logic Delay");
routingDelay = getMetric("Routing Delay");
logicLevels = getMetric("Logic Levels");
iterations = getMetric("Arithmetic Iterations");

% NOTE:
% No percentage "speed improvement" is calculated here because the
% combinational and sequential timing measurements are fundamentally
% different architectural quantities.

%% 7. Power Analysis

totalPower  = getMetric("Total On-Chip Power");
dynamicPower = getMetric("Dynamic Power");
staticPower = getMetric("Device Static Power");
slicePower  = getMetric("Slice Logic Power");
signalPower = getMetric("Signal Power");
ioPower     = getMetric("IO Power");

totalPowerDifference = ...
    totalPower.Sequential - totalPower.Combinational;

totalPowerPercentChange = ...
    (totalPowerDifference / totalPower.Combinational) * 100;

dynamicPowerDifference = ...
    dynamicPower.Sequential - dynamicPower.Combinational;

dynamicPowerPercentChange = ...
    (dynamicPowerDifference / dynamicPower.Combinational) * 100;

slicePowerPercentChange = ...
    ((slicePower.Sequential - slicePower.Combinational) / ...
    slicePower.Combinational) * 100;

signalPowerPercentChange = ...
    ((signalPower.Sequential - signalPower.Combinational) / ...
    signalPower.Combinational) * 100;

ioPowerPercentChange = ...
    ((ioPower.Sequential - ioPower.Combinational) / ...
    ioPower.Combinational) * 100;

combIOFraction = ...
    (ioPower.Combinational / totalPower.Combinational) * 100;

seqIOFraction = ...
    (ioPower.Sequential / totalPower.Sequential) * 100;

%% 8. Figure — Resource Utilization

resourceNames = categorical( ...
    ["LUTs", "Slices", "Registers", "IOBs"]);

resourceValues = [
    implLUTs.Combinational, implLUTs.Sequential;
    slices.Combinational, slices.Sequential;
    registers.Combinational, registers.Sequential;
    iobs.Combinational, iobs.Sequential
];

figure;

bar(resourceNames, resourceValues);

ylabel("Resource Count");
title("Multiplier Resource Utilization");
legend("Combinational", "Sequential", ...
    "Location", "best");

grid on;

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Resource_Utilization.png"), ...
    "Resolution", 300);

%% 9. Figure — Primitive Composition

primitiveNames = categorical( ...
    ["LUT6", "LUT5", "LUT4", "LUT3", ...
     "LUT2", "LUT1", "CARRY4", "FDRE", "FDSE"]);

primitiveValues = [
    getMetric("LUT6").Combinational, getMetric("LUT6").Sequential;
    getMetric("LUT5").Combinational, getMetric("LUT5").Sequential;
    getMetric("LUT4").Combinational, getMetric("LUT4").Sequential;
    getMetric("LUT3").Combinational, getMetric("LUT3").Sequential;
    getMetric("LUT2").Combinational, getMetric("LUT2").Sequential;
    getMetric("LUT1").Combinational, getMetric("LUT1").Sequential;
    getMetric("CARRY4").Combinational, getMetric("CARRY4").Sequential;
    getMetric("FDRE").Combinational, getMetric("FDRE").Sequential;
    getMetric("FDSE").Combinational, getMetric("FDSE").Sequential
];

figure;

bar(primitiveNames, primitiveValues);

ylabel("Primitive Count");
title("Multiplier Primitive Composition");
legend("Combinational", "Sequential", ...
    "Location", "best");

grid on;

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Primitive_Composition.png"), ...
    "Resolution", 300);

%% 10. Figure — Timing Breakdown

timingNames = categorical( ...
    ["Logic Delay", "Routing Delay", "Total Reported Path"]);

timingValues = [
    logicDelay.Combinational, logicDelay.Sequential;
    routingDelay.Combinational, routingDelay.Sequential;
    worstPath.Combinational, worstPath.Sequential
];

figure;

bar(timingNames, timingValues);

ylabel("Delay (ns)");
title("Routed Timing Breakdown");
legend( ...
    "Combinational Input-to-Output Path", ...
    "Sequential Register/Control Path", ...
    "Location", "best");

grid on;

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Timing_Breakdown.png"), ...
    "Resolution", 300);

%% 11. Figure — Power Breakdown

powerNames = categorical( ...
    ["Slice Logic", "Signals", "I/O", "Static"]);

powerValues = [
    slicePower.Combinational, slicePower.Sequential;
    signalPower.Combinational, signalPower.Sequential;
    ioPower.Combinational, ioPower.Sequential;
    staticPower.Combinational, staticPower.Sequential
];

figure;

bar(powerNames, powerValues);

ylabel("Estimated Power (W)");
title("Vivado Estimated Power Breakdown");
legend("Combinational", "Sequential", ...
    "Location", "best");

grid on;

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Power_Breakdown.png"), ...
    "Resolution", 300);

%% 12. Write Quantitative Results

resultsFile = ...
    "Combinational_vs_Sequential_Multiplier_Results.txt";

fid = fopen(resultsFile, "w");

fprintf(fid, ...
    "COMBINATIONAL VS SEQUENTIAL MULTIPLIER ANALYSIS\n");
fprintf(fid, ...
    "================================================\n\n");

fprintf(fid, "RESOURCE UTILIZATION\n");
fprintf(fid, "--------------------\n");

fprintf(fid, ...
    "Implementation LUTs: %.0f -> %.0f\n", ...
    implLUTs.Combinational, implLUTs.Sequential);

fprintf(fid, ...
    "LUT change: %.0f (%.2f%%)\n", ...
    lutDifference, lutPercentChange);

fprintf(fid, ...
    "Implementation slices: %.0f -> %.0f\n", ...
    slices.Combinational, slices.Sequential);

fprintf(fid, ...
    "Slice change: %.0f (%.2f%%)\n", ...
    sliceDifference, slicePercentChange);

fprintf(fid, ...
    "Registers: %.0f -> %.0f\n", ...
    registers.Combinational, registers.Sequential);

fprintf(fid, ...
    "Bonded IOBs: %.0f -> %.0f\n", ...
    iobs.Combinational, iobs.Sequential);

fprintf(fid, ...
    "IOB change: %.0f (%.2f%%)\n\n", ...
    iobDifference, iobPercentChange);

fprintf(fid, "PRIMITIVE MAPPING\n");
fprintf(fid, "-----------------\n");

fprintf(fid, ...
    "CARRY4: %.0f -> %.0f\n", ...
    carry4.Combinational, carry4.Sequential);

fprintf(fid, ...
    "CARRY4 change: %.0f (%.2f%%)\n\n", ...
    carryDifference, carryPercentChange);

fprintf(fid, "TIMING / LATENCY\n");
fprintf(fid, "----------------\n");

fprintf(fid, ...
    "Combinational worst routed input-to-output path: %.3f ns\n", ...
    worstPath.Combinational);

fprintf(fid, ...
    "  Logic delay: %.3f ns\n", ...
    logicDelay.Combinational);

fprintf(fid, ...
    "  Routing delay: %.3f ns\n", ...
    routingDelay.Combinational);

fprintf(fid, ...
    "  Logic levels: %.0f\n\n", ...
    logicLevels.Combinational);

fprintf(fid, ...
    "Sequential longest reported register/control path: %.3f ns\n", ...
    worstPath.Sequential);

fprintf(fid, ...
    "  Logic delay: %.3f ns\n", ...
    logicDelay.Sequential);

fprintf(fid, ...
    "  Routing delay: %.3f ns\n", ...
    routingDelay.Sequential);

fprintf(fid, ...
    "  Logic levels: %.0f\n", ...
    logicLevels.Sequential);

fprintf(fid, ...
    "  Arithmetic iterations: %.0f\n\n", ...
    iterations.Sequential);

fprintf(fid, ...
    "IMPORTANT: These two timing measurements are not equivalent\n");
fprintf(fid, ...
    "operation-latency measurements. No sequential Fmax or absolute\n");
fprintf(fid, ...
    "operation latency is claimed because no clock constraint was\n");
fprintf(fid, ...
    "defined for the sequential implementation.\n\n");

fprintf(fid, "POWER ESTIMATION\n");
fprintf(fid, "----------------\n");

fprintf(fid, ...
    "Total on-chip power: %.3f W -> %.3f W\n", ...
    totalPower.Combinational, totalPower.Sequential);

fprintf(fid, ...
    "Numerical total-power change: %.3f W (%.2f%%)\n", ...
    totalPowerDifference, totalPowerPercentChange);

fprintf(fid, ...
    "Dynamic power: %.3f W -> %.3f W (%.2f%%)\n", ...
    dynamicPower.Combinational, ...
    dynamicPower.Sequential, ...
    dynamicPowerPercentChange);

fprintf(fid, ...
    "Slice-logic power change: %.2f%%\n", ...
    slicePowerPercentChange);

fprintf(fid, ...
    "Signal power change: %.2f%%\n", ...
    signalPowerPercentChange);

fprintf(fid, ...
    "I/O power change: %.2f%%\n", ...
    ioPowerPercentChange);

fprintf(fid, ...
    "Combinational I/O fraction of total power: %.2f%%\n", ...
    combIOFraction);

fprintf(fid, ...
    "Sequential I/O fraction of total power: %.2f%%\n\n", ...
    seqIOFraction);

fprintf(fid, "POWER LIMITATIONS\n");
fprintf(fid, "-----------------\n");

fprintf(fid, ...
    "Both Vivado power reports have Low overall confidence.\n");
fprintf(fid, ...
    "The estimates are dominated by I/O power and do not use a\n");
fprintf(fid, ...
    "simulation activity file. The sequential design also lacks a\n");
fprintf(fid, ...
    "defined clock constraint. Therefore, the reported wattages are\n");
fprintf(fid, ...
    "implementation estimates under Vivado assumptions, not measured\n");
fprintf(fid, ...
    "board-level power consumption.\n");

fclose(fid);

%% 13. Display Summary

fprintf("\nAnalysis complete.\n\n");

fprintf("Sequential LUT change: %.2f%%\n", ...
    lutPercentChange);

fprintf("Sequential slice change: %.2f%%\n", ...
    slicePercentChange);

fprintf("Sequential CARRY4 change: %.2f%%\n", ...
    carryPercentChange);

fprintf("Numerical total-power change: %.2f%%\n", ...
    totalPowerPercentChange);

fprintf("\nGenerated files:\n");
fprintf("  %s\n", resultsFile);
fprintf("  %s\n", ...
    fullfile(figuresDir, "Resource_Utilization.png"));
fprintf("  %s\n", ...
    fullfile(figuresDir, "Primitive_Composition.png"));
fprintf("  %s\n", ...
    fullfile(figuresDir, "Timing_Breakdown.png"));
fprintf("  %s\n", ...
    fullfile(figuresDir, "Power_Breakdown.png"));