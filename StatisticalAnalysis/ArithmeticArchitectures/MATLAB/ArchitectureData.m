%% ArchitectureData.m
% Comparative hardware measurement dataset for:
%
%   1. IntegerArithmeticEngine       (8-bit)
%   2. FixedPointArithmeticEngine    (8-bit)
%   3. FP16ArithmeticEngine          (16-bit, optimized)
%
% Data Sources:
%   Integer and Fixed-Point:
%       Integer_vs_FixedPointEngine study
%
%   Optimized FP16:
%       Vivado 2026.1 synthesis, implementation,
%       timing, and power reports
%
% Output:
%   ArithmeticArchitecture_Data.csv
%
% Notes:
%   - Resource measurements are obtained from Vivado reports.
%   - Timing and power measurements use different constraints
%     and estimation conditions across the studies.
%   - Missing or non-exact measurements are represented by NaN.
%   - NaN values must not be interpreted as zero.

clear;
clc;

%% 1. Define measurement names

Metric = [
    "Synthesis LUTs"
    "Implementation LUTs"
    "Implementation Slices"
    "Registers"
    "F7 Muxes"
    "DSPs"
    "Bonded IOBs"
    "BUFGCTRL"
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
    "Longest Register-to-Register Path"
    "Logic Delay"
    "Routing Delay"
    "Logic Levels"
    "Total On-Chip Power"
    "Dynamic Power"
    "Device Static Power"
    "Slice Logic Power"
    "Signal Power"
    "IO Power"
    "BUFG Power"
    "Clock Period"
    "Worst Negative Slack"
    "Worst Hold Slack"
];

%% 2. Define measurement categories

% Resource metrics:   1-8
% Primitive metrics:  9-18
% Timing metrics:     19-22 and 30-32
% Power metrics:      23-29

Category = [
    repmat("Resource", 8, 1)
    repmat("Primitive", 10, 1)
    repmat("Timing", 4, 1)
    repmat("Power", 7, 1)
    repmat("Timing", 3, 1)
];

%% 3. Define measurement units

% Initialize all measurements as resource counts.
% Timing and power units are then assigned separately.

numberOfMetrics = numel(Metric);

Unit = repmat("count", numberOfMetrics, 1);

% Timing measurements expressed in nanoseconds.

timingIndices = [19, 20, 21, 30, 31, 32];

Unit(timingIndices) = "ns";

% Power measurements expressed in watts.

powerIndices = 23:29;

Unit(powerIndices) = "W";

%% 4. IntegerArithmeticEngine measurements

% Architecture:
%   8-bit integer arithmetic
%
% Timing:
%   Unconstrained routed register-to-register path
%
% Power:
%   Vivado estimation without simulation-derived switching activity

Integer = [
    588       % Synthesis LUTs
    584       % Implementation LUTs
    179       % Implementation Slices
    203       % Registers
    9         % F7 Muxes
    0         % DSPs
    51        % Bonded IOBs
    1         % BUFGCTRL
    248       % LUT6
    78        % LUT5
    67        % LUT4
    104       % LUT3
    100       % LUT2
    75        % LUT1
    67        % CARRY4
    199       % FDRE
    4         % FDSE
    9         % MUXF7
    4.082     % Longest Register-to-Register Path (ns)
    1.957     % Logic Delay (ns)
    2.125     % Routing Delay (ns)
    7         % Logic Levels
    16.077    % Total On-Chip Power (W)
    15.785    % Dynamic Power (W)
    0.292     % Device Static Power (W)
    3.293     % Slice Logic Power (W)
    2.818     % Signal Power (W)
    9.675     % IO Power (W)
    0.006     % BUFG Power (W)
    NaN       % Clock Period (ns)
    NaN       % Worst Negative Slack (ns)
    NaN       % Worst Hold Slack (ns)
];

%% 5. FixedPointArithmeticEngine measurements

% Architecture:
%   8-bit fixed-point arithmetic
%
% Timing:
%   Unconstrained routed register-to-register path
%
% Power:
%   Vivado estimation without simulation-derived switching activity

FixedPoint = [
    527       % Synthesis LUTs
    521       % Implementation LUTs
    161       % Implementation Slices
    163       % Registers
    2         % F7 Muxes
    0         % DSPs
    51        % Bonded IOBs
    1         % BUFGCTRL
    161       % LUT6
    85        % LUT5
    97        % LUT4
    121       % LUT3
    105       % LUT2
    71        % LUT1
    70        % CARRY4
    159       % FDRE
    4         % FDSE
    2         % MUXF7
    4.378     % Longest Register-to-Register Path (ns)
    1.941     % Logic Delay (ns)
    2.437     % Routing Delay (ns)
    6         % Logic Levels
    12.463    % Total On-Chip Power (W)
    12.279    % Dynamic Power (W)
    0.185     % Device Static Power (W)
    3.448     % Slice Logic Power (W)
    2.930     % Signal Power (W)
    5.900     % IO Power (W)
    0.006     % BUFG Power (W)
    NaN       % Clock Period (ns)
    NaN       % Worst Negative Slack (ns)
    NaN       % Worst Hold Slack (ns)
];

%% 6. Optimized FP16ArithmeticEngine measurements

% Architecture:
%   IEEE 754 half-precision floating-point arithmetic
%
% Optimization:
%   Leading-zero detection and variable-shift normalization
%
% Timing:
%   Post-implementation timing with a 40 ns clock constraint
%
% Power:
%   Vivado estimated power with low confidence
%
% Notes:
%   - Timing measurements are from the worst-slack setup path.
%   - Clock power is reported as less than 0.001 W.
%   - NaN is used for clock power because its exact
%     numerical value is not reported.

FP16 = [
    3223      % Synthesis LUTs
    3163      % Implementation LUTs
    919       % Implementation Slices
    446       % Registers
    5         % F7 Muxes
    2         % DSPs
    104       % Bonded IOBs
    1         % BUFGCTRL
    1571      % LUT6
    755       % LUT5
    603       % LUT4
    551       % LUT3
    405       % LUT2
    2         % LUT1
    178       % CARRY4
    442       % FDRE
    4         % FDSE
    5         % MUXF7
    39.571    % Longest reported setup data-path delay (ns)
    13.101    % Logic Delay (ns)
    26.470    % Routing Delay (ns)
    56        % Logic Levels
    0.087     % Total On-Chip Power (W)
    0.017     % Dynamic Power (W)
    0.070     % Device Static Power (W)
    0.006     % Slice Logic Power (W)
    0.006     % Signal Power (W)
    0.003     % IO Power (W)
    NaN       % BUFG/Clock Power (<0.001 W)
    40.000    % Clock Period (ns)
    0.367     % Worst Negative Slack (ns)
    0.123     % Worst Hold Slack (ns)
];

%% 7. Validate dataset dimensions

% Verify that all arrays contain the same number of entries.

assert( ...
    numel(Category) == numberOfMetrics, ...
    'Category and Metric dimensions do not match.' ...
);

assert( ...
    numel(Unit) == numberOfMetrics, ...
    'Unit and Metric dimensions do not match.' ...
);

assert( ...
    numel(Integer) == numberOfMetrics, ...
    'Integer measurements are incomplete.' ...
);

assert( ...
    numel(FixedPoint) == numberOfMetrics, ...
    'Fixed-Point measurements are incomplete.' ...
);

assert( ...
    numel(FP16) == numberOfMetrics, ...
    'FP16 measurements are incomplete.' ...
);

% Ensure all arrays are column vectors.

Category = Category(:);
Metric = Metric(:);
Unit = Unit(:);

Integer = Integer(:);
FixedPoint = FixedPoint(:);
FP16 = FP16(:);

% Check for duplicate measurement names.

assert( ...
    numel(unique(Metric)) == numberOfMetrics, ...
    'Duplicate measurement names were detected.' ...
);

% Verify that measurements are nonnegative,
% excluding timing slack values, which may be negative.

slackIndices = ismember( ...
    Metric, ...
    ["Worst Negative Slack", "Worst Hold Slack"] ...
);

measurementMatrix = [Integer, FixedPoint, FP16];

nonSlackValues = measurementMatrix(~slackIndices, :);

assert( ...
    all(nonSlackValues(~isnan(nonSlackValues)) >= 0), ...
    'Unexpected negative measurement detected.' ...
);

% Verify that timing breakdowns are internally consistent.

timingPathIndex = Metric == "Longest Register-to-Register Path";
logicDelayIndex = Metric == "Logic Delay";
routingDelayIndex = Metric == "Routing Delay";

pathDelay = measurementMatrix(timingPathIndex, :);
logicDelay = measurementMatrix(logicDelayIndex, :);
routingDelay = measurementMatrix(routingDelayIndex, :);

timingDifference = abs( ...
    pathDelay - (logicDelay + routingDelay) ...
);

assert( ...
    all(timingDifference(~isnan(timingDifference)) < 0.001), ...
    'Timing breakdown does not match the reported path delay.' ...
);

% Verify that total power approximately equals
% dynamic power plus device static power.

totalPowerIndex = Metric == "Total On-Chip Power";
dynamicPowerIndex = Metric == "Dynamic Power";
staticPowerIndex = Metric == "Device Static Power";

totalPower = measurementMatrix(totalPowerIndex, :);
dynamicPower = measurementMatrix(dynamicPowerIndex, :);
staticPower = measurementMatrix(staticPowerIndex, :);

powerDifference = abs( ...
    totalPower - (dynamicPower + staticPower) ...
);

assert( ...
    all(powerDifference(~isnan(powerDifference)) < 0.002), ...
    'Power breakdown does not match total on-chip power.' ...
);

%% 8. Construct hardware comparison table

% Use HardwareData instead of ArchitectureData
% to avoid conflicts with the MATLAB script filename.

HardwareData = table( ...
    Category, ...
    Metric, ...
    Unit, ...
    Integer, ...
    FixedPoint, ...
    FP16 ...
);

%% 9. Export CSV dataset

scriptDirectory = fileparts(mfilename('fullpath'));

projectDirectory = fileparts(scriptDirectory);

dataDirectory = fullfile(projectDirectory, 'DATA');

if ~isfolder(dataDirectory)
    mkdir(dataDirectory);
end

outputFile = fullfile( ...
    dataDirectory, ...
    'ArithmeticArchitecture_Data.csv' ...
);

writetable(HardwareData, outputFile);
%% 10. Display dataset summary

fprintf('\n');

fprintf('ARITHMETIC ARCHITECTURE DATA GENERATION\n');
fprintf('=======================================\n');

fprintf('Architectures: %d\n', 3);
fprintf('Measurements:  %d\n', height(HardwareData));

fprintf('\nMeasurement Categories:\n');

fprintf('  Resource:  %d\n', sum(Category == "Resource"));
fprintf('  Primitive: %d\n', sum(Category == "Primitive"));
fprintf('  Timing:    %d\n', sum(Category == "Timing"));
fprintf('  Power:     %d\n', sum(Category == "Power"));

fprintf('\nAvailable Measurements:\n');

fprintf('  Integer:     %d\n', sum(~isnan(Integer)));
fprintf('  Fixed-Point: %d\n', sum(~isnan(FixedPoint)));
fprintf('  FP16:        %d\n', sum(~isnan(FP16)));

fprintf('\nTiming Verification:\n');

fprintf('  Integer path delay:     %.3f ns\n', pathDelay(1));
fprintf('  Fixed-Point path delay: %.3f ns\n', pathDelay(2));
fprintf('  FP16 setup path delay:  %.3f ns\n', pathDelay(3));

fprintf('\nPower Verification:\n');

fprintf('  Integer total power:     %.3f W\n', totalPower(1));
fprintf('  Fixed-Point total power: %.3f W\n', totalPower(2));
fprintf('  FP16 total power:        %.3f W\n', totalPower(3));

fprintf('\nCSV generated successfully:\n');
fprintf('%s\n', outputFile);

fprintf('\n');