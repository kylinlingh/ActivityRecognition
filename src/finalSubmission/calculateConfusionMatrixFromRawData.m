function [truePositiveCount, falsePositiveCount, falseNegativeCount] = calculateConfusionMatrixFromRawData(cachedData)
    peopleCount = 34;
    preWinThreshold = 5.5;  
    bakWinThreshold = 0.2;
    checkWinLen = 3;
    minActivityLen = getMinLengthOfSameActivity(cachedData);
    
    truePositiveCount = 0;
    falsePositiveCount = 0;
    falseNegativeCount = 0;
    for i = 1 : peopleCount
        targetId = i;
        [~, allCanSwitchedPos, realSwitchedPos] = ...
            getCanPosForSingleOneFromRawData(cachedData, minActivityLen, targetId, preWinThreshold, bakWinThreshold, checkWinLen);
        [truePositive, falsePositive, falseNegative] = ...
            calculateConfusionMatrixForSingleOne(allCanSwitchedPos, realSwitchedPos);
        truePositiveCount = truePositiveCount + length(truePositive);
        falsePositiveCount = falsePositiveCount + length(falsePositive);
        falseNegativeCount = falseNegativeCount + length(falseNegative);
    end

end