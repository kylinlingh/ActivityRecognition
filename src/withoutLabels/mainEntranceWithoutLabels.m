
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);
clearvars -except cachedData
%% Average filtering for k times
win_size = 21;
std_coeff = 0;
target_id = 22;
times = 1;

% Attention: must remove these ids' data: 4,9£¬25
[raw_axis_x, raw_label] = extractIndividualData(cachedData, 'x', target_id);
[raw_axis_y, ~] = extractIndividualData(cachedData, 'y', target_id);
[raw_axis_z, ~] = extractIndividualData(cachedData, 'z', target_id);

[filted_x, filted_y, filted_z] = avgFilterKTimes(raw_label ,raw_axis_x, raw_axis_y, raw_axis_z, win_size, times);


figure;
%subplot(311);
plot(raw_axis_x, 'b-');
hold on;
plot(filted_x, 'g-', 'LineWidth', 1.5);
hold on;
plot(raw_label, 'r-');
hold off;

%{
subplot(312);
plot(raw_axis_y, 'b-');
hold on;
plot(filted_y, 'g-', 'LineWidth', 1.5);
hold on;
plot(raw_label, 'r-');
hold off;

subplot(313);
plot(raw_axis_z, 'b-');
hold on;
plot(filted_z, 'g-', 'LineWidth', 1.5);
hold on;
plot(raw_label, 'r-');
hold off;
%}


%{
figure;
plot(raw_axis_x, 'b-');
hold on;
plot(fir_filtered_axis_x, 'g-');
hold on;
plot(raw_label, 'r-');
hold off;
%}

%fir_filtered_axis_x = averageFilteringWithoutLabels(raw_axis_x, raw_label, win_size, std_coeff);
%fir_filtered_axis_y = averageFilteringWithoutLabels(raw_axis_y, raw_label, win_size, std_coeff);
%fir_filtered_axis_z = averageFilteringWithoutLabels(raw_axis_z, raw_label, win_size, std_coeff);

%{
% First time to average filter each axis.
figure;
plot(raw_axis_x, 'b-');
hold on;
plot(fir_filtered_axis_x, 'g-', 'LineWidth', 1.5);
hold on;
plot(raw_label, 'r-');
title('First time to average filter x axis');
hold off;
%}

%sec_filtered_axis_x = averageFilteringWithoutLabels(fir_filtered_axis_x, raw_label, win_size, std_coeff);
%sec_filtered_axis_y = averageFilteringWithoutLabels(fir_filtered_axis_y, raw_label, win_size, std_coeff);
%sec_filtered_axis_z = averageFilteringWithoutLabels(fir_filtered_axis_z, raw_label, win_size, std_coeff);

%{
% Second time to average filter each axis.
figure;
%subplot(211);
plot(raw_axis_x, 'b-');
hold on;
plot(fir_filtered_axis_x, 'g-', 'LineWidth', 1.5);
hold on;
plot(sec_filtered_axis_x, 'r-');
hold on;
plot(raw_label, 'k-', 'LineWidth', 1.5);
title('Second time to average filter x axis');
hold off;
%}

%% Predict mutation position

% function mutationDetection(half_win, filtered_x, filtered_y, filtered_z, raw_label)
half_win = 20;
[pred_pos, real_pos, locs_x, locs_y, locs_z] = mutationDetectionWithoutLabels(half_win, filted_x, filted_y, filted_z, raw_label, target_id);


%% Plot raw signal
fs = 20;
%plotRawSignal(fs, raw_label, raw_axis_x, target_id, 'x');
%plotRawSignal(fs, raw_label, raw_axis_y, target_id, 'y');
%plotRawSignal(fs, raw_label, raw_axis_z, target_id, 'z');





%% Average filtering many times
function [filtered_axis_x, filtered_axis_y, filtered_axis_z] = avgFilterKTimes(raw_label, raw_axis_x, raw_axis_y, raw_axis_z, win_size, times)
    for i = 1 : times
        filtered_axis_x = averageFilteringWithoutLabels(raw_axis_x, raw_label, win_size);
        filtered_axis_y = averageFilteringWithoutLabels(raw_axis_y, raw_label, win_size);
        filtered_axis_z = averageFilteringWithoutLabels(raw_axis_z, raw_label, win_size);
        
        raw_axis_x = filtered_axis_x;
        raw_axis_y = filtered_axis_y;
        raw_axis_z = filtered_axis_z;
    end

end