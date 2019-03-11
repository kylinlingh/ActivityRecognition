function [rawAxisData, rawAxisLabel] = extractSingleAxisDataFromRawData(cachedData, targetAxis, targetId)
    id = cachedData(:,1);
    label = cachedData(:,2);

    switch targetAxis
        case 'x', component = 4;
        case 'y', component = 5;
        case 'z', component = 6;
    end
    axisData = cachedData(:,component);

    rawAxisData = axisData(id == targetId);
    rawAxisLabel = label(id == targetId);
end