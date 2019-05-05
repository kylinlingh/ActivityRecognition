function [labelCount, percent] = statiscsActivitiesDataDistribution(cachedData)
    rawLabel = cachedData(:,2);
    labelCount = zeros(10,1);
    percent = zeros(10,1);
    for i = 1 : length(rawLabel)
       curLabel = rawLabel(i)+1;
       labelCount(curLabel) = labelCount(curLabel) + 1;
    end
    
    for i = 1 : 10
       percent(i) = labelCount(i) / length(rawLabel);        
    end
    
end