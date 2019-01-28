pathRoot = 'E:\matlab_workspace\dataset\HKUSTleft\';
handSide = 'left';
mapForIdAndName = loadDataFromDir(pathRoot, handSide);

%% Right handside
pathRoot = 'E:\matlab_workspace\dataset\HKUSTright\';
handSide = 'right';
mapForIdAndName = loadDataFromDir(pathRoot, handSide);
%%

function mapForIdAndName = loadDataFromDir(pathRoot, handSide)
    list = dir(fullfile(pathRoot));
    fileNum = size(list, 1) - 2;
    mergeAll = [];
    lengthAll = 0;
    mapForIdAndName = struct();
    mapForNameAndId = struct();
    for k = 3 : fileNum + 2
       filePath = strcat(pathRoot, list(k).name);
       fprintf("%s\n", filePath);
       tmpTable = csvread(filePath, 1, 0);
       tmpId = ones([length(tmpTable), 1]) * (k - 2);
       tmpTable = [tmpTable tmpId]; % add user id to the matrix
       
       ttmp = strsplit(list(k).name, '.');
       targetName = ttmp{1,1};
       mapForIdAndName.(strcat('id',num2str(k-2))) = targetName;
       mapForNameAndId.(targetName) = strcat('id',num2str(k-2));
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
    save mapForIdAndName.mat mapForIdAndName;
    save mapForNameAndId.mat mapForNameAndId;
end