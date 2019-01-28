
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_ALL_HANDS.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');
mapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForIdAndName.mat');

load(cacheDataPath);
load(mapPath);
clearvars -except cachedData mapForIdAndName

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
clearvars -except cachedData  min_length mapForIdAndName

%% Process individual data

target_id = 15;

pre_threshold = 5.5;  
bak_threshold = 0.2;
check_win = 3;
frequency = 25;
[raw_label, all_predicted_locs, merge_locs, real_locs] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold, check_win);
figure;
drawPredictedLabel(raw_label, all_predicted_locs, target_id, pre_threshold, bak_threshold, check_win);
[predict_result, true_result,tp, fp, fn] = calculateMetricsWithoutLabels(all_predicted_locs, real_locs, length(raw_label), frequency);
[X, Y, T, AUC] = perfcurve(true_result, predict_result, 1);

%clearvars -except cachedData  min_length AUC merge_locs all_predicted_locs mapForIdAndName
%{
figure;
plot(X,Y);
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC for Segmentation');
%}
%plotroc(true_result, predict_result);
%auc = calAUC(true_result, predict_result);

%}
%% Process All people
pre_threshold = 5.5;  
bak_threshold = 0.2;
check_win = 3;
frequency = 25;
mapForSegmentation = struct();
for id = 1:34
    target_id = id;
    [raw_label, all_predicted_locs, merge_locs, real_locs] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold, check_win);
    key = strcat('id',num2str(id));
    value = mapForIdAndName.(key);
    tmp = regexp(value, '\.', 'split');
    name = cell2mat(tmp(1));
    mapForSegmentation.(name) = all_predicted_locs';
    %drawPredictedLabel(raw_label, all_predicted_locs, target_id, pre_threshold, bak_threshold, check_win);
    %[predict_result, true_result,tp, fp, fn] = calculateMetricsWithoutLabels(all_predicted_locs, real_locs, length(raw_label), frequency);
    %[X, Y, T, AUC] = perfcurve(true_result, predict_result, 1);
end
%%
writeToTxt(mapForSegmentation, 'left');
save mapForSegmentation.mat mapForSegmentation;
% save('SegmentResult.txt', '-struct' ,'mapForSegmentation', '-ascii');
%%

function writeToTxt(mapForSegmentation, handSide)
    if strcmp(handSide, 'left')
        fileId = fopen('SegmentResult_left.txt', 'w');
    elseif strcmp(handSide, 'right')
        fileId = fopen('SegmentResult_right.txt', 'w');
    else
        fileId = fopen('SegmentResult_both.txt', 'w');
    end
    
    nameArray = fieldnames(mapForSegmentation);
    for i = 1:length(nameArray)
       name = cell2mat(nameArray(i));
       fprintf(fileId, '%s ', name);
       valueArray = mapForSegmentation.(name);
       for j = 1 : length(valueArray)
          fprintf(fileId, '%d ', valueArray(j));
       end
       fprintf(fileId, '\n');
    end
end

function [result]=calAUC(test_targets,output)
    %计算AUC值,test_targets为原始样本标签,output为分类器得到的标签
    %均为行或列向量
    [A,I]=sort(output);
    M=0;N=0;
    for i=1:length(output)
        if(test_targets(i)==1)
            M=M+1;
        else
            N=N+1;
        end
    end
    sigma=0;
    for i=M+N:-1:1
        if(test_targets(I(i))==1)
            sigma=sigma+i;
        end
    end
    result=(sigma-(M+1)*M/2)/(M*N);
end

function [true_loc_count, pred_loc_count, true_loc_pos, pred_loc_pos] = verifySomething(true_result, predict_result)
    true_loc_count = 0;
    pred_loc_count = 0;
    true_loc_pos = [];
    pred_loc_pos = [];
    for i = 1 : length(true_result);
        if true_result(i) == 1
            true_loc_count = true_loc_count + 1
            true_loc_pos = [true_loc_pos, i];
        end
        if predict_result(i) == 1
            pred_loc_count = pred_loc_count + 1
            pred_loc_pos = [pred_loc_pos; i];
        end
    end
end
