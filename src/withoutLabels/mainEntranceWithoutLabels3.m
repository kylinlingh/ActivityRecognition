
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
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

%% Extract individual data
target_id = 37;

% Attention:  4,9£¬25
% Best: 31
% Worst:
[raw_axis_x, raw_label] = extractIndividualData(cachedData, 'x', target_id);
[raw_axis_y, ~] = extractIndividualData(cachedData, 'y', target_id);
[raw_axis_z, ~] = extractIndividualData(cachedData, 'z', target_id);

%%
[filted_x, canpos_x] = averageFilteringWithoutLabels3(raw_label, raw_axis_x, min_length, target_id);
[filted_y, canpos_y] = averageFilteringWithoutLabels3(raw_label, raw_axis_y, min_length, target_id);
[filted_z, canpos_z] = averageFilteringWithoutLabels3(raw_label, raw_axis_z, min_length, target_id);
real_pos = findRealMutationPosition(raw_label);

%{
mergeThreshold = 20;
canpos_x = mergeCandidatePos(canpos_x,mergeThreshold);
canpos_y = mergeCandidatePos(canpos_y,mergeThreshold);
canpos_z = mergeCandidatePos(canpos_z,mergeThreshold);
%}

mergeThreshold = 200;
merge_all = [canpos_x; canpos_y; canpos_z];
merge_all = mergeCandidatePos(sort(merge_all), mergeThreshold);
merge_all = merge_all(merge_all >= min_length);
merge_all = merge_all(merge_all < length(raw_label) - min_length);
drawPredictedLabel(raw_label, merge_all, target_id);

merge_locs = zeros(50,5);
merge_locs = mergeLocs(merge_locs, canpos_x, 1);
merge_locs = mergeLocs(merge_locs, canpos_y, 2);
merge_locs = mergeLocs(merge_locs, canpos_z, 3);
merge_locs = mergeLocs(merge_locs, merge_all, 4);
merge_locs = mergeLocs(merge_locs, real_pos, 5);

%%




%%
%{
half_win = 10;
[pred_pos, real_pos, locs_x, locs_y, locs_z] = mutationDetectionWithoutLabels(half_win, filted_x, filted_y, filted_z, raw_label, target_id);

merge_locs = zeros(50,5);
merge_locs = mergeLocs(merge_locs, locs_x, 1);
merge_locs = mergeLocs(merge_locs, locs_y, 2);
merge_locs = mergeLocs(merge_locs, locs_z, 3);
merge_locs = mergeLocs(merge_locs, pred_pos, 4);
merge_locs = mergeLocs(merge_locs, real_pos, 5);
%}
function [merge_locs] =  mergeLocs(merge_locs, locs, ind) 
    for j = 1 : length(locs)
       merge_locs(j, ind) = locs(j); 
    end
end

function [real_mutation_pos] = findRealMutationPosition(raw_labels)
    t_array = zeros(length(raw_labels),1);
    k = 1;
    for i = 2 : length(raw_labels)
        if raw_labels(i) - raw_labels(i-1) ~= 0
           t_array(k) = i;
           k = k + 1;
        end
    end
    real_mutation_pos = t_array(1:k-1);
end

function res = mergeCandidatePos(locs, threshold)
    res = zeros(length(locs), 1);
    pre_data = locs(1);
    res(1) = pre_data;
    k = 2;
    i = 2;
    while i <= length(locs)
        while i <= length(locs) && locs(i) <= pre_data + threshold
            pre_data = locs(i);
            i = i + 1;
        end
        if i <= length(locs)
            pre_data = locs(i);
            res(k) = locs(i);
            k = k + 1; 
            i = i + 1;
        end
        
    end
    res = res(1:k-1);
end

    function drawPredictedLabel(raw_label, predict_loc, target_id)
        figure;
        plot(raw_label, 'g-', 'LineWidth', 1);
        hold on;
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 7], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw label of target id: ', num2str(target_id)];
        title(t_title);
        legend('raw_label', 'predicted position');
        hold off;
    end
