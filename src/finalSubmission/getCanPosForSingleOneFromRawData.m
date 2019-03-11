function [rawLabel, allCanSwitchedPos, realSwitchedPos] = ...
    getCanPosForSingleOneFromRawData(cachedData, minActivityLen, targetId, preWinThreshold, bakWinThreshold, checkWinLen)

% ��ȡĳ���û�����������ĺ�ѡ�����зֵ㣬���鲢Ϊһ�����鷵��

    % Attention:  4,9��25
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