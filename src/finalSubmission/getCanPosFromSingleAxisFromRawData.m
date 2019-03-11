function [candidatePos] = ...
    getCanPosFromSingleAxisFromRawData(rawAxisData, comWinLen, preWinThreshold, bakWinThreshold, curWinLen)

% 从单个坐标轴上获得候选的动作切换位置

    %check_win = 3; % WISDM    
    mergeThreshold = 200;       
    dataLen = length(rawAxisData);
    candidatePos = zeros(dataLen, 1);
    canIndex = 1;

    for rawDataIndex = 2 : dataLen - 1 - curWinLen
        [for_beg_pointer,bak_end_pointer] = getIndex(rawDataIndex, comWinLen, dataLen, curWinLen);
        for_end_pointer = rawDataIndex - 1;
        bak_beg_pointer = rawDataIndex + curWinLen;

        for_mean = mean(rawAxisData(for_beg_pointer: for_end_pointer));
        bak_mean = mean(rawAxisData(bak_beg_pointer: bak_end_pointer));
        this_mean = mean(rawAxisData(rawDataIndex : rawDataIndex + curWinLen -1));

        t_for_diff = this_mean - for_mean;
        t_bak_diff = this_mean - bak_mean;
        if abs(t_for_diff) > preWinThreshold && abs(t_bak_diff) < bakWinThreshold
            candidatePos(canIndex) = rawDataIndex;
            canIndex = canIndex + 1;
        end             

    end
        candidatePos = candidatePos(1:canIndex-1);

% 合并全部
    if ~isempty(candidatePos)
            candidatePos = mergeCandidatePos(candidatePos, mergeThreshold);
    end

    function [forward_pointer, backward_pointer] = getIndex( curIndex, comWinLen, dataLen,curWinLen)
        if curIndex <= comWinLen
            forward_pointer = 1;
            backward_pointer = curIndex + curWinLen + comWinLen;
        elseif curIndex >= dataLen - comWinLen - curWinLen
            forward_pointer = curIndex - comWinLen;
            backward_pointer = dataLen;
        else
            forward_pointer = curIndex - comWinLen;
            backward_pointer = curIndex + curWinLen + comWinLen;
        end
    end

    function res = mergeCandidatePos(locs, threshold)
        res = zeros(length(locs), 1);
        pre_data = locs(1);
        res(1) = pre_data;
        k = 2;
        i = 2;
        while i <= length(locs)
            while i <= length(locs) && locs(i) <= pre_data + threshold
                pre_data = locs(i);
                i = i + 1;
            end
            if i <= length(locs)
                pre_data = locs(i);
                res(k) = locs(i);
                k = k + 1; 
                i = i + 1;
            end

        end
        res = res(1:k-1);
    end

end