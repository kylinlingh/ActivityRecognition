
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
idAndNamemapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForIdAndName.mat');
nameAndIdmapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForNameAndId.mat');
segmentResultPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForSegmentation.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');

load(cacheDataPath);
load(idAndNamemapPath);
load(segmentResultPath);
load(nameAndIdmapPath);
%%
drawRecognition(23, 25,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);

%% 将两个人的预测结果组合起来，使用电平来表示标签

function drawRecognition(testId1, testId2,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)
 %   testId1 = 10;
    [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId1,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);
    axis_data = predictedLabel;
    sampling_rate = 50;
    t = (1/sampling_rate) * (0:length(axis_data)-1)';

    figure;
    subplot(211);
    plot(t, axis_data, '-b', 'LineWidth', 1);
    title_str = ['Recognition result of user id: ' num2str(testId1)];
    title(title_str);
    xlabel('Time(sec)');
    ylabel('Activity label');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小
    %hl = legend('predition');
    %set(hl, 'Orientation', 'horizon'); % 设置水平显示图线标志

 %   testId1 = 15;
    [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId2,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);
    axis_data = predictedLabel;
    t = (1/sampling_rate) * (0:length(axis_data)-1)';
    subplot(212);
    plot(t, axis_data, '-b', 'LineWidth', 1);
    title_str = ['Recognition result of user id: ' num2str(testId2)];
    title(title_str);
    xlabel('Time(sec)');
    ylabel('Activity label');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小

end
%%
function drawActivities(axis_data, x_title_str, sampling_rate, time_window)
    activity_count = 8;
    moving_average_win_len = 50;
    moving_average_axis_data = smooth(axis_data, moving_average_win_len);
    
    t = (1/sampling_rate) * (0:length(axis_data)-1)';
    figure;
    plot( axis_data, '-b', 'LineWidth', 1);
    hold on;
    plot(t,moving_average_axis_data, '-r', 'LineWidth',0.5);
    hold on;
    axis([0 time_window*activity_count min(axis_data) max(axis_data)]); % 去除作图后的空白区域

    title(x_title_str);
    xlabel('Time(sec)');
    set(gca, 'XTick', 0: time_window: time_window*activity_count);   % 设置x轴的刻度为每隔40个数显示一次
    ylabel('{Acceleration(m/s^2)}');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小
    hl = legend('Raw signal', 'Moving average', 'Location', 'southeast');
    set(hl, 'Orientation', 'horizon'); % 设置水平显示图线标志

end

function res_label= getRawLabelForTarget(cachedData, targetId)
    id_data = cachedData(:,1);
    acti_label = cachedData(:,2);  
    res_label = acti_label(id_data == targetId);
end
    
function segmentPos = getSegment(mapForSegmentation, targetName)
    segmentPos = mapForSegmentation.(targetName);
end

function targetId = getId(mapForNameAndId ,targetName)
     targetId = str2num(mapForNameAndId.(targetName)(3:end));    
end

function targetName = getName(mapForIdAndName, testId)
    keyName = strcat('id',num2str(testId));
    targetName = mapForIdAndName.(keyName);
    ttmp = strsplit(targetName, '.');
    targetName = ttmp{1,1};
end
    
function res = extractIndiData(cachedData, target_id)
    condition = cachedData(:,1) == target_id;
    res = cachedData(condition,:);
end

function [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)
    targetName = getName(mapForIdAndName, testId);
    predictionResPath = sprintf('%s%s%s','E:\matlab_workspace\dataset\predictionResleft\predictionResult_', targetName, '.txt')
    %fprintf(predictionResPath);
    file = textscan(fopen(predictionResPath), '%d', 'Delimiter',',');
    predictedLabel = file{1,1};
    fprintf('length of predictedLabel: %d\n', length(predictedLabel));
    targetId = getId(mapForNameAndId, targetName);
    targetSegmentPos = getSegment(mapForSegmentation, targetName);
    targetRawLabel = getRawLabelForTarget(cachedData, targetId);
    fprintf('length of rawLabel: %d\n', length(targetRawLabel));
end