function [targetName, predictedLabel, targetSegmentPos, targetRawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation)

% 读取指定的用户id对应的识别结果，并返回以下内容：
% predictedLabel: 用户识别出来的动作标签
% targetSegmentPos：从该用户的原始传感器数据上提取到的动作切换候选位置
% targetRawLabel：用户实际的动作标签

    targetName = getName(mapForIdAndName, testId);
    predictionResPath = sprintf('%s%s%s','E:\matlab_workspace\dataset\predictionResleft\predictionResult_', targetName, '.txt')
    %fprintf(predictionResPath);
    file = textscan(fopen(predictionResPath), '%d', 'Delimiter',',');
    
    predictedLabel = file{1,1};
    %fprintf('length of predictedLabel: %d\n', length(predictedLabel));
    %targetId = getId(mapForNameAndId, targetName);
    targetSegmentPos = getSegment(mapForSegmentation, targetName);
    targetRawLabel = getRawLabelForTarget(cachedData, testId);
    %fprintf('length of rawLabel: %d\n', length(targetRawLabel));
    fclose('all');

    function res_label= getRawLabelForTarget(cachedData, targetId)
        id_data = cachedData(:,1);
        acti_label = cachedData(:,2);  
        res_label = acti_label(id_data == targetId);
    end

    function segmentPos = getSegment(mapForSegmentation, targetName)
        segmentPos = mapForSegmentation.(targetName);
    end

 %   function targetId = getId(mapForNameAndId ,targetName)
 %        targetId = str2num(mapForNameAndId.(targetName)(3:end));    
 %   end

    function targetName = getName(mapForIdAndName, testId)
        keyName = strcat('id',num2str(testId));
        targetName = mapForIdAndName.(keyName);
        ttmp = strsplit(targetName, '.');
        targetName = ttmp{1,1};
    end
end