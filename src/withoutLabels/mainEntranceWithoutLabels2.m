
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);
clearvars -except cachedData

%% Find peaks in raw signal
win_size = 120;
std_coeff = 0;
target_id = 13;
times = 1;

% Attention: must remove these ids' data: 4,9£¬25
[raw_axis_x, raw_label] = extractIndividualData(cachedData, 'x', target_id);
[raw_axis_y, ~] = extractIndividualData(cachedData, 'y', target_id);
[raw_axis_z, ~] = extractIndividualData(cachedData, 'z', target_id);

figure;
subplot(311);
plot(raw_axis_x);
hold on;
plot(raw_label, 'r-', 'LineWidth',1.5);
hold off;
subplot(312);
plot(raw_axis_y);
hold on;
plot(raw_label, 'r-', 'LineWidth',1.5);
hold off;
subplot(313);
plot(raw_axis_z);
hold on;
plot(raw_label, 'r-', 'LineWidth',1.5);
hold off;

half_win = 120;
min_peak_height = 1;
[pred_pos, real_pos, locs_x, locs_y, locs_z] = rawDataFindPeak(half_win, raw_axis_x, raw_axis_y, raw_axis_z, raw_label, target_id, min_peak_height);
merge_locs = zeros(50,5);
merge_locs = mergeLocs(merge_locs, locs_x, 1);
merge_locs = mergeLocs(merge_locs, locs_y, 2);
merge_locs = mergeLocs(merge_locs, locs_z, 3);
merge_locs = mergeLocs(merge_locs, pred_pos, 4);
merge_locs = mergeLocs(merge_locs, real_pos, 5);

function [merge_locs] =  mergeLocs(merge_locs, locs, ind) 
    for j = 1 : length(locs)
       merge_locs(j, ind) = locs(j); 
    end
end
