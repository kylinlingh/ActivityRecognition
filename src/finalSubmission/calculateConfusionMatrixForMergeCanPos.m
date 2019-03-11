function [truePositiveCount, falsePositiveCount, falseNegativeCount] = ...
    calculateConfusionMatrixForMergeCanPos(cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation)

    peopleCount = 34;
    truePositiveCount = 0;
    falsePositiveCount = 0;
    falseNegativeCount = 0;
    
    for i = 1 : peopleCount
        testId = i;
        
        [predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
            reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);
        
        [truePositive, falsePositive, falseNegative] = ...
            calculateConfusionMatrixForSingleOne(validMergeSwitchedPos, realSwitchedPos);
        
        truePositiveCount = truePositiveCount + length(truePositive);
        falsePositiveCount = falsePositiveCount + length(falsePositive);
        falseNegativeCount = falseNegativeCount + length(falseNegative);
    end

end