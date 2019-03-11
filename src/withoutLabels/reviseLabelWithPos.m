
function [predictedPercision, revisiedPercision] =  reviseLabelWithPos(testId, plotLabel,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)

%testId = 6;
[targetRawLabel, predictedLabel, canAllPos] =  getRevisedCandidatedPos2(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);

mutationCanPos = [1, canAllPos, length(predictedLabel)];
clearvars -except targetRawLabel mutationCanPos testId predictedLabel plotLabel
%%
[revisedResult] = reviseLabel(predictedLabel, mutationCanPos);

validLength = length(predictedLabel);
validRawData = targetRawLabel(1:validLength);
predictedPercision = mean(validRawData == (predictedLabel+1));
        
 % Ȼ�����׼ȷ��
cutRawLabel = targetRawLabel(1:length(revisedResult));
revisiedPercision = mean(revisedResult == cutRawLabel);

%% ������ı�ǩ��ԭʼ��ǩ�Ա�ͼ
if plotLabel == 1
    figure;
    plot(targetRawLabel, 'b-');
    hold on;
    plot(revisedResult+1, 'r-');
    titleStr = ['Target: ' num2str(testId) ',predicted percison: ' num2str(predictedPercision)  ' ,revised Percision: ' num2str(revisiedPercision)];
    title(titleStr);
    legend('raw label', 'revised label');
end
%%

function [revisedResult, percision] = reviseLabel(predictedLabel, mutationCanPos)
    revisedResult = predictedLabel;
    
    % ���ݺ�ѡ�����޸�Ԥ����
    for i = 1 : length(mutationCanPos) - 1   
        preIn = ceil(mutationCanPos(i));
        bakIn = ceil(mutationCanPos(i+1));
        validData = predictedLabel(preIn : bakIn);
        maxLabel = getMaxCountLabel(validData);
        revisedResult(preIn : bakIn) = ones(bakIn - preIn + 1,1) * (maxLabel+1);
    end   
end

function [revisedResult, percision] = reviseLabelAndCalPercision2(targetRawLabel, mutationCanPos)
    revisedResult = zeros(length(targetRawLabel), 1);
    
    % ���ݺ�ѡ�����޸�Ԥ����
    for i = 1 : length(mutationCanPos) - 1   
        preIn = ceil(mutationCanPos(i));
        bakIn = ceil(mutationCanPos(i+1));
        validData = targetRawLabel(preIn : bakIn);
        maxLabel = getMaxCountLabel(validData);
        revisedResult(preIn : bakIn) = ones(1,bakIn - preIn + 1) * maxLabel;
    end
    
    % Ȼ�����׼ȷ��
    percision = mean(revisedResult == targetRawLabel);
    
end

function res = getMaxCountLabel(inputArray)
        table = tabulate(inputArray);
        [~, idx] = max(table(:, 2));
        res = table(idx);
end

end
