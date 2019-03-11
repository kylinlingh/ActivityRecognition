
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
%%
meanPredictedPercision = mean(predictedAccuracy);
meanRevisiedPercision = mean(revisedAccuracy);

%% 
function [predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel)
    % 计算分类器的识别准确率
    validLength = length(predictedLabel);
    validRawData = rawLabel(1:validLength);
    predictedPercision = mean(validRawData == (predictedLabel+1)); % predictedLabel
    % 计算修复分类结果后的准确率       
    revisedPercision = mean(revisedLabel == rawLabel(1:length(revisedLabel)));
end

function drawPredictionMergeAll(testId,predictedLabel, canSwitchedPosFromRawData, realSwitchedPos,canSwitchedPosFromSmoothedRecResult,validMergeSwitchedPos  )
    axis_data = predictedLabel;
    sampling_rate = 50;
    t = (1/sampling_rate) * (0:length(axis_data)-1)';

    figure;
    plot(axis_data, '-b', 'LineWidth', 1);
    title_str = ['Recognition result of user id: ' num2str(testId)];
    title(title_str);
    xlabel('Time(sec)');
    ylabel('Activity label');
    hold on;
    for i = 1 : length(canSwitchedPosFromRawData)
        plot([canSwitchedPosFromRawData(i), canSwitchedPosFromRawData(i)],[0, 10], 'c--','LineWidth',1);
        hold on;
    end

    yytmp = ones(length(realSwitchedPos),1) * 8.3;
    plot(realSwitchedPos, yytmp, 'mo');
    hold on;
     
    
    yytmp = ones(length(validMergeSwitchedPos),1) * 9.8;
    plot(validMergeSwitchedPos, yytmp, 'r*');
    hold on;
end
