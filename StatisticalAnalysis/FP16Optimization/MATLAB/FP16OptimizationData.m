%% FP16OptimizationData.m
% Generate verified FPGA resource datasets for three FP16 development stages.
% Target: Xilinx Artix-7 xc7a35tcpg236-1; Vivado 2026.1.
% Source: routed implementation utilization reports for each stage.
% Run this script before FP16OptimizationAnalysis.m.

clear; clc;

scriptDir = fileparts(mfilename('fullpath'));
projectDir = fileparts(scriptDir);
dataDir = fullfile(projectDir, 'DATA');
if ~exist(dataDir, 'dir'), mkdir(dataDir); end

Stage = ["Original"; "Revised"; "Optimized"];
ImplementedLUTs = [3638; 3637; 3163];
OccupiedSlices = [1078; 1066; 919];
SliceRegisters = [446; 446; 446];
FlipFlops = [426; 446; 446];
Latches = [20; 0; 0];
LUT6 = [1784; 1784; 1571];
LUT5 = [1003; 1003; 755];
CARRY4 = [173; 173; 178];
DSP48E1 = [2; 2; 2];

measurements = table(Stage, ImplementedLUTs, OccupiedSlices, ...
    SliceRegisters, FlipFlops, Latches, LUT6, LUT5, CARRY4, DSP48E1);
writetable(measurements, fullfile(dataDir, 'FP16Optimization_Data.csv'));

metricNames = measurements.Properties.VariableNames(2:end);
metricCount = numel(metricNames);
Metric = strings(metricCount, 1);
OriginalToRevisedPct = nan(metricCount, 1);
RevisedToOptimizedPct = nan(metricCount, 1);
OriginalToOptimizedPct = nan(metricCount, 1);

for k = 1:metricCount
    Metric(k) = string(metricNames{k});
    values = measurements.(metricNames{k});
    OriginalToRevisedPct(k) = percentChange(values(1), values(2));
    RevisedToOptimizedPct(k) = percentChange(values(2), values(3));
    OriginalToOptimizedPct(k) = percentChange(values(1), values(3));
end

rates = table(Metric, OriginalToRevisedPct, RevisedToOptimizedPct, ...
    OriginalToOptimizedPct);
writetable(rates, fullfile(dataDir, 'FP16Optimization_RatesOfChange.csv'));

fprintf('Created %s\n', fullfile(dataDir, 'FP16Optimization_Data.csv'));
fprintf('Created %s\n', fullfile(dataDir, 'FP16Optimization_RatesOfChange.csv'));

%% Local helper
function pct = percentChange(previous, current)
    % Percentage change is undefined if the previous value is zero.
    if previous == 0
        pct = NaN;
    else
        pct = 100 * (current - previous) / previous;
    end
end
