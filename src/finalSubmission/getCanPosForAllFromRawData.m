% 找出所有人的候选动作切换点，并输出到文件中
%% 加载缓存数据
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_ALL_HANDS.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');
mapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForIdAndName.mat');

load(cacheDataPath);
load(mapPath);

minLength = getMinLengthOfSameActivity(cachedData);
clearvars -except cachedData mapForIdAndName minLength
%% 测试单个人的结果
targetId = 15;

preWinThreshold = 5.5;  
bakWinThreshold = 0.2;
checkWinLen = 3;

[rawLabel, canSwitchedPos, realSwitchedPos] = ...
    getCanPosForSingleOneFromRawData(cachedData, minLength, targetId, preWinThreshold, bakWinThreshold, checkWinLen);
figure;
drawCanSwitchedPosFromRawData(rawLabel, canSwitchedPos, targetId, preWinThreshold, bakWinThreshold, checkWinLen);

%% 找出所有人的候选动作切换点
preWinThreshold = 5.5;  
bakWinThreshold = 0.2;
checkWinLen = 3;
frequency = 25;
mapForAllCanSwitchedPos = struct();

for id = 1:34
    fprintf('Processing id: %d \n', id);
    targetId = id;
    [rawLabel, canSwitchedPos, realSwitchedPos] = ...
        getCanPosForSingleOneFromRawData(cachedData, minLength, targetId, preWinThreshold, bakWinThreshold, checkWinLen);
    key = strcat('id',num2str(id));
    value = mapForIdAndName.(key);
    tmp = regexp(value, '\.', 'split');
    name = cell2mat(tmp(1));
    mapForAllCanSwitchedPos.(name) = canSwitchedPos';
end

%% 将找到的全部候选点输出到文件中
writeToTxt(mapForAllCanSwitchedPos, 'left');
save mapForSegmentation.mat mapForAllCanSwitchedPos;

%% 
function drawCanSwitchedPosFromRawData(raw_label, predict_loc, target_id, pre_threshold, bak_threshold, check_win)
% 绘制所有候选的动作切换点
        % figure;
        plot(raw_label, 'g-', 'LineWidth', 1);
        hold on;
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 10], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw label of target id: ', num2str(target_id) ];
        title(t_title);
        xlabel(['pre threshold: ', num2str(pre_threshold),' bak threshold: ', num2str(bak_threshold)]);
        ylabel(['check win: ',num2str(check_win)]);
        legend('raw_label', 'predicted position');
        hold off;
end

function writeToTxt(mapForSegmentation, handSide)
    if strcmp(handSide, 'left')
        fileId = fopen('SegmentResult_left.txt', 'w');
    elseif strcmp(handSide, 'right')
        fileId = fopen('SegmentResult_right.txt', 'w');
    else
        fileId = fopen('SegmentResult_both.txt', 'w');
    end
    
    nameArray = fieldnames(mapForSegmentation);
    for i = 1:length(nameArray)
       name = cell2mat(nameArray(i));
       fprintf(fileId, '%s ', name);
       valueArray = mapForSegmentation.(name);
       for j = 1 : length(valueArray)
          fprintf(fileId, '%d ', valueArray(j));
       end
       fprintf(fileId, '\n');
    end
end