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

%% Visualize pre_threshold and bak_threshold setting
for i = 1:5
    visualizePreBakThresholdSetting(cachedData, min_length, i);
end
%% Visualize check_win setting
pre_threshold = 6;
bak_threshold = 0.5;
for i = 1:5
    visualizeCheckWinSetting(cachedData, min_length, i, pre_threshold, bak_threshold);
end

function visualizeCheckWinSetting(cachedData, min_length, target_id, pre_threshold, bak_threshold)
    figure;
    for i = 1:6
       subplot(2,3,i);
       check_win = i;
       [raw_label, merge_all, merge_locs, real_locs] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold, check_win);
        drawPredictedLabel(raw_label, merge_all, target_id, pre_threshold, bak_threshold, check_win);
    end
end

%% Function for pre_threshold and bak_threshold setting
function visualizePreBakThresholdSetting(cachedData, min_length, target_id)
    figure;
    for i = 1:6
        subplot(2,3,i);
        pre_threshold = 6;
        bak_threshold = 0 + (i / 10);
        [raw_label, merge_all, merge_locs, real_locs] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold);
        drawPredictedLabel(raw_label, merge_all, target_id, pre_threshold, bak_threshold);
    end
end
