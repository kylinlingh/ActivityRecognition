
function minLength = getMinLengthOfSameActivity(cachedData)
% ��ȡͬһ���������������ʱ��
    rawLabel = cachedData(:,2);

    minLength = intmax;
    preLabel = rawLabel(1);
    labelCount = 1;
    for i = 2 : length(rawLabel)
        curLabel = rawLabel(i);
        if curLabel ~= preLabel 
            if labelCount < minLength
               minLength = labelCount; 
    %           fprintf("%d - %d\n",i, min_length);
            end
            labelCount = 1;
            preLabel = curLabel;
        else
            labelCount = labelCount + 1;
        end
    end
end