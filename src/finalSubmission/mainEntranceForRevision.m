
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
%% ��ȡ�����������ݷֲ����
% ���������ǴӴ������õ���ԭʼ���ݣ�ֻ��label��1��8����������9�������л�����֡������Ϊ9�ű�ǩ���ڴ���ԭʼ���ݣ���ȡ����֡ʱ�����ģ����Բ���������ԭʼ������
[labelCount, percent] = statiscsActivitiesDataDistribution(cachedData);


%% ��鵥�˵�����Ч�� 

testId = 6;
[predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);

[predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel);

%% ���ȫ���˵�����Ч��
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
%% ���ֻʹ��ԭʼ������õ��Ķ����л�λ�ã�Ԥ��׼ȷ��Ϊ��81.59���������׼ȷ��Ϊ69.96
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
%% ��������ָ��
meanPredictedPercision = mean(predictedAccuracy);
meanRevisiedPercision = mean(revisedAccuracy);
%% ���㼸��ָ��
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

%% ����ͼ��
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
    set(gca, 'FontSize', 20); % ���������������С   
%% 
function [predictedPercision,revisedPercision] = calPercision(rawLabel, predictedLabel, revisedLabel)
    % �����������ʶ��׼ȷ��
    validLength = length(predictedLabel);
    validRawData = rawLabel(1:validLength);
    predictedPercision = mean(validRawData == (predictedLabel+1)); % predictedLabel
    % �����޸����������׼ȷ��       
    revisedPercision = mean(revisedLabel == rawLabel(1:length(revisedLabel)));
end

%%


    function revisedResult = reviseFunc(predictedLabel, validMergeSwitchedPos)
        revisedResult = predictedLabel;

        % ���ݺ�ѡ�����޸�Ԥ����    
        
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