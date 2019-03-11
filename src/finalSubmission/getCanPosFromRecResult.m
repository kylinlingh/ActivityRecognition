function [revCanSwitchedPos, smoothedRecLabel] = ...
getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData)
% ƽ��ʶ����
% ��ƽ�����ʶ�������ȡ�����л���ѡλ��

% ��ȡ��ԭʼ�ź����ݷ����㷨��Ķ����л�λ��
[targetName, predictedLabel, canPosFromRawData, targetRawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation);

%%
voteWinLength = 500;
% ʹ�û���������ƽ������
reviseLabelOnce = smoothRecResultFunc(predictedLabel, voteWinLength);
smoothedRecLabel = reviseLabelOnce;

% ��ȡƽ�����ݵĶ����л�λ��
revCanSwitchedPos = getRealSwitchedPos(smoothedRecLabel);

%drawRevisionResult(targetRawLabel,targetSegmentPos, predictedLabel, testId, reviseLabel, rreviseLabel, targetName, predictedPercision, revisionPercision);
%drawRevisionResult(targetRawLabel,targetSegmentPos, predictedLabel, testId, reviseLabel, rreviseLabel, targetName, predictedPercision, lengthRevisionPercision);

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

    function smoothedLabel = smoothRecResultFunc(predictedLabel, voteWinLength)
        smoothedLabel = predictedLabel;
        douVotWinLen = 2*voteWinLength;
        dataLen = length(predictedLabel);
        smoothedLabel(1:douVotWinLen) = getMaxCountLabel(predictedLabel(1:douVotWinLen));
        smoothedLabel(dataLen-douVotWinLen : dataLen) = getMaxCountLabel(predictedLabel(dataLen-douVotWinLen : dataLen)); 

        for i = douVotWinLen + 1 : dataLen - douVotWinLen - 1
            preIndex = i - voteWinLength;
            bakIndex = i + voteWinLength;
            smoothedLabel(i) = getMaxCountLabel(predictedLabel(preIndex:bakIndex));
        end
    end

    function res = getMaxCountLabel(inputArray)
        table = tabulate(inputArray);
        [~, idx] = max(table(:, 2));
        res = table(idx);
    end


end


