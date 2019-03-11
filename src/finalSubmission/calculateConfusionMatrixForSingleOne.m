function [truePositive, falsePositive, falseNegative] = ...
    calculateConfusionMatrixForSingleOne(allCanSwitchedPos, realSwitchedPos)
    checkWin = 1000;

    tallCanSwitchedPos = allCanSwitchedPos;
    deleteFlagForAllCanPos = zeros(length(allCanSwitchedPos), 1);
    deleteFlagForRealPos = zeros(length(realSwitchedPos),1);
    
    %                   realTrue           realFalse
    % predictedTrue     true positive  | false positive
    % predictedFalse    false negative | true negative
    truePositive = [];   
    falseNegative = [];
    falsePositive = [];
    for i = 1 : length(realSwitchedPos)
       curPos = realSwitchedPos(i);
       preLimit = curPos - checkWin;
       bakLimit = curPos + checkWin;
       for j = 1 : length(tallCanSwitchedPos)
          curCanPos = tallCanSwitchedPos(j);
          if curCanPos >= preLimit && curCanPos <= bakLimit
             truePositive = [truePositive, curCanPos];
             deleteFlagForAllCanPos(j) = 1;
             deleteFlagForRealPos(i) = 1;
             tallCanSwitchedPos(j) = [];
             break;
          end
       end
    end
    for i = 1 : length(realSwitchedPos)
       if deleteFlagForRealPos(i) == 0
          falseNegative = [falseNegative, realSwitchedPos(i)]; 
       end
    end
    
    for i = 1 : length(allCanSwitchedPos)
       if deleteFlagForAllCanPos(i) == 0
          falsePositive = [falsePositive, allCanSwitchedPos(i)]; 
       end
    end
    
    falsePositive = tallCanSwitchedPos;
    
end