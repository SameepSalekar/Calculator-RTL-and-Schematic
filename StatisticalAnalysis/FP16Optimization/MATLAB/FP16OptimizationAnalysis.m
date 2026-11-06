
%% FP16OptimizationAnalysis.m
% Analyze verified routed FP16 resource usage across three revisions.
% Prerequisite: run FP16OptimizationData.m to create both CSV datasets.
% Timing and power are intentionally excluded: stage-equivalent measurements
% are not yet established.

clear; clc; close all;

scriptDir = fileparts(mfilename('fullpath'));
projectDir = fileparts(scriptDir);
dataDir = fullfile(projectDir, 'DATA');
resultsDir = fullfile(projectDir, 'Results');
figuresDir = fullfile(resultsDir, 'Figures');
if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end
if ~exist(figuresDir, 'dir'), mkdir(figuresDir); end

measurementsPath = fullfile(dataDir, 'FP16Optimization_Data.csv');
ratesPath = fullfile(dataDir, 'FP16Optimization_RatesOfChange.csv');
if ~isfile(measurementsPath) || ~isfile(ratesPath)
    error('Missing CSV input. Run FP16OptimizationData.m first.');
end

data = readtable(measurementsPath, 'TextType', 'string');
rates = readtable(ratesPath, 'TextType', 'string');
expectedStages = ["Original"; "Revised"; "Optimized"];
assert(height(data) == 3 && isequal(string(data.Stage), expectedStages), ...
    'CSV must contain Original, Revised, Optimized in that order.');

stageNames = cellstr(data.Stage);
x = 1:3;

%% Figure 1: Resource utilization (absolute counts)
f = figure('Color','w', 'Position',[100 100 900 500]);
bar(x, [data.ImplementedLUTs data.OccupiedSlices], 'grouped');
set(gca,'XTick',x,'XTickLabel',stageNames);
ylabel('FPGA resources (count)');
title('FP16 Resource Utilization');
legend('Implemented LUTs','Occupied slices','Location','northeast');
grid on;
saveFigure(f, figuresDir, 'Resource_Utilization.png');

%% Figure 2: Selected mapped primitives
f = figure('Color','w', 'Position',[100 100 900 500]);
bar(x, [data.LUT6 data.LUT5 data.CARRY4], 'grouped');
set(gca,'XTick',x,'XTickLabel',stageNames);
ylabel('Primitive count');
title('FP16 Primitive Composition');
legend('LUT6','LUT5','CARRY4','Location','northeast');
grid on;
saveFigure(f, figuresDir, 'Primitive_Composition.png');

%% Figure 3: Register classification
f = figure('Color','w', 'Position',[100 100 900 500]);
bar(x, [data.FlipFlops data.Latches], 'stacked');
set(gca,'XTick',x,'XTickLabel',stageNames);
ylabel('Register count');
title('FP16 Register Classification');
legend('Flip-flops','Latches','Location','northeast');
grid on;
saveFigure(f, figuresDir, 'Register_Classification.png');

%% Figure 4: Optimization progress (absolute reductions vs original)
f = figure('Color','w', 'Position',[100 100 900 500]);
plot(x, data.ImplementedLUTs(1) - data.ImplementedLUTs, '-o', ...
    'LineWidth',2,'MarkerSize',8); hold on;
plot(x, data.OccupiedSlices(1) - data.OccupiedSlices, '-s', ...
    'LineWidth',2,'MarkerSize',8);
set(gca,'XTick',x,'XTickLabel',stageNames);
ylabel('Resources saved relative to original (count)');
title('FP16 Optimization Progress');
legend('LUTs saved','Slices saved','Location','northwest');
grid on;
saveFigure(f, figuresDir, 'Optimization_Progress.png');

%% Figure 5: Resource progression line graph (absolute counts)
f = figure('Color','w', 'Position',[100 100 900 500]);
plot(x, data.ImplementedLUTs, '-o','LineWidth',2,'MarkerSize',8); hold on;
plot(x, data.OccupiedSlices, '-s','LineWidth',2,'MarkerSize',8);
set(gca,'XTick',x,'XTickLabel',stageNames);
ylabel('Resources used (count)');
title('FP16 Resource Progression');
legend('Implemented LUTs','Occupied slices','Location','northeast');
grid on;
saveFigure(f, figuresDir, 'Resource_Progression_LineGraph.png');

%% Figure 6: Percentage change per development transition
% Only plot metrics that have an informative resource trend.
metricsToPlot = ["ImplementedLUTs", "OccupiedSlices", "CARRY4"];
transitionNames = {'Original to Revised','Revised to Optimized'};
changeMatrix = nan(2,numel(metricsToPlot));
for k = 1:numel(metricsToPlot)
    idx = find(rates.Metric == metricsToPlot(k), 1);
    if isempty(idx), error('Missing rate metric: %s',metricsToPlot(k)); end
    changeMatrix(:,k) = [rates.OriginalToRevisedPct(idx); ...
                         rates.RevisedToOptimizedPct(idx)];
end
f = figure('Color','w', 'Position',[100 100 1000 500]);
plot(1:2,changeMatrix(:,1),'-o','LineWidth',2,'MarkerSize',8); hold on;
plot(1:2,changeMatrix(:,2),'-s','LineWidth',2,'MarkerSize',8);
plot(1:2,changeMatrix(:,3),'-^','LineWidth',2,'MarkerSize',8);
yline(0,'--');
set(gca,'XTick',1:2,'XTickLabel',transitionNames);
xlim([0.8 2.2]);
ylabel('Change from preceding stage (%)');
title('FP16 Stage-to-Stage Rates of Change');
legend('Implemented LUTs','Occupied slices','CARRY4','Location','best');
grid on;
saveFigure(f, figuresDir, 'RatesOfChange_LineGraph.png');

%% Figure 7: Normalized line graph, 100% = original
f = figure('Color','w', 'Position',[100 100 900 500]);
plot(x,100*data.ImplementedLUTs/data.ImplementedLUTs(1), ...
    '-o','LineWidth',2,'MarkerSize',8); hold on;
plot(x,100*data.OccupiedSlices/data.OccupiedSlices(1), ...
    '-s','LineWidth',2,'MarkerSize',8);
plot(x,100*data.SliceRegisters/data.SliceRegisters(1), ...
    '-^','LineWidth',2,'MarkerSize',8);
set(gca,'XTick',x,'XTickLabel',stageNames);
ylabel('Original baseline (%)');
title('FP16 Normalized Resource Progression');
legend('Implemented LUTs','Occupied slices','Slice registers','Location','southwest');
grid on;
saveFigure(f, figuresDir, 'Normalized_Resource_LineGraph.png');

%% Results report
resultsPath = fullfile(resultsDir, 'FP16Optimization_Results.txt');
fid = fopen(resultsPath, 'w');
if fid < 0, error('Could not open results file for writing.'); end
cleanupObj = onCleanup(@() fclose(fid));
fprintf(fid,'FP16 ARITHMETIC ENGINE: OPTIMIZATION ANALYSIS\n');
fprintf(fid,'============================================\n');
fprintf(fid,'Target: Xilinx Artix-7 xc7a35tcpg236-1\n');
fprintf(fid,'Tool: Vivado 2026.1\n');
fprintf(fid,'Source: routed implementation utilization reports\n');
fprintf(fid,'Stages: Original -> Revised -> Optimized\n\n');

fprintf(fid,'IMPLEMENTED RESOURCE COUNTS\n');
fprintf(fid,'%-22s %12s %12s %12s\n','Metric','Original','Revised','Optimized');
metricNames = data.Properties.VariableNames(2:end);
for k = 1:numel(metricNames)
    v = data.(metricNames{k});
    fprintf(fid,'%-22s %12d %12d %12d\n',metricNames{k},v(1),v(2),v(3));
end

fprintf(fid,'\nPERCENTAGE CHANGE (NEGATIVE = DECREASE)\n');
fprintf(fid,'%-22s %16s %16s %16s\n','Metric','Orig->Rev','Rev->Opt','Orig->Opt');
for k = 1:height(rates)
    fprintf(fid,'%-22s %15.2f%% %15.2f%% %15.2f%%\n', ...
        char(rates.Metric(k)),rates.OriginalToRevisedPct(k), ...
        rates.RevisedToOptimizedPct(k),rates.OriginalToOptimizedPct(k));
end

lutReduction = 100*(data.ImplementedLUTs(1)-data.ImplementedLUTs(3))/data.ImplementedLUTs(1);
sliceReduction = 100*(data.OccupiedSlices(1)-data.OccupiedSlices(3))/data.OccupiedSlices(1);
fprintf(fid,'\nENGINEERING OBSERVATIONS\n');
fprintf(fid,'- Implemented LUT reduction: %.2f%% (%d fewer LUTs).\n', ...
    lutReduction,data.ImplementedLUTs(1)-data.ImplementedLUTs(3));
fprintf(fid,'- Occupied slice reduction: %.2f%% (%d fewer slices).\n', ...
    sliceReduction,data.OccupiedSlices(1)-data.OccupiedSlices(3));
fprintf(fid,'- Original to revised: 20 inferred latches eliminated.\n');
fprintf(fid,'- Total slice registers remain at 446 in every stage.\n');
fprintf(fid,'- DSP48E1 usage remains at 2; CARRY4 usage increases from 173 to 178.\n');
fprintf(fid,'\nLIMITATIONS\n');
fprintf(fid,'- Stages are discrete design revisions, not equal time intervals.\n');
fprintf(fid,'- Percentage change from a zero baseline is undefined (NaN).\n');
fprintf(fid,'- Timing and power are excluded until comparable stage reports are verified.\n');
fprintf(fid,'- Resource changes alone do not establish functional equivalence.\n');
fprintf(fid,'- Stage changes may reflect RTL changes and implementation effects.\n');

fprintf('Saved results to %s\n',resultsPath);
fprintf('Saved 7 figures to %s\n',figuresDir);

%% Local helper
function saveFigure(fig,folder,fileName)
    exportgraphics(fig,fullfile(folder,fileName),'Resolution',200);
    close(fig);
end
