
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);
clearvars -except cachedData
%% Double average filtering
win_size = 21;
std_coeff = 1;
target_id = 8;

% Attention: must remove these ids' data: 4,9£¬25
[raw_axis_x, raw_label] = extractIndividualData(cachedData, 'x', target_id);
fir_filtered_axis_x = averageFiltering(raw_axis_x, raw_label, win_size, std_coeff);

[raw_axis_y, ~] = extractIndividualData(cachedData, 'y', target_id);
fir_filtered_axis_y = averageFiltering(raw_axis_y, raw_label, win_size, std_coeff);

[raw_axis_z, ~] = extractIndividualData(cachedData, 'z', target_id);
fir_filtered_axis_z = averageFiltering(raw_axis_z, raw_label, win_size, std_coeff);

%{
% First time to average filter each axis.
%figure;
plot(raw_axis_x, 'b-');
hold on;
plot(fir_filtered_axis_x, 'g-', 'LineWidth', 1.5);
hold on;
plot(raw_label_x, 'r-');
title('First time to average filter x axis');
hold off;
%}

sec_filtered_axis_x = averageFiltering(fir_filtered_axis_x, raw_label, win_size, std_coeff);
sec_filtered_axis_y = averageFiltering(fir_filtered_axis_y, raw_label, win_size, std_coeff);
sec_filtered_axis_z = averageFiltering(fir_filtered_axis_z, raw_label, win_size, std_coeff);

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
half_win = 10;
[pred_pos, real_pos] = mutationDetection(half_win, sec_filtered_axis_x, sec_filtered_axis_y, sec_filtered_axis_z, raw_label, target_id);






%{
%% Plot raw signal
fs = 20;
plotRawSignal(fs, raw_label, raw_axis_x, target_id, 'x');
plotRawSignal(fs, raw_label, raw_axis_y, target_id, 'y');
plotRawSignal(fs, raw_label, raw_axis_z, target_id, 'z');
%}


