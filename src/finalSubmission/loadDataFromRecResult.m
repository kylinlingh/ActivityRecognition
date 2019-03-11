function [targetName, predictedLabel, targetSegmentPos, targetRawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation)

% ��ȡָ�����û�id��Ӧ��ʶ�������������������ݣ�
% predictedLabel: �û�ʶ������Ķ�����ǩ
% targetSegmentPos���Ӹ��û���ԭʼ��������������ȡ���Ķ����л���ѡλ��
% targetRawLabel���û�ʵ�ʵĶ�����ǩ

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