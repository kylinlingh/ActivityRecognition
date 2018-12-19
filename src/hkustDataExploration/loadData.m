pathRoot = 'E:\matlab_workspace\dataset\HKUSTleft\';
handSide = 'left';
loadDataFromDir(pathRoot, handSide);

pathRoot = 'E:\matlab_workspace\dataset\HKUSTright\';
handSide = 'right';
loadDataFromDir(pathRoot, handSide);

function loadDataFromDir(pathRoot, handSide)
    list = dir(fullfile(pathRoot));
    fileNum = size(list, 1) - 2;
    mergeAll = [];
    lengthAll = 0;
    for k = 3 : fileNum
       filePath = strcat(pathRoot, list(k).name);
       tmpTable = csvread(filePath, 1, 0);
       tmpId = ones([length(tmpTable), 1]) * (k - 2);
       tmpTable = [tmpTable tmpId]; % add user id to the matrix
       fprintf("%s\n", filePath);
       mergeAll = [mergeAll;tmpTable];
       lengthAll = lengthAll + length(tmpTable);
    end
    
    xAxis = mergeAll(:, 1);
    yAxis = mergeAll(:, 2);
    zAxis = mergeAll(:, 3);
    label = mergeAll(:, 4);
    id = mergeAll(:, 5);
    timestamp = zeros([lengthAll,1]);
    cachedData = [id label timestamp xAxis yAxis zAxis];
    
    if strcmp(handSide, 'left')
       save HKUST_LEFT_HAND.mat cachedData;
    elseif strcmp(handSide, 'right')
       save HKUST_RIGHT_HAND.mat cachedData; 
    else
       save HKUST_ALL_HAND.mat cachedData; 
    end
end