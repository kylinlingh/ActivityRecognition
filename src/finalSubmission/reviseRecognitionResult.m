function [predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)

% 读取数据，获得从原始数据里的动作切换候选位置
[targetName, predictedLabel, canSwitchedPosFromRawData, rawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation);
dataLen = length(predictedLabel);

% 获取真实的动作切换位置，用于做图比较
realSwitchedPos = getRealSwitchedPos(rawLabel);

% 平滑预测结果，并从预测结果里获得动作切换候选位置
[canSwitchedPosFromSmoothedRecResult, smoothedRecLabel] = ...
getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);

% reviCanSwitchedPos = mergeInWinLen(reviCanSwitchedPos, 10000);

% 合并两种候选位置
resMergeSwitchedPosFromRawDataAndSmoothedRecognitionResult = sort([canSwitchedPosFromRawData, canSwitchedPosFromSmoothedRecResult']);
validMergeSwitchedPos = screenValidPos(resMergeSwitchedPosFromRawDataAndSmoothedRecognitionResult, 300);

% 必须，必须要在前后添加两个坐标，否则准确率大跌
validMergeSwitchedPos = [1, validMergeSwitchedPos, length(predictedLabel)];

% 根据候选位置，修复识别结果
revisedLabel = reviseFunc(predictedLabel ,validMergeSwitchedPos);

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

end