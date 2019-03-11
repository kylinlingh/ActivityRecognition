function [predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)

% ��ȡ���ݣ���ô�ԭʼ������Ķ����л���ѡλ��
[targetName, predictedLabel, canSwitchedPosFromRawData, rawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation);
dataLen = length(predictedLabel);

% ��ȡ��ʵ�Ķ����л�λ�ã�������ͼ�Ƚ�
realSwitchedPos = getRealSwitchedPos(rawLabel);

% ƽ��Ԥ����������Ԥ�������ö����л���ѡλ��
[canSwitchedPosFromSmoothedRecResult, smoothedRecLabel] = ...
getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);

% reviCanSwitchedPos = mergeInWinLen(reviCanSwitchedPos, 10000);

% �ϲ����ֺ�ѡλ��
resMergeSwitchedPosFromRawDataAndSmoothedRecognitionResult = sort([canSwitchedPosFromRawData, canSwitchedPosFromSmoothedRecResult']);
validMergeSwitchedPos = screenValidPos(resMergeSwitchedPosFromRawDataAndSmoothedRecognitionResult, 300);

% ���룬����Ҫ��ǰ������������꣬����׼ȷ�ʴ��
validMergeSwitchedPos = [1, validMergeSwitchedPos, length(predictedLabel)];

% ���ݺ�ѡλ�ã��޸�ʶ����
revisedLabel = reviseFunc(predictedLabel ,validMergeSwitchedPos);

    function revisedResult = reviseFunc(predictedLabel, validMergeSwitchedPos)
        revisedResult = predictedLabel;

        % ���ݺ�ѡ�����޸�Ԥ����    
        
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