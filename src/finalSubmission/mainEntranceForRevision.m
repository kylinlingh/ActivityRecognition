
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
%% 获取动作类别的数据分布情况
% 声明：这是从传感器得到的原始数据，只有label从1到8，并不包含9（动作切换数据帧），因为9号标签是在处理原始数据，提取数据帧时产生的，所以并不存在于原始数据里
[labelCount, percent] = statiscsActivitiesDataDistribution(cachedData);


%% 检查单人的修正效果 

testId = 6;
[predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);

[predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel);

%% 检查全部人的修正效果
peopleCount = 34;
predictedAccuracy = zeros(1, peopleCount);
revisedAccuracy = zeros(1, peopleCount);
plotLabel = 0;

for i = 1 : peopleCount
    testId = i;
    [predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);
    [predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel);
    predictedAccuracy(i) = predictedPercision;
    revisedAccuracy(i) = revisedPercision;
end
%% 检查只使用原始数据里得到的动作切换位置，预测准确率为：81.59，修正后的准确率为69.96
%preWinThreshold = 5.5;  
%bakWinThreshold = 0.2;
%checkWinLen = 3;
%minActivityLen = getMinLengthOfSameActivity(cachedData);

%for i = 1 : peopleCount
%    targetId = i;
%    [rawLabel, allCanSwitchedPos, realSwitchedPos] = ...
%    getCanPosForSingleOneFromRawData(cachedData, minActivityLen, targetId,
%    preWinThreshold, bakWinThreshold, checkWinLen);

%    [targetName, predictedLabel, targetSegmentPos, targetRawLabel] = ...
%        loadDataFromRecResult(targetId, cachedData, mapForIdAndName, mapForSegmentation);
    
%    revisedLabel = reviseFunc(predictedLabel ,allCanSwitchedPos);
%    [predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel);
%    predictedAccuracy(i) = predictedPercision;
%    revisedAccuracy(i) = revisedPercision;
%end
%% 计算两个指标
meanPredictedPercision = mean(predictedAccuracy);
meanRevisiedPercision = mean(revisedAccuracy);
%% 计算几个指标
bigger = 0;
littler = 0;
maxup = 0;
maxdown = 1;
for i = 1 : length(predictedAccuracy)
    gap = revisedAccuracy (i) - predictedAccuracy(i);
    if gap > 0
        bigger = bigger + 1;
        if gap > maxup
            maxup = gap;
        end
    else 
        littler = littler + 1;
        if gap < maxdown
            maxdown = gap;
        end
    end
end

%% 绘制图表
    figure;
    xAxis = [1:34];
    scatter(xAxis ,predictedAccuracy, 'b*');
    hold on;
    scatter(xAxis ,revisedAccuracy, 'go');
    hold on;
    plot(predictedAccuracy,'-o');
    hold on;
    plot(revisedAccuracy,'--o','LineWidth',1.5);
    hold on;

    title('Correction of activity recognition result');
    legend('preAccuracy', 'revAccuracy', 'Location','SouthEast');
    xlabel('Target id');
    ylabel('Accuracy');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小   
%% 
function [predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel)
    % 计算分类器的识别准确率
    validLength = length(predictedLabel);
    validRawData = rawLabel(1:validLength);
    predictedPercision = mean(validRawData == (predictedLabel+1)); % predictedLabel
    % 计算修复分类结果后的准确率       
    revisedPercision = mean(revisedLabel == rawLabel(1:length(revisedLabel)));
end

%%


    function revisedResult = reviseFunc(predictedLabel, validMergeSwitchedPos)
        revisedResult = predictedLabel;

        % 根据候选点来修复预测结果    
        
        for i = 1 : length(validMergeSwitchedPos) - 1   
            preIn = ceil(validMergeSwitchedPos(i));
            bakIn = ceil(validMergeSwitchedPos(i+1));
            validData = predictedLabel(preIn : bakIn);
            maxLabel = getMaxCountLabel(validData);
            revisedResult(preIn : bakIn) = ones(1,bakIn - preIn + 1) * (maxLabel+1);
        end
    end

    function res = getMaxCountLabel(inputArray)
            table = tabulate(inputArray);
            [~, idx] = max(table(:, 2));
            res = table(idx);
    end