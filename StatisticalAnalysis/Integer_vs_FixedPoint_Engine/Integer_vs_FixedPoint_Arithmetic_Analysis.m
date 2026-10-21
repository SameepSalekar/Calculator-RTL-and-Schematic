%% Integer vs Fixed-Point Arithmetic Engine Analysis
% Quantitative comparison of the Integer Arithmetic Engine and
% Fixed-Point Arithmetic Engine using Vivado implementation results.

clear;
clc;
close all;


%% 1. Import Raw Data

dataFile = "Integer_vs_FixedPoint_Arithmetic_Engine_Data.csv";

data = readtable(dataFile, "TextType", "string");

figuresDir = fullfile(pwd, "Figures");

if ~isfolder(figuresDir)
    mkdir(figuresDir);
end

getMetric = @(name) data(data.Metric == name, :);


%% 2. Resource Utilization Analysis

synthLUTs = getMetric("Synthesis LUTs");
implLUTs  = getMetric("Implementation LUTs");
slices    = getMetric("Implementation Slices");
registers = getMetric("Registers");
f7Muxes   = getMetric("F7 Muxes");

% Fixed-Point minus Integer
lutDifference = implLUTs.FixedPoint - implLUTs.Integer;
lutPercentChange = ...
    (lutDifference / implLUTs.Integer) * 100;

sliceDifference = slices.FixedPoint - slices.Integer;
slicePercentChange = ...
    (sliceDifference / slices.Integer) * 100;

registerDifference = registers.FixedPoint - registers.Integer;
registerPercentChange = ...
    (registerDifference / registers.Integer) * 100;

f7Difference = f7Muxes.FixedPoint - f7Muxes.Integer;
f7PercentChange = ...
    (f7Difference / f7Muxes.Integer) * 100;

% Synthesis-to-implementation LUT changes
integerSynthToImplDifference = ...
    implLUTs.Integer - synthLUTs.Integer;

integerSynthToImplPercent = ...
    (integerSynthToImplDifference / synthLUTs.Integer) * 100;

fixedSynthToImplDifference = ...
    implLUTs.FixedPoint - synthLUTs.FixedPoint;

fixedSynthToImplPercent = ...
    (fixedSynthToImplDifference / synthLUTs.FixedPoint) * 100;


%% 3. Primitive-Level Analysis

lut6   = getMetric("LUT6");
lut5   = getMetric("LUT5");
lut4   = getMetric("LUT4");
lut3   = getMetric("LUT3");
lut2   = getMetric("LUT2");
lut1   = getMetric("LUT1");
carry4 = getMetric("CARRY4");
fdre   = getMetric("FDRE");
fdse   = getMetric("FDSE");
muxf7  = getMetric("MUXF7");

lut6Difference = lut6.FixedPoint - lut6.Integer;
lut6PercentChange = ...
    (lut6Difference / lut6.Integer) * 100;

lut5Difference = lut5.FixedPoint - lut5.Integer;
lut5PercentChange = ...
    (lut5Difference / lut5.Integer) * 100;

lut4Difference = lut4.FixedPoint - lut4.Integer;
lut4PercentChange = ...
    (lut4Difference / lut4.Integer) * 100;

lut3Difference = lut3.FixedPoint - lut3.Integer;
lut3PercentChange = ...
    (lut3Difference / lut3.Integer) * 100;

lut2Difference = lut2.FixedPoint - lut2.Integer;
lut2PercentChange = ...
    (lut2Difference / lut2.Integer) * 100;

lut1Difference = lut1.FixedPoint - lut1.Integer;
lut1PercentChange = ...
    (lut1Difference / lut1.Integer) * 100;

carry4Difference = carry4.FixedPoint - carry4.Integer;
carry4PercentChange = ...
    (carry4Difference / carry4.Integer) * 100;

fdreDifference = fdre.FixedPoint - fdre.Integer;
fdrePercentChange = ...
    (fdreDifference / fdre.Integer) * 100;

fdseDifference = fdse.FixedPoint - fdse.Integer;

muxf7Difference = muxf7.FixedPoint - muxf7.Integer;
muxf7PercentChange = ...
    (muxf7Difference / muxf7.Integer) * 100;


%% 4. Timing Analysis

totalPath    = getMetric("Longest Register-to-Register Path");
logicDelay   = getMetric("Logic Delay");
routingDelay = getMetric("Routing Delay");
logicLevels  = getMetric("Logic Levels");

pathDifference = ...
    totalPath.FixedPoint - totalPath.Integer;

pathPercentChange = ...
    (pathDifference / totalPath.Integer) * 100;

logicDifference = ...
    logicDelay.FixedPoint - logicDelay.Integer;

logicPercentChange = ...
    (logicDifference / logicDelay.Integer) * 100;

routingDifference = ...
    routingDelay.FixedPoint - routingDelay.Integer;

routingPercentChange = ...
    (routingDifference / routingDelay.Integer) * 100;


%% 5. Power Analysis

totalPower   = getMetric("Total On-Chip Power");
dynamicPower = getMetric("Dynamic Power");
staticPower  = getMetric("Device Static Power");
slicePower   = getMetric("Slice Logic Power");
signalPower  = getMetric("Signal Power");
ioPower      = getMetric("IO Power");
bufgPower    = getMetric("BUFG Power");

totalPowerDifference = ...
    totalPower.FixedPoint - totalPower.Integer;

totalPowerPercentChange = ...
    (totalPowerDifference / totalPower.Integer) * 100;

dynamicPowerDifference = ...
    dynamicPower.FixedPoint - dynamicPower.Integer;

dynamicPowerPercentChange = ...
    (dynamicPowerDifference / dynamicPower.Integer) * 100;

staticPowerDifference = ...
    staticPower.FixedPoint - staticPower.Integer;

staticPowerPercentChange = ...
    (staticPowerDifference / staticPower.Integer) * 100;

slicePowerDifference = ...
    slicePower.FixedPoint - slicePower.Integer;

slicePowerPercentChange = ...
    (slicePowerDifference / slicePower.Integer) * 100;

signalPowerDifference = ...
    signalPower.FixedPoint - signalPower.Integer;

signalPowerPercentChange = ...
    (signalPowerDifference / signalPower.Integer) * 100;

ioPowerDifference = ...
    ioPower.FixedPoint - ioPower.Integer;

ioPowerPercentChange = ...
    (ioPowerDifference / ioPower.Integer) * 100;

integerIOFraction = ...
    (ioPower.Integer / totalPower.Integer) * 100;

fixedIOFraction = ...
    (ioPower.FixedPoint / totalPower.FixedPoint) * 100;


%% 6. Generate Resource Utilization Figure

resourceNames = [
    "LUTs"
    "Slices"
    "Registers"
    "F7 Muxes"
];

integerResources = [
    implLUTs.Integer
    slices.Integer
    registers.Integer
    f7Muxes.Integer
];

fixedResources = [
    implLUTs.FixedPoint
    slices.FixedPoint
    registers.FixedPoint
    f7Muxes.FixedPoint
];

figure;

bar([integerResources fixedResources]);

grid on;

title("Integer vs Fixed-Point Resource Utilization");
ylabel("Resource Count");

xticks(1:length(resourceNames));
xticklabels(resourceNames);

legend( ...
    "Integer", ...
    "Fixed-Point", ...
    "Location", ...
    "best");

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Resource_Utilization.png"), ...
    "Resolution", ...
    300);


%% 7. Generate Primitive Composition Figure

primitiveNames = [
    "LUT6"
    "LUT5"
    "LUT4"
    "LUT3"
    "LUT2"
    "LUT1"
    "CARRY4"
    "FDRE"
    "FDSE"
    "MUXF7"
];

integerPrimitives = [
    lut6.Integer
    lut5.Integer
    lut4.Integer
    lut3.Integer
    lut2.Integer
    lut1.Integer
    carry4.Integer
    fdre.Integer
    fdse.Integer
    muxf7.Integer
];

fixedPrimitives = [
    lut6.FixedPoint
    lut5.FixedPoint
    lut4.FixedPoint
    lut3.FixedPoint
    lut2.FixedPoint
    lut1.FixedPoint
    carry4.FixedPoint
    fdre.FixedPoint
    fdse.FixedPoint
    muxf7.FixedPoint
];

figure;

bar([integerPrimitives fixedPrimitives]);

grid on;

title("Integer vs Fixed-Point Primitive Composition");
ylabel("Primitive Count");

xticks(1:length(primitiveNames));
xticklabels(primitiveNames);
xtickangle(45);

legend( ...
    "Integer", ...
    "Fixed-Point", ...
    "Location", ...
    "best");

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Primitive_Composition.png"), ...
    "Resolution", ...
    300);


%% 8. Generate Timing Breakdown Figure

timingNames = [
    "Logic Delay"
    "Routing Delay"
    "Total Path"
];

integerTiming = [
    logicDelay.Integer
    routingDelay.Integer
    totalPath.Integer
];

fixedTiming = [
    logicDelay.FixedPoint
    routingDelay.FixedPoint
    totalPath.FixedPoint
];

figure;

bar([integerTiming fixedTiming]);

grid on;

title("Routed Register-to-Register Timing Comparison");
ylabel("Delay (ns)");

xticks(1:length(timingNames));
xticklabels(timingNames);

legend( ...
    "Integer", ...
    "Fixed-Point", ...
    "Location", ...
    "best");

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Timing_Breakdown.png"), ...
    "Resolution", ...
    300);


%% 9. Generate Power Breakdown Figure

powerNames = [
    "Slice Logic"
    "Signals"
    "I/O"
    "Static"
];

integerPower = [
    slicePower.Integer
    signalPower.Integer
    ioPower.Integer
    staticPower.Integer
];

fixedPower = [
    slicePower.FixedPoint
    signalPower.FixedPoint
    ioPower.FixedPoint
    staticPower.FixedPoint
];

figure;

bar([integerPower fixedPower]);

grid on;

title("Vivado Estimated Power Breakdown");
ylabel("Estimated Power (W)");

xticks(1:length(powerNames));
xticklabels(powerNames);

legend( ...
    "Integer", ...
    "Fixed-Point", ...
    "Location", ...
    "best");

exportgraphics( ...
    gcf, ...
    fullfile(figuresDir, "Power_Breakdown.png"), ...
    "Resolution", ...
    300);


%% 10. Write Numerical Results File

resultsFile = ...
    "Integer_vs_FixedPoint_Arithmetic_Engine_Results.txt";

fid = fopen(resultsFile, "w");

fprintf(fid, ...
    "INTEGER VS FIXED-POINT ARITHMETIC ENGINE ANALYSIS\n");

fprintf(fid, ...
    "=================================================\n\n");


% Resource utilization
fprintf(fid, "RESOURCE UTILIZATION\n");
fprintf(fid, "--------------------\n");

fprintf(fid, ...
    "Implemented LUTs: Integer = %d, Fixed-Point = %d\n", ...
    implLUTs.Integer, ...
    implLUTs.FixedPoint);

fprintf(fid, ...
    "Difference (Fixed-Point - Integer) = %d (%0.2f%%)\n\n", ...
    lutDifference, ...
    lutPercentChange);

fprintf(fid, ...
    "Implemented slices: Integer = %d, Fixed-Point = %d\n", ...
    slices.Integer, ...
    slices.FixedPoint);

fprintf(fid, ...
    "Difference (Fixed-Point - Integer) = %d (%0.2f%%)\n\n", ...
    sliceDifference, ...
    slicePercentChange);

fprintf(fid, ...
    "Registers: Integer = %d, Fixed-Point = %d\n", ...
    registers.Integer, ...
    registers.FixedPoint);

fprintf(fid, ...
    "Difference (Fixed-Point - Integer) = %d (%0.2f%%)\n\n", ...
    registerDifference, ...
    registerPercentChange);

fprintf(fid, ...
    "F7 Muxes: Integer = %d, Fixed-Point = %d\n", ...
    f7Muxes.Integer, ...
    f7Muxes.FixedPoint);

fprintf(fid, ...
    "Difference (Fixed-Point - Integer) = %d (%0.2f%%)\n\n", ...
    f7Difference, ...
    f7PercentChange);

fprintf(fid, ...
    "Integer synthesis-to-implementation LUT change = %d (%0.2f%%)\n", ...
    integerSynthToImplDifference, ...
    integerSynthToImplPercent);

fprintf(fid, ...
    "Fixed-Point synthesis-to-implementation LUT change = %d (%0.2f%%)\n\n", ...
    fixedSynthToImplDifference, ...
    fixedSynthToImplPercent);


% Primitive mapping
fprintf(fid, "PRIMITIVE MAPPING\n");
fprintf(fid, "-----------------\n");

fprintf(fid, ...
    "LUT6: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    lut6.Integer, lut6.FixedPoint, ...
    lut6Difference, lut6PercentChange);

fprintf(fid, ...
    "LUT5: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    lut5.Integer, lut5.FixedPoint, ...
    lut5Difference, lut5PercentChange);

fprintf(fid, ...
    "LUT4: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    lut4.Integer, lut4.FixedPoint, ...
    lut4Difference, lut4PercentChange);

fprintf(fid, ...
    "LUT3: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    lut3.Integer, lut3.FixedPoint, ...
    lut3Difference, lut3PercentChange);

fprintf(fid, ...
    "LUT2: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    lut2.Integer, lut2.FixedPoint, ...
    lut2Difference, lut2PercentChange);

fprintf(fid, ...
    "LUT1: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    lut1.Integer, lut1.FixedPoint, ...
    lut1Difference, lut1PercentChange);

fprintf(fid, ...
    "CARRY4: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    carry4.Integer, carry4.FixedPoint, ...
    carry4Difference, carry4PercentChange);

fprintf(fid, ...
    "FDRE: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n", ...
    fdre.Integer, fdre.FixedPoint, ...
    fdreDifference, fdrePercentChange);

fprintf(fid, ...
    "FDSE: Integer = %d, Fixed-Point = %d, Change = %d\n", ...
    fdse.Integer, fdse.FixedPoint, ...
    fdseDifference);

fprintf(fid, ...
    "MUXF7: Integer = %d, Fixed-Point = %d, Change = %d (%0.2f%%)\n\n", ...
    muxf7.Integer, muxf7.FixedPoint, ...
    muxf7Difference, muxf7PercentChange);


% Timing
fprintf(fid, "TIMING ANALYSIS\n");
fprintf(fid, "---------------\n");

fprintf(fid, ...
    "Longest reported register-to-register path:\n");

fprintf(fid, ...
    "Integer = %0.3f ns\n", ...
    totalPath.Integer);

fprintf(fid, ...
    "Fixed-Point = %0.3f ns\n", ...
    totalPath.FixedPoint);

fprintf(fid, ...
    "Difference = %0.3f ns (%0.2f%%)\n\n", ...
    pathDifference, ...
    pathPercentChange);

fprintf(fid, ...
    "Logic delay: Integer = %0.3f ns, Fixed-Point = %0.3f ns\n", ...
    logicDelay.Integer, ...
    logicDelay.FixedPoint);

fprintf(fid, ...
    "Logic delay difference = %0.3f ns (%0.2f%%)\n\n", ...
    logicDifference, ...
    logicPercentChange);

fprintf(fid, ...
    "Routing delay: Integer = %0.3f ns, Fixed-Point = %0.3f ns\n", ...
    routingDelay.Integer, ...
    routingDelay.FixedPoint);

fprintf(fid, ...
    "Routing delay difference = %0.3f ns (%0.2f%%)\n\n", ...
    routingDifference, ...
    routingPercentChange);

fprintf(fid, ...
    "Logic levels: Integer = %d, Fixed-Point = %d\n\n", ...
    logicLevels.Integer, ...
    logicLevels.FixedPoint);

fprintf(fid, ...
    "NOTE: Timing values are unconstrained routed register-to-register paths.\n");

fprintf(fid, ...
    "No maximum clock frequency, timing closure, or overall engine speed advantage is claimed.\n\n");


% Power
fprintf(fid, "POWER ANALYSIS\n");
fprintf(fid, "--------------\n");

fprintf(fid, ...
    "Total power: Integer = %0.3f W, Fixed-Point = %0.3f W\n", ...
    totalPower.Integer, ...
    totalPower.FixedPoint);

fprintf(fid, ...
    "Difference = %0.3f W (%0.2f%%)\n\n", ...
    totalPowerDifference, ...
    totalPowerPercentChange);

fprintf(fid, ...
    "Dynamic power change = %0.3f W (%0.2f%%)\n", ...
    dynamicPowerDifference, ...
    dynamicPowerPercentChange);

fprintf(fid, ...
    "Static power change = %0.3f W (%0.2f%%)\n", ...
    staticPowerDifference, ...
    staticPowerPercentChange);

fprintf(fid, ...
    "Slice logic power change = %0.3f W (%0.2f%%)\n", ...
    slicePowerDifference, ...
    slicePowerPercentChange);

fprintf(fid, ...
    "Signal power change = %0.3f W (%0.2f%%)\n", ...
    signalPowerDifference, ...
    signalPowerPercentChange);

fprintf(fid, ...
    "I/O power change = %0.3f W (%0.2f%%)\n\n", ...
    ioPowerDifference, ...
    ioPowerPercentChange);

fprintf(fid, ...
    "Integer I/O fraction of total estimate = %0.2f%%\n", ...
    integerIOFraction);

fprintf(fid, ...
    "Fixed-Point I/O fraction of total estimate = %0.2f%%\n\n", ...
    fixedIOFraction);

fprintf(fid, ...
    "NOTE: Vivado power estimates have Low overall confidence and lack simulation-derived activity data.\n");

fprintf(fid, ...
    "The values are not measured board-level power consumption.\n");

fclose(fid);


%% 11. Console Summary

fprintf("\n");
fprintf("INTEGER VS FIXED-POINT ARITHMETIC ENGINE\n");
fprintf("========================================\n");

fprintf( ...
    "Implemented LUT change: %0.2f%%\n", ...
    lutPercentChange);

fprintf( ...
    "Slice change: %0.2f%%\n", ...
    slicePercentChange);

fprintf( ...
    "Register change: %0.2f%%\n", ...
    registerPercentChange);

fprintf( ...
    "Longest reported path change: %0.2f%%\n", ...
    pathPercentChange);

fprintf( ...
    "Total Vivado power estimate change: %0.2f%%\n", ...
    totalPowerPercentChange);

fprintf("\nAnalysis complete.\n");