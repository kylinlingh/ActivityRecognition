function [rawLabel, allCanSwitchedPos, realSwitchedPos] = ...
    getCanPosForSingleOneFromRawData(cachedData, minActivityLen, targetId, preWinThreshold, bakWinThreshold, checkWinLen)

% 获取某个用户三个坐标轴的候选动作切分点，并归并为一个数组返回

    % Attention:  4,9，25
    % Best: 31
    % Worst:
    [rawAxisOfX, rawLabel]  = extractSingleAxisDataFromRawData(cachedData, 'x', targetId);
    [rawAxisOfY, ~]         = extractSingleAxisDataFromRawData(cachedData, 'y', targetId);
    [rawAxisOfZ, ~]         = extractSingleAxisDataFromRawData(cachedData, 'z', targetId);

    %%
    canSwitchedPosOfAxisX = getCanPosFromSingleAxisFromRawData(rawAxisOfX, minActivityLen, preWinThreshold, bakWinThreshold, checkWinLen);
    canSwitchedPosOfAxisY = getCanPosFromSingleAxisFromRawData(rawAxisOfY, minActivityLen, preWinThreshold, bakWinThreshold, checkWinLen);
    canSwitchedPosOfAxisZ = getCanPosFromSingleAxisFromRawData(rawAxisOfZ, minActivityLen, preWinThreshold, bakWinThreshold, checkWinLen);
    
    realSwitchedPos = getRealSwitchedPos(rawLabel);
    mergeThreshold = 1000;
    allCanSwitchedPos = [canSwitchedPosOfAxisX; canSwitchedPosOfAxisY; canSwitchedPosOfAxisZ];
    
    allCanSwitchedPos = screenValidPos(sort(allCanSwitchedPos), mergeThreshold);
    allCanSwitchedPos = allCanSwitchedPos(allCanSwitchedPos >= minActivityLen);
    allCanSwitchedPos = allCanSwitchedPos(allCanSwitchedPos < length(rawLabel) - minActivityLen);

end