%% CLA vs Ripple-Carry Adder/Subtractor FPGA Analysis
%
% Target FPGA: Xilinx Artix-7 xc7a35tcpg236-1
% Vivado Version: 2026.1
% Datapath Width: 4 bits
%
% This script performs a controlled quantitative comparison between
% carry-lookahead and ripple-carry adder/subtractor implementations.
%
% Both designs expose equivalent top-level functionality and were
% synthesized and implemented for the same FPGA target using the
% same Vivado version.
%
% Analysis includes:
%   1. FPGA resource utilization
%   2. LUT primitive composition
%   3. Routed combinational timing
%   4. Vivado power estimates
%
% All raw numerical values are stored in:
% CLA_vs_RippleCarry_Data.csv

clear;
clc;
close all;

%% 1. Import Vivado Data

scriptDir = fileparts(mfilename('fullpath'));

if isempty(scriptDir)
    scriptDir = pwd;
end

csvFile = fullfile(scriptDir, 'CLA_vs_RippleCarry_Data.csv');

Data = readtable(csvFile, 'TextType', 'string');

disp('CLA vs Ripple-Carry Adder/Subtractor FPGA Analysis');
disp('==================================================');
disp(' ');
disp('Raw Vivado Dataset:');
disp(Data);


%% 2. Extract Analysis Values

% Resource utilization
rcaLUTs   = Data.RCA(Data.Metric == "Implementation LUTs");
claLUTs   = Data.CLA(Data.Metric == "Implementation LUTs");

rcaSlices = Data.RCA(Data.Metric == "Implementation Slices");
claSlices = Data.CLA(Data.Metric == "Implementation Slices");

% Timing
rcaDelay = Data.RCA(Data.Metric == "Worst Routed Path Delay");
claDelay = Data.CLA(Data.Metric == "Worst Routed Path Delay");

rcaLogicDelay = Data.RCA(Data.Metric == "Worst Path Logic Delay");
claLogicDelay = Data.CLA(Data.Metric == "Worst Path Logic Delay");

rcaRoutingDelay = Data.RCA(Data.Metric == "Worst Path Routing Delay");
claRoutingDelay = Data.CLA(Data.Metric == "Worst Path Routing Delay");

% Power
rcaTotalPower = Data.RCA(Data.Metric == "Total On-Chip Power");
claTotalPower = Data.CLA(Data.Metric == "Total On-Chip Power");

rcaDynamicPower = Data.RCA(Data.Metric == "Dynamic Power");
claDynamicPower = Data.CLA(Data.Metric == "Dynamic Power");

rcaStaticPower = Data.RCA(Data.Metric == "Device Static Power");
claStaticPower = Data.CLA(Data.Metric == "Device Static Power");


%% 3. Resource Utilization Calculations

lutDifference = claLUTs - rcaLUTs;
sliceDifference = claSlices - rcaSlices;

if rcaLUTs ~= 0
    lutPercentChange = (lutDifference / rcaLUTs) * 100;
else
    lutPercentChange = NaN;
end

if rcaSlices ~= 0
    slicePercentChange = (sliceDifference / rcaSlices) * 100;
else
    slicePercentChange = NaN;
end



%% 4. Timing Calculations

delayDifference = claDelay - rcaDelay;

delayPercentChange = ...
    (delayDifference / rcaDelay) * 100;

delayRatio = claDelay / rcaDelay;

logicDelayDifference = ...
    claLogicDelay - rcaLogicDelay;

logicDelayPercentChange = ...
    (logicDelayDifference / rcaLogicDelay) * 100;

routingDelayDifference = ...
    claRoutingDelay - rcaRoutingDelay;

routingDelayPercentChange = ...
    (routingDelayDifference / rcaRoutingDelay) * 100;


%% 5. Power Calculations

totalPowerDifference = ...
    claTotalPower - rcaTotalPower;

totalPowerPercentChange = ...
    (totalPowerDifference / rcaTotalPower) * 100;

totalPowerRatio = ...
    claTotalPower / rcaTotalPower;

dynamicPowerDifference = ...
    claDynamicPower - rcaDynamicPower;

staticPowerDifference = ...
    claStaticPower - rcaStaticPower;


%% 6. Display Calculated Results

fprintf('\n');
fprintf('CALCULATED COMPARISON RESULTS\n');
fprintf('=============================\n\n');

fprintf('RESOURCE UTILIZATION\n');
fprintf('--------------------\n');
fprintf('Implemented LUT Difference: %d\n', lutDifference);
fprintf('Implemented LUT Change: %.2f %%\n', lutPercentChange);
fprintf('Implemented Slice Difference: %d\n', sliceDifference);
fprintf('Implemented Slice Change: %.2f %%\n\n', slicePercentChange);

fprintf('TIMING\n');
fprintf('------\n');
fprintf('RCA Worst Routed Delay: %.3f ns\n', rcaDelay);
fprintf('CLA Worst Routed Delay: %.3f ns\n', claDelay);
fprintf('CLA - RCA Delay Difference: %.3f ns\n', delayDifference);
fprintf('CLA Delay Change: %.2f %%\n', delayPercentChange);
fprintf('CLA/RCA Delay Ratio: %.5f\n\n', delayRatio);

fprintf('Logic Delay Difference: %.3f ns\n', logicDelayDifference);
fprintf('CLA Logic Delay Change: %.2f %%\n', logicDelayPercentChange);

fprintf('Routing Delay Difference: %.3f ns\n', routingDelayDifference);
fprintf('CLA Routing Delay Change: %.2f %%\n\n', routingDelayPercentChange);

fprintf('POWER\n');
fprintf('-----\n');
fprintf('RCA Total Power Estimate: %.3f W\n', rcaTotalPower);
fprintf('CLA Total Power Estimate: %.3f W\n', claTotalPower);
fprintf('CLA - RCA Power Difference: %.3f W\n', totalPowerDifference);
fprintf('CLA Total Power Change: %.4f %%\n', totalPowerPercentChange);
fprintf('CLA/RCA Power Ratio: %.5f\n', totalPowerRatio);
fprintf('Dynamic Power Difference: %.3f W\n', dynamicPowerDifference);
fprintf('Static Power Difference: %.3f W\n', staticPowerDifference);

%% 7. Create Figure Output Directory

figuresDir = fullfile(scriptDir, 'Figures');

if ~exist(figuresDir, 'dir')
    mkdir(figuresDir);
end


%% 8. Figure 1 - FPGA Resource Utilization

resourceLabels = ["LUTs", "Slices", "Registers", "DSPs"];

resourceRCA = [
    Data.RCA(Data.Metric == "Implementation LUTs")
    Data.RCA(Data.Metric == "Implementation Slices")
    Data.RCA(Data.Metric == "Registers")
    Data.RCA(Data.Metric == "DSPs")
];

resourceCLA = [
    Data.CLA(Data.Metric == "Implementation LUTs")
    Data.CLA(Data.Metric == "Implementation Slices")
    Data.CLA(Data.Metric == "Registers")
    Data.CLA(Data.Metric == "DSPs")
];

figure('Name', 'FPGA Resource Utilization');
bar([resourceRCA resourceCLA]);

set(gca, 'XTickLabel', resourceLabels);

xlabel('FPGA Resource');
ylabel('Resource Count');
title('FPGA Resource Utilization');

legend('Ripple-Carry', 'Carry-Lookahead', ...
       'Location', 'best');

grid on;

drawnow;

exportgraphics(gca, ...
    fullfile(figuresDir, 'Resource_Utilization.png'), ...
    'Resolution', 300);
%% 9. Figure 2 - LUT Primitive Composition

primitiveLabels = ["LUT6", "LUT5", "LUT4", "LUT3", "LUT2"];

primitiveRCA = [
    Data.RCA(Data.Metric == "LUT6")
    Data.RCA(Data.Metric == "LUT5")
    Data.RCA(Data.Metric == "LUT4")
    Data.RCA(Data.Metric == "LUT3")
    Data.RCA(Data.Metric == "LUT2")
];

primitiveCLA = [
    Data.CLA(Data.Metric == "LUT6")
    Data.CLA(Data.Metric == "LUT5")
    Data.CLA(Data.Metric == "LUT4")
    Data.CLA(Data.Metric == "LUT3")
    Data.CLA(Data.Metric == "LUT2")
];

figure('Name', 'LUT Primitive Composition');

bar([primitiveRCA primitiveCLA]);

set(gca, 'XTickLabel', primitiveLabels);

xlabel('LUT Primitive');
ylabel('Logical Primitive Count');
title('LUT Primitive Composition');

legend('Ripple-Carry', 'Carry-Lookahead', ...
       'Location', 'best');

grid on;

drawnow;

exportgraphics(gca, ...
    fullfile(figuresDir, 'LUT_Primitive_Composition.png'), ...
    'Resolution', 300);
%% 10. Figure 3 - Routed Timing Breakdown

timingComponents = [
    rcaLogicDelay,   rcaRoutingDelay
    claLogicDelay,   claRoutingDelay
];

figure('Name', 'Routed Timing Breakdown');

bar(timingComponents, 'stacked');

set(gca, 'XTickLabel', ...
    ["Ripple-Carry", "Carry-Lookahead"]);

ylabel('Delay (ns)');
title('Worst Routed Path Delay Breakdown');

legend('Logic Delay', 'Routing Delay', ...
       'Location', 'best');

grid on;

drawnow;

exportgraphics(gca, ...
    fullfile(figuresDir, 'Timing_Breakdown.png'), ...
    'Resolution', 300);

%% 11. Figure 4 - Vivado Power Breakdown

powerLabels = ["Slice Logic", "Signals", "I/O", "Static"];

powerRCA = [
    Data.RCA(Data.Metric == "Slice Logic Power")
    Data.RCA(Data.Metric == "Signal Power")
    Data.RCA(Data.Metric == "IO Power")
    Data.RCA(Data.Metric == "Device Static Power")
];

powerCLA = [
    Data.CLA(Data.Metric == "Slice Logic Power")
    Data.CLA(Data.Metric == "Signal Power")
    Data.CLA(Data.Metric == "IO Power")
    Data.CLA(Data.Metric == "Device Static Power")
];

figure('Name', 'Vivado Power Breakdown');

bar([powerRCA powerCLA]);

set(gca, 'XTickLabel', powerLabels);

xlabel('Power Component');
ylabel('Estimated Power (W)');
title('Vivado Estimated Power Breakdown');

legend('Ripple-Carry', 'Carry-Lookahead', ...
       'Location', 'best');

grid on;

drawnow;

exportgraphics(gca, ...
    fullfile(figuresDir, 'Power_Breakdown.png'), ...
    'Resolution', 300);



fprintf('\nAll figures exported successfully to:\n%s\n', figuresDir);


%% 12. Generate Analysis Results File

resultsFile = fullfile(scriptDir, ...
    'CLA_vs_RippleCarry_Results.txt');

fid = fopen(resultsFile, 'w');

if fid == -1
    error('Unable to create results file.');
end

fprintf(fid, 'CLA vs Ripple-Carry Adder/Subtractor FPGA Analysis\n');
fprintf(fid, '==================================================\n\n');

fprintf(fid, 'Experimental Configuration\n');
fprintf(fid, '--------------------------\n');
fprintf(fid, 'Target FPGA: Xilinx Artix-7 xc7a35tcpg236-1\n');
fprintf(fid, 'Vivado Version: 2026.1\n');
fprintf(fid, 'Datapath Width: 4 bits\n\n');


fprintf(fid, '1. FPGA RESOURCE UTILIZATION\n');
fprintf(fid, '----------------------------\n');

fprintf(fid, 'Implemented LUTs:\n');
fprintf(fid, '  Ripple-Carry: %d\n', rcaLUTs);
fprintf(fid, '  Carry-Lookahead: %d\n', claLUTs);
fprintf(fid, '  Difference (CLA - RCA): %d\n', lutDifference);
fprintf(fid, '  Relative Change: %.2f %%\n\n', lutPercentChange);

fprintf(fid, 'Implemented Slices:\n');
fprintf(fid, '  Ripple-Carry: %d\n', rcaSlices);
fprintf(fid, '  Carry-Lookahead: %d\n', claSlices);
fprintf(fid, '  Difference (CLA - RCA): %d\n', sliceDifference);
fprintf(fid, '  Relative Change: %.2f %%\n\n', slicePercentChange);

fprintf(fid, ['Interpretation:\n' ...
    'Both implementations used the same overall physical FPGA ' ...
    'resource footprint: 8 LUTs and 2 slices. The LUT primitive ' ...
    'composition differed, indicating that Vivado mapped the two ' ...
    'architectures into different underlying Boolean structures ' ...
    'while achieving identical physical utilization.\n\n']);


fprintf(fid, '2. ROUTED TIMING ANALYSIS\n');
fprintf(fid, '-------------------------\n');

fprintf(fid, 'Worst Routed Input-to-Output Path:\n');
fprintf(fid, '  Ripple-Carry: %.3f ns\n', rcaDelay);
fprintf(fid, '  Carry-Lookahead: %.3f ns\n', claDelay);
fprintf(fid, '  Difference (CLA - RCA): %.3f ns\n', delayDifference);
fprintf(fid, '  CLA Relative Change: %.2f %%\n', delayPercentChange);
fprintf(fid, '  CLA/RCA Delay Ratio: %.5f\n\n', delayRatio);

fprintf(fid, 'Worst-Path Logic Delay:\n');
fprintf(fid, '  Ripple-Carry: %.3f ns\n', rcaLogicDelay);
fprintf(fid, '  Carry-Lookahead: %.3f ns\n', claLogicDelay);
fprintf(fid, '  Difference (CLA - RCA): %.3f ns\n', logicDelayDifference);
fprintf(fid, '  CLA Relative Change: %.2f %%\n\n', ...
    logicDelayPercentChange);

fprintf(fid, 'Worst-Path Routing Delay:\n');
fprintf(fid, '  Ripple-Carry: %.3f ns\n', rcaRoutingDelay);
fprintf(fid, '  Carry-Lookahead: %.3f ns\n', claRoutingDelay);
fprintf(fid, '  Difference (CLA - RCA): %.3f ns\n', routingDelayDifference);
fprintf(fid, '  CLA Relative Change: %.2f %%\n\n', ...
    routingDelayPercentChange);

fprintf(fid, ['Interpretation:\n' ...
    'For these implemented 4-bit designs, the Ripple-Carry design ' ...
    'exhibited a lower whole-module worst-case routed path delay. ' ...
    'The Carry-Lookahead design reduced logic delay, but its higher ' ...
    'routing delay outweighed that reduction on the reported worst ' ...
    'path. The result is specific to these implemented Artix-7 ' ...
    'designs and should not be interpreted as an inherent timing ' ...
    'advantage of ripple-carry architecture.\n\n']);

fprintf(fid, ['Timing Caveat:\n' ...
    'The comparison uses routed combinational input-to-output paths. ' ...
    'No clock-based maximum-frequency or timing-closure claim is ' ...
    'made from these measurements.\n\n']);


fprintf(fid, '3. VIVADO POWER ESTIMATION\n');
fprintf(fid, '--------------------------\n');

fprintf(fid, 'Total On-Chip Power:\n');
fprintf(fid, '  Ripple-Carry: %.3f W\n', rcaTotalPower);
fprintf(fid, '  Carry-Lookahead: %.3f W\n', claTotalPower);
fprintf(fid, '  Difference (CLA - RCA): %.3f W\n', totalPowerDifference);
fprintf(fid, '  CLA Relative Change: %.4f %%\n', totalPowerPercentChange);
fprintf(fid, '  CLA/RCA Power Ratio: %.5f\n\n', totalPowerRatio);

fprintf(fid, 'Dynamic Power:\n');
fprintf(fid, '  Ripple-Carry: %.3f W\n', rcaDynamicPower);
fprintf(fid, '  Carry-Lookahead: %.3f W\n', claDynamicPower);
fprintf(fid, '  Difference (CLA - RCA): %.3f W\n\n', ...
    dynamicPowerDifference);

fprintf(fid, 'Device Static Power:\n');
fprintf(fid, '  Ripple-Carry: %.3f W\n', rcaStaticPower);
fprintf(fid, '  Carry-Lookahead: %.3f W\n', claStaticPower);
fprintf(fid, '  Difference (CLA - RCA): %.3f W\n\n', ...
    staticPowerDifference);

fprintf(fid, ['Interpretation:\n' ...
    'The two architectures produced effectively equivalent Vivado ' ...
    'power estimates. The Carry-Lookahead estimate was only 0.002 W ' ...
    'higher than the Ripple-Carry estimate. The reported difference ' ...
    'originated from estimated signal power, while slice-logic, I/O, ' ...
    'and static-power estimates were identical at report precision.\n\n']);

fprintf(fid, ['Power Caveat:\n' ...
    'These values are Vivado estimates rather than measured board ' ...
    'power. The reports have low confidence because switching ' ...
    'activity was not fully specified, and the estimates are ' ...
    'dominated by I/O power. Therefore, the small power difference ' ...
    'should not be interpreted as a significant real-world power ' ...
    'advantage for either architecture.\n\n']);


fprintf(fid, '4. OVERALL CONCLUSION\n');
fprintf(fid, '---------------------\n');

fprintf(fid, ['At a 4-bit datapath width on the selected Artix-7 FPGA, ' ...
    'both architectures achieved identical overall LUT and slice ' ...
    'utilization after implementation. Their internal LUT primitive ' ...
    'composition differed, demonstrating architecture-dependent ' ...
    'mapping despite equal physical utilization.\n\n']);

fprintf(fid, ['The Carry-Lookahead implementation reduced the logic portion ' ...
    'of its reported worst path but incurred greater routing delay, ' ...
    'resulting in a 3.40%% higher whole-module worst routed path delay ' ...
    'for this implementation. Power estimates were effectively ' ...
    'equivalent, differing by approximately 0.033%%.\n\n']);

fprintf(fid, ['These results demonstrate that RTL architectural differences ' ...
    'do not necessarily translate directly into differences in final ' ...
    'FPGA resource utilization, timing, or estimated power because ' ...
    'synthesis, technology mapping, placement, and routing also affect ' ...
    'the implemented hardware.\n']);

fclose(fid);

fprintf('\nAnalysis results exported successfully to:\n%s\n', ...
    resultsFile);