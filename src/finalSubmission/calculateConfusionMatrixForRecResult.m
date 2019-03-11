function [truePositiveCount, falsePositiveCount, falseNegativeCount] = calculateConfusionMatrixForRecResult(cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)
    peopleCount = 34;
    truePositiveCount = 0;
    falsePositiveCount = 0;
    falseNegativeCount = 0;
    
    for i = 1 : peopleCount
        testId = i;
        [~, ~, ~, targetRawLabel] = ...
            loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation);

        [canSwitchedPosFromSmoothedRecResult, ~] = ...
        getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);
        realSwitchedPos = getRealSwitchedPos(targetRawLabel);
        [truePositive, falsePositive, falseNegative] = ...
            calculateConfusionMatrixForSingleOne(canSwitchedPosFromSmoothedRecResult, realSwitchedPos);
        
        truePositiveCount = truePositiveCount + length(truePositive);
        falsePositiveCount = falsePositiveCount + length(falsePositive);
        falseNegativeCount = falseNegativeCount + length(falseNegative);
    end

end