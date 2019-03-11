function [revisedMutationPos, rreviseLabel] = ...
reviseSingleOne(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData)

[targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId);

%%
voteWinLength = 500;
minLengthOfSameActivity = 2000;
% 两次修复的效果会好很多
reviseLabel = reviseLabelFunc(predictedLabel, voteWinLength);
rreviseLabel = reviseLabelFunc(reviseLabel', voteWinLength);
%rreviseLabel = reviseLabel;
revisedMutationPos = findRealMutationPosition(rreviseLabel);
lengthReviseLabel = minLengthRevision(rreviseLabel, minLengthOfSameActivity, revisedMutationPos);
%%

mutateLabel = 8;
mutatePos = getMutateLabelPos(predictedLabel, mutateLabel);
realPos = findRealMutationPosition(targetRawLabel);

merge_locs = zeros(50,3);
merge_locs = mergeLocs(merge_locs, mutatePos, 1);           % 标签为8的数据位置
merge_locs = mergeLocs(merge_locs, targetSegmentPos, 2);    % 信号处理算法找到的动作切分位置
merge_locs = mergeLocs(merge_locs, realPos, 3);             % 数据的真实切换位置
merge_locs = mergeLocs(merge_locs, revisedMutationPos, 4);  % 数据修正后的切换位置
%% Compare result of revision and prediction accuracy
%[predictedPercision, revisionPercision] = calPercision(targetRawLabel, predictedLabel, rreviseLabel);
%[~, lengthRevisionPercision] = calPercision(targetRawLabel, predictedLabel, lengthReviseLabel);


%drawRevisionResult(targetRawLabel,targetSegmentPos, predictedLabel, testId, reviseLabel, rreviseLabel, targetName, predictedPercision, revisionPercision);
%      drawRevisionResult(targetRawLabel,targetSegmentPos, predictedLabel, testId, reviseLabel, rreviseLabel, targetName, predictedPercision, lengthRevisionPercision);

%% Auxiliary function definition

    function drawRevisionResult(targetRawLabel, targetSegmentPos, predictedLabel,targetId, reviseLabel, rreviseLabel, targetName, predictedPercision, revisionPercision )
       % drawMergeLabel(targetRawLabel, targetSegmentPos, predictedLabel, targetId);
        figure;
        plot(targetRawLabel, 'r-', 'LineWidth', 1);
        hold on;
        %plot(reviseLabel, 'k-', 'LineWidth', 1.5);
        %hold on;
        plot(rreviseLabel+2, 'g-', 'LineWidth', 1.5);
        hold on;
        plot(lengthReviseLabel+3, 'b-');
        
        legend('raw label', 'revise label', 'rrevise label', 'lengthReviseLabel','Location','southeast');
        legend('raw label', 'rrevise label', 'lengthReviseLabel','Location','southeast');
        for i = 1 : length(targetSegmentPos)
           plot([targetSegmentPos(i), targetSegmentPos(i)],[0, 10], 'c-','LineWidth',1);
           hold on;
        end
        titleList = ['Target: ',targetName, ' TargetId: ', num2str(targetId) ,...
            ', Predicted Accuracy: ', num2str(predictedPercision), ', Revisied Accuracy: ', num2str(revisionPercision), ...
            ', Length Revisied Accuracy: ', num2str(lengthRevisionPercision)];
        title(titleList);
    end

    function lengthRevised = minLengthRevision(rreviseLabel, minLengthOfSameActivity, revisedMutationPos)
       lengthRevised = rreviseLabel;
        for i = 2 : length(revisedMutationPos)
            currentMutationPos = revisedMutationPos(i);
            preMutationPos = revisedMutationPos(i-1);
            preGap = currentMutationPos - preMutationPos;
            if preGap < minLengthOfSameActivity
                lengthRevised(preMutationPos : currentMutationPos) = lengthRevised(preMutationPos - 1);
            end
        end 
    end

    function [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId)
        targetName = getName(mapForIdAndName, testId);
        predictionResPath = sprintf('%s%s%s','E:\matlab_workspace\dataset\predictionResleft\predictionResult_', targetName, '.txt')
        %fprintf(predictionResPath);
        file = textscan(fopen(predictionResPath), '%d', 'Delimiter',',');
        predictedLabel = file{1,1};
        fprintf('length of predictedLabel: %d\n', length(predictedLabel));
        targetId = getId(mapForNameAndId, targetName);
        targetSegmentPos = getSegment(mapForSegmentation, targetName);
        targetRawLabel = getRawLabelForTarget(cachedData, targetId);
        fprintf('length of rawLabel: %d\n', length(targetRawLabel));
    end

    function [predictedPercision, revisionPercision] = calPercision(targetRawLabel, predictedLabel, rreviseLabel)
        validLength = length(predictedLabel);
        validRawData = targetRawLabel(1:validLength);
        validRevision = rreviseLabel';
        predictedPercision = mean(validRawData == (predictedLabel+1));
        revisionPercision = mean(validRawData == (validRevision(1:validLength) + 1));
        %revisionPercision = 0;
    end

    function revisedLabel = reviseLabelFunc(predictedLabel, voteWinLength)
        revisedLabel = predictedLabel;
        douVotWinLen = 2*voteWinLength;
        dataLen = length(predictedLabel);
        revisedLabel(1:douVotWinLen) = getMaxCountLabel(predictedLabel(1:douVotWinLen));
        revisedLabel(dataLen-douVotWinLen : dataLen) = getMaxCountLabel(dataLen-douVotWinLen : dataLen); 

        for i = douVotWinLen + 1 : dataLen - douVotWinLen - 1
            preIndex = i - voteWinLength;
            bakIndex = i + voteWinLength;
            revisedLabel(i) = getMaxCountLabel(predictedLabel(preIndex:bakIndex));
        end
    end

    function reviseLabel = reviseLabelFunc2(predictedLabel, voteWinLength)
        validWinLength = voteWinLength;
        FREQUENCY = 50;
        lengOfData = length(predictedLabel);

        reviseLabel = zeros(1,lengOfData);
        for i = 1 : FREQUENCY : length(predictedLabel)
            [preBegIndex, preEndIndex, bakBegIndex, bakEndIndex] = locateIndex(i, lengOfData, voteWinLength, FREQUENCY);
            %preWin = predictedLabel(preBegIndex:preEndIndex);
            %bakWin = predictedLabel(bakBegIndex:bakEndIndex);
            %validArray = [preWin ; bakWin ];
            validArray = predictedLabel(preBegIndex : bakEndIndex);

            %if length(preWin) == length(bakWin) && numel(unique(preWin)) == 1 && numel(unique(bakWin)) == 1
             %   candidateLabel =  cast(preWin(1), 'double');
            %else
            %    candidateLabel = getMaxCountLabel(validArray);
            %end
            candidateLabel = getMaxCountLabel(validArray);
            reviseLabel(i:i+FREQUENCY - 1) = ones(1,FREQUENCY) * (candidateLabel);
        end

    end

    function res = getMaxCountLabel(inputArray)
        table = tabulate(inputArray);
        [maxCount, idx] = max(table(:, 2));
        res = table(idx);
    end

    function [preBegIndex, preEndIndex, bakBegIndex, bakEndIndex] = locateIndex(index, lengOfData, voteWinLength, frequency)
        [preBegIndex, preEndIndex, preGap] = getPreWinIndex(index, voteWinLength);
        % 前后互相补齐，保证数据量达到voteWinLength
        [bakBegIndex, bakEndIndex, bakGap] = getBakWinIndex(index, lengOfData, voteWinLength + preGap, frequency);
        [preBegIndex, preEndIndex, preGap] = getPreWinIndex(index, voteWinLength+bakGap);
    end

    function [preBegIndex, preEndIndex, preGap] = getPreWinIndex(index, voteWinLength)
        preBegIndex = index - voteWinLength;
        if preBegIndex < 1
           preBegIndex = 1; 
        end
        preEndIndex = index - 1;
        if preEndIndex < 1
            preEndIndex = 1;
        end
        preWinCount = preEndIndex - preBegIndex + 1;
        preGap = voteWinLength - preWinCount;
    end

    function [bakBegIndex, bakEndIndex, bakGap] = getBakWinIndex(index, lengOfData, voteWinLength, frequency)
        bakBegIndex = index + frequency;
        if bakBegIndex > lengOfData
            bakBegIndex = lengOfData;
        end
        bakEndIndex = index + frequency + voteWinLength - 1;
        if bakEndIndex > lengOfData
            bakEndIndex = lengOfData;
        end    
        bakWinCount = bakEndIndex - bakBegIndex + 1;
        bakGap = voteWinLength - bakWinCount;     
    end

    function [real_mutation_pos] = findRealMutationPosition(raw_labels)
        t_array = zeros(length(raw_labels),1);
        k = 1;
        for i = 2 : length(raw_labels)
            if raw_labels(i) - raw_labels(i-1) ~= 0
               t_array(k) = i;
               k = k + 1;
            end
        end
        real_mutation_pos = t_array(1:k-1);
     end

    function [merge_locs] =  mergeLocs(merge_locs, locs, ind) 
        for j = 1 : length(locs)
           merge_locs(j, ind) = locs(j); 
        end
    end

    function res_label= getRawLabelForTarget(cachedData, targetId)
        id_data = cachedData(:,1);
        acti_label = cachedData(:,2);  
        res_label = acti_label(id_data == targetId);
    end

    function targetId = getId(mapForNameAndId ,targetName)
         targetId = str2num(mapForNameAndId.(targetName)(3:end));    
    end

    function targetName = getName(mapForIdAndName, testId)
        keyName = strcat('id',num2str(testId));
        targetName = mapForIdAndName.(keyName);
        ttmp = strsplit(targetName, '.');
        targetName = ttmp{1,1};
    end

    function segmentPos = getSegment(mapForSegmentation, targetName)
        segmentPos = mapForSegmentation.(targetName);
    end

    function mutatePos = getMutateLabelPos(predictedLabel, mutateLabel)
        mutatePos = zeros(100,1);
        k = 1;
        j = 1;
        for i = 1 : length(predictedLabel)
            if i < j
                continue
            end
            if predictedLabel(i) == mutateLabel
               j = i + 1;
               while j < length(predictedLabel) && predictedLabel(j) == predictedLabel(j - 1)
                   j = j + 1;
               end
               mutatePos(k) = j - 1;
               k = k + 1;
               i = j;
            end
        end
        mutatePos = mutatePos(1:k);
    end

end