
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);

%% Plot raw signal
% function plotRawSignal(fs,cachedData, check_id, axis)
fs = 20;
check_id = 33;
plotRawSignal(fs,cachedData, check_id,'z');

%% Plot scatter
% function plotScatter(cachedData, check_id, check_axis, actstr)
check_id = 33;
check_axis = 'z';
check_acti = 'Walking'; % Walking
plotScatter(cachedData, check_id, check_axis, check_acti);

%% Plot histogram
check_id = 33;
check_axis = 'z';
% function plotHistogram(cachedData, check_id, axis)
%plotHistogram(cachedData, check_id, 'x');
%plotHistogram(cachedData, check_id, 'y');
plotHistogram(cachedData, check_id, check_axis);

%% Plot single activity of single one
% function plotSinglePerActi(cachedData, check_id, check_act, check_axis)
check_id = 33;
check_act = 'Walking';
check_act = 'Upstairs';
check_axis = 'z';
plotSinglePerActi(cachedData, check_id, check_act, check_axis);
%% Average Filter v1
% function averageFiltering(cachedData,check_axis, check_id, win_size, output_file_name)
win_size = 20;
check_id = 33;
check_axis = 'x';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',check_axis,'axis','_v1.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);
averageFiltering(cachedData, check_axis, check_id, win_size, output_file_name);

%% Average Filter v2
% function averageFiltering(cachedData,check_axis, check_id, win_size, output_file_name)
win_size = 20;
check_id = 33;
check_axis = 'z';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',check_axis,'axis','v2.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);

[raw, filted] = averageFilteringv2(cachedData, check_axis, check_id, win_size, output_file_name);
figure;
plot(raw, 'b-');
hold on;
plot(filted, 'r-.');
hold off;

%%
