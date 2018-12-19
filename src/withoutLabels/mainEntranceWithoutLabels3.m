
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_ALL_HANDS.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');

load(cacheDataPath);
clearvars -except cachedData

%% Find the minimum length of same activity
raw_label = cachedData(:,2);

min_length = intmax;
pre_label = raw_label(1);
label_count = 1;
for i = 2 : length(raw_label)
    cur_label = raw_label(i);
    if cur_label ~= pre_label 
        if label_count < min_length
           min_length = label_count; 
%           fprintf("%d - %d\n",i, min_length);
        end
        label_count = 1;
        pre_label = cur_label;
    else
        label_count = label_count + 1;
    end
end
clearvars -except cachedData  min_length

%% Process individual data
target_id = 25;

pre_threshold = 6;  
bak_threshold = 0.5;
check_win = 5;
frequency = 50;
[raw_label, all_predicted_locs, merge_locs, real_locs] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold, check_win);
figure;
drawPredictedLabel(raw_label, all_predicted_locs, target_id, pre_threshold, bak_threshold, check_win);
[tp, fp, fn] = calculateMetrics(all_predicted_locs, real_locs, frequency);




