
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
idAndNamemapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForIdAndName.mat');
nameAndIdmapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForNameAndId.mat');
segmentResultPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForSegmentation.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');
load(cacheDataPath);
load(idAndNamemapPath);
load(segmentResultPath);
load(nameAndIdmapPath);
%%
% 一个动作的切换点存在以下几种情况：

% 容易处理的情况：
% 1. 该点被动作切换定位算法找出来
% 2. 该点被识别出来（标签为8）
% 3. 该点即没有被定位算法找出来，也没有被识别出来，但是两边的标签很干净且不相同

% 难以处理的情况：
% 该点的两侧不干净，虽然有标签的突变，但是并不能肯定


% 原理：
% 识别结果为8就表示该处大概率（但并不绝对，因为识别结果本身可能存在错误）存在一个动作的切分位置
% 动作切分算法找到的切分位置表示该处大概率（但不绝对，因为原始信号存在噪音，会影响切分算法的准确性）存在一个动作的切分位置

% 算法流程：
% 首先找到识别结果为8的位置，然后往前往后检查一个窗口内是否存在切分候选点，存在的话就认为该处存在一个切分点，如果不存在，
%   则往前往后搜索看是否存在一个干净的识别结果的变换点（所谓干净，指的是这个变换点的前后窗口内没有电平的高频率变换）
% 同样地，从候选的切换点往前往后搜索一个干净的识别结果变换点，如果存在就认为该处也有一个动作的切换点
% 候选点的选择应该是排查其两侧的标签是否相同，如果相同则表明该候选点无效
% 
% 切换点选择原则是尽量往最干净的候选位置靠拢
% 

% 程序开发时使用的testId=5

testId = 31;
[targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);
predictedMutation = locateLabel8(predictedLabel);
realMutationPos = findRealMutationPosition(targetRawLabel);
%%
checkWin = 100;
dataLen = length(predictedLabel);
[strongPossibility, remPredictedMutation, remTargetSegmentPos] = getStrongPossibility(predictedMutation, targetSegmentPos, dataLen, checkWin);

checkPredictedWin = 2000;
weakPossibilityWithPredictedLabel = checkPredictedMutation(predictedLabel ,remPredictedMutation, checkPredictedWin);

checkSegmentWin = 100;
weakPossibilityWithSegmentPos = checkSegmentPosValid(predictedLabel ,remTargetSegmentPos, checkSegmentWin);

mergeWin = 1000;
mergeWeakCandidatePos = mergePredictionAndSegment(weakPossibilityWithPredictedLabel, weakPossibilityWithSegmentPos, dataLen, mergeWin);

voteWinLength = 500;
rawDataCandidatePos = findCleanMutation(predictedLabel, 500);
%%
[revisedMutationPos, reviseLabel] = testReviseSingleOne(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);
revisedMutationPos = mergeInWinLen(revisedMutationPos, 10000);

mergeAllPos = [strongPossibility, mergeWeakCandidatePos, rawDataCandidatePos ];
mergeAllPos = sort(mergeAllPos);

mMergeAllPos = mergeInWinLen(mergeAllPos, 100);
%% 合并全部候选点, 效果显示较好的有32，
% 找出结果修正后的候选点，记为新候选点
% 轮询修正前的候选点，如果两个相邻的候选点之间存在一个新的候选点就采用，如果存在多余一个的候选点，就评估概率：距离每大于2000就认为新的候选点有效
% 对两个候选点之间的标签进行少数服从多数的原则投票

[resMergeAll, resMergeAllFlag] = mergeWithRevisedPos(mMergeAllPos, revisedMutationPos, 1000);
%drawPredictionMergeAll(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation, realMutationPos, mMergeAllPos, revisedMutationPos, resMergeAll );

%% 将识别结果、原始标签、切分线综合起来

% 对比实验一
% 直接合并原始信号里的切换点与修正后的切换点
% 结果显示平均低0.7到2个百分点，一般是0.997和0.989的区别

resMergeSwitchedPosOfRawDataAndRevisied = sort([targetSegmentPos, revisedMutationPos]);
mergeSwitchedPosOfRawDataAndRevisied = mergeTwoArray(resMergeSwitchedPosOfRawDataAndRevisied, 300);
drawPredictionMergeAll(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation, realMutationPos, mMergeAllPos, revisedMutationPos, mergeSwitchedPosOfRawDataAndRevisied );

mutationCanPos = [1, mergeSwitchedPosOfRawDataAndRevisied, length(targetRawLabel)];
[revisedResult, revisiedPercision] = calPercision(targetRawLabel, mutationCanPos);
minLen = min(length(predictedLabel), length(targetRawLabel));

validLength = length(predictedLabel);
validRawData = targetRawLabel(1:validLength);
predictedPercision = mean(validRawData == (predictedLabel+1));


figure;
plot(targetRawLabel, 'b-');
hold on;
plot(revisedResult+1, 'r-');
titleStr = ['Target: ' num2str(testId) ',predicted percison: ' num2str(predictedPercision)  ' ,revised Percision: ' num2str(revisiedPercision)];
title(titleStr);
legend('raw label', 'revised label');








%%

function res = getMaxCountLabel(inputArray)
        table = tabulate(inputArray);
        [~, idx] = max(table(:, 2));
        res = table(idx);
end

function [revisedResult, percision] = calPercision(targetRawLabel, mutationCanPos)
    revisedResult = zeros(length(targetRawLabel), 1);
    
    % 根据候选点来修复预测结果
    for i = 1 : length(mutationCanPos) - 1   
        preIn = ceil(mutationCanPos(i));
        bakIn = ceil(mutationCanPos(i+1));
        validData = targetRawLabel(preIn : bakIn);
        maxLabel = getMaxCountLabel(validData);
        revisedResult(preIn : bakIn) = ones(1,bakIn - preIn + 1) * maxLabel;
    end
    
    % 然后计算准确率
    percision = mean(revisedResult == targetRawLabel);
end

function res = mergeTwoArray(array, mergeWinLen)
    res = [array(1)];
    j = 1;
    for i = 2 : length(array)
        if array(i) - res(j) < mergeWinLen
             res(j) = ceil((array(i) + res(j))/2);
        else
            j = j + 1;
            res(j) = array(i);
        end
    end
end

function [res, resFlag] = mergeWithRevisedPos(mMergeAllPos, revisedMutationPos, mergeWin)

    mMergeAllLen = length(mMergeAllPos);
    mrevisedMutationLen = length(revisedMutationPos);
    resFlag = [];
    res = [];
    i = 1;
    j = 1;
    while i <= mMergeAllLen && j <= mrevisedMutationLen
       if mMergeAllPos(i) < revisedMutationPos(j)
           bakLimit = mMergeAllPos(i) + mergeWin;
           tmpMeanWin = [mMergeAllPos(i)];
           while j <= mrevisedMutationLen && revisedMutationPos(j) <= bakLimit
               tmpMeanWin = [tmpMeanWin, revisedMutationPos(j)];
              j = j + 1; 
           end
           res = [res, mean(tmpMeanWin)];
           resFlag = [resFlag, 1];
           i = i + 1;
       else
           bakLimit = revisedMutationPos(j) + mergeWin;
           tmpMeanWin = [revisedMutationPos(j)];
           while i <= mMergeAllLen && mMergeAllPos(i) <= bakLimit
              tmpMeanWin = [tmpMeanWin, revisedMutationPos(j)];
              i = i + 1; 
           end
           res = [res, mean(tmpMeanWin)];
           resFlag = [resFlag, 0];
           j = j + 1;
       end       
    end
    while i <= mMergeAllLen
       res = [res, mMergeAllPos(i)];
           resFlag = [resFlag, 1];
           i = i + 1;
    end
    while j <= mrevisedMutationLen
        res = [res, revisedMutationPos(j)];
        resFlag = [resFlag, 0];
        j = j + 1;
    end
      
end

function drawPredictionMergeAll(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation, realMutationPos, mergeAllPos, revisedMutationPos, resMergeAll )
    % testId = 10;
    [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);
    axis_data = predictedLabel;
    sampling_rate = 50;
    t = (1/sampling_rate) * (0:length(axis_data)-1)';

    figure;
    plot(axis_data, '-b', 'LineWidth', 1);
    title_str = ['Recognition result of user id: ' num2str(testId)];
    title(title_str);
    xlabel('Time(sec)');
    ylabel('Activity label');
    hold on;
    for i = 1 : length(targetSegmentPos)
        plot([targetSegmentPos(i), targetSegmentPos(i)],[0, 10], 'c--','LineWidth',1);
        hold on;
    end
%    plot(targetRawLabel, 'r-', 'LineWidth', 1);
%    hold on;
    
%    ytmp = ones(length(predictedMutation),1) * 8.5;
%    plot(predictedMutation, ytmp, 'gv');
%    hold on;
    
    yytmp = ones(length(realMutationPos),1) * 8.5;
    plot(realMutationPos, yytmp, 'mo');
    hold on;
     
%    yytmp = ones(length(mergeAllPos),1) * 9;
%    plot(mergeAllPos, yytmp, 'r*');
%    hold on;
    
%    yytmp = ones(length(revisedMutationPos),1) * 9.5;
%    plot(revisedMutationPos, yytmp, 'r*');
%    hold on;
    
    yytmp = ones(length(resMergeAll),1) * 9.8;
    plot(resMergeAll, yytmp, 'r*');
    hold on;
end

function drawPrediction(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation, realMutationPos, predictedMutation, strongPossibility, weakPossibilityWithPredictedLabel, weakPossibilityWithSegmentPos, mergeWeakCandidatePos, checkRes)
    % testId = 10;
    [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);
    axis_data = predictedLabel;
    sampling_rate = 50;
    t = (1/sampling_rate) * (0:length(axis_data)-1)';

    figure;
    plot(axis_data, '-b', 'LineWidth', 1);
    title_str = ['Recognition result of user id: ' num2str(testId)];
    title(title_str);
    xlabel('Time(sec)');
    ylabel('Activity label');
    hold on;
    for i = 1 : length(targetSegmentPos)
        plot([targetSegmentPos(i), targetSegmentPos(i)],[0, 10], 'c--','LineWidth',1);
        hold on;
    end
    plot(targetRawLabel, 'r-', 'LineWidth', 1);
    hold on;
    
%    ytmp = ones(length(predictedMutation),1) * 8.5;
%    plot(predictedMutation, ytmp, 'gv');
%    hold on;
    
    yytmp = ones(length(realMutationPos),1) * 0.5;
    plot(realMutationPos, yytmp, 'mv');
    hold on;

    yytmp = ones(length(strongPossibility),1) * 8.3;
    plot(strongPossibility, yytmp, 'rv');
    hold on;
    
    yytmp = ones(length(weakPossibilityWithPredictedLabel),1) * 9;
    plot(weakPossibilityWithPredictedLabel, yytmp, 'k<');
    hold on;
    
    yytmp = ones(length(weakPossibilityWithSegmentPos),1) * 9.3;
    plot(weakPossibilityWithSegmentPos, yytmp, 'k>');
    hold on;
    
    
    yytmp = ones(length(mergeWeakCandidatePos),1) * 9.5;
    plot(mergeWeakCandidatePos, yytmp, 'rv');
    hold on;
    
    
    yytmp = ones(length(checkRes),1) * 9.7;
    plot(checkRes, yytmp, 'r*');
    hold on;
end

function res = mergeInWinLen(allData, winLen)
    i = 1;
    res = [];
    while i <= length(allData)
       bakLimit = allData(i) + winLen;
       j = i + 1;
       while j <= length(allData) && allData(j) <= bakLimit
            j = j + 1;
       end
       res = [res, allData(i)];
       i = j;
    end 
end

function checkRes = findCleanMutation(predictedLabel, checkCleanWin)
% 在预测的标签上检测是否存在这样的候选点：两侧的标签都干净，并且不相同
    checkRes = [];
    
    for i = checkCleanWin + 2 : length(predictedLabel) - checkCleanWin - 2
        if predictedLabel(i) == 8
           continue; 
        end
       curPos = predictedLabel(i); 
       preEndIn = i - 1;
       preBegIn = preEndIn - checkCleanWin;  
       bakBegIn = i + 1;
       bakEndIn = bakBegIn + checkCleanWin;
       
       preCheckData = predictedLabel(preBegIn : preEndIn);
       bakCheckData = predictedLabel(bakBegIn : bakEndIn);
       
       preFlag = checkSameWin(preCheckData);
       bakFlag = checkSameWin(bakCheckData);
       
       if (preFlag == 1 && bakFlag == 1) && preCheckData(1) ~= bakCheckData(1) && preCheckData(1) ~= 8 && bakCheckData(1) ~= 8
          checkRes = [checkRes, i]; 
       end
       
    end

end

function res = checkSegmentPosValid(predictedLabel ,targetSegmentPos, checkSegmentWin)
% 检查切换点两侧的标签是否一致，如果一致则表明这个切换点无效
    res = [];
    for i = 1 : length(targetSegmentPos)
       curMutation = targetSegmentPos(i);
       ppreBegIndex = curMutation - checkSegmentWin;
       if ppreBegIndex < 1
           ppreBegIndex = 1;
       end
       bbakEndIndex = curMutation + checkSegmentWin;
       if bbakEndIndex > length(predictedLabel)
           bbakEndIndex = length(predictedLabel);
       end
       
       ppreEndIndex = curMutation - 1;
       bbakBegIndex = curMutation + 1;
       
       ppreWinData = predictedLabel(ppreBegIndex : ppreEndIndex);
       bbakWinData = predictedLabel(bbakBegIndex : bbakEndIndex);
       
       ppreflag = checkSameWin(ppreWinData);
       bbakflag = checkSameWin(bbakWinData);
       
       if ppreflag == 1 && bbakflag == 1 && ppreWinData(1) == bbakWinData(1)
           % clean
           continue;
       end       
       res = [res, curMutation];
    end
end

function  res = mergePredictionAndSegment(weakPossibilityWithPredictedLabel, weakPossibilityWithSegmentPos, dataLen, mergeWin)
   
    res = zeros(1, length(weakPossibilityWithPredictedLabel) + length(weakPossibilityWithSegmentPos));
    kkk = 1;
    aaa = 1;
    iii = 1;
    while iii <= length(weakPossibilityWithPredictedLabel)
       curPosi = weakPossibilityWithPredictedLabel(iii);
       preBeg = curPosi - mergeWin;
       bakEnd = curPosi + mergeWin;
       if preBeg < 1
           preBeg = 1
       end
       if bakEnd > dataLen
           bakEnd = dataLen
       end
            
       if kkk <= length(weakPossibilityWithSegmentPos) && weakPossibilityWithSegmentPos(kkk) < preBeg
           res(aaa) = weakPossibilityWithSegmentPos(kkk);
           aaa = aaa + 1;
           kkk = kkk + 1;
           continue;
       end
       
       if kkk <= length(weakPossibilityWithSegmentPos) && weakPossibilityWithSegmentPos(kkk) > bakEnd
          res(aaa) = curPosi;
          aaa = aaa + 1;
          iii = iii + 1;
          continue;
       end
       
       if kkk <= length(weakPossibilityWithSegmentPos) && weakPossibilityWithSegmentPos(kkk) >= preBeg && weakPossibilityWithSegmentPos(kkk) <= bakEnd
           while kkk <= length(weakPossibilityWithSegmentPos) && weakPossibilityWithSegmentPos(kkk) >= preBeg && weakPossibilityWithSegmentPos(kkk) <= bakEnd
              kkk = kkk + 1; 
           end
           res(aaa) = curPosi;
           aaa = aaa + 1;
           iii = iii + 1;
       end
       
       if kkk > length(weakPossibilityWithSegmentPos)
          res(aaa) = curPosi;
          aaa = aaa + 1;
          iii = iii + 1;
       end
         
    end
    res = res(1:aaa-1);
end

function res = checkSegmentPosClean(predictedLabel ,targetSegmentPos, checkSegmentWin)
% 检查识别标签为8的点附近是否干净，干净的定义就是在前后一个检查窗口内没有其他标签的结果
    res = [];
    for i = 1 : length(targetSegmentPos)
       curMutation = targetSegmentPos(i);
       ppreBegIndex = curMutation - checkSegmentWin;
       if ppreBegIndex < 1
           ppreBegIndex = 1;
       end
       bbakEndIndex = curMutation + checkSegmentWin;
       if bbakEndIndex > length(predictedLabel)
           bbakEndIndex = length(predictedLabel);
       end
       
       ppreEndIndex = curMutation - 1;
       bbakBegIndex = curMutation + 1;
       
       ppreWinData = predictedLabel(ppreBegIndex : ppreEndIndex);
       bbakWinData = predictedLabel(bbakBegIndex : bbakEndIndex);
       
       ppreflag = checkSameWin(ppreWinData);
       bbakflag = checkSameWin(bbakWinData);
       
       if ppreflag == 1 || bbakflag == 1
           % clean
           res = [res, curMutation];
       end       

    end
end

function res = checkPredictedMutation(predictedLabel ,remPredictedMutation, checkPredictedWin)
% 检查识别标签为8的点附近是否干净，干净的定义就是在前后一个检查窗口内没有其他标签的结果
    res = [];
    for i = 1 : length(remPredictedMutation)
       curMutation = remPredictedMutation(i);
       j = curMutation;
       while j >= 1 && predictedLabel(j) == 8
           j = j - 1;
       end
       ppreBegIndex = j - checkPredictedWin;
       if ppreBegIndex < 1
           ppreBegIndex = 1;
       end
       bbakEndIndex = curMutation + checkPredictedWin;
       if bbakEndIndex > length(predictedLabel)
           bbakEndIndex = length(predictedLabel);
       end
       
       ppreEndIndex = j;
       bbakBegIndex = curMutation + 1;
       
       ppreWinData = predictedLabel(ppreBegIndex : ppreEndIndex);
       bbakWinData = predictedLabel(bbakBegIndex : bbakEndIndex);
       
       ppreflag = checkSameWin(ppreWinData);
       bbakflag = checkSameWin(bbakWinData);
       
       if (ppreflag == 1 || bbakflag == 1) && (ppreWinData(1) ~= bbakWinData(1))
           % clean
           res = [res, curMutation];
       end       

    end
end

function flag = checkSameWin(winData)
    tBeg = winData(1);
    flag = 1;
    for i = 2 : length(winData)
       if winData(i) ~= tBeg
           flag = 0;
           break;
       end
    end
end

function [res, remPredictedMutation, remTargetSegmentPos] = getStrongPossibility(predictedMutation, targetSegmentPos, dataLen, checkWin)
    
    k = 1;
    m = 1;
    flag = 0;
    ii = 1;
    res = zeros(1, length(predictedMutation));
    kk = 1;
    remPredictedMutation = zeros(1, length(predictedMutation));
    remTargetSegmentPos = zeros(1, length(targetSegmentPos));
    
    while ii <= length(predictedMutation) && k <= length(targetSegmentPos)
        curPos = predictedMutation(ii);
        [preIndex, bakIndex] = getIndexTmp(dataLen, curPos, checkWin);
        
        if targetSegmentPos(k) < preIndex
           remTargetSegmentPos(kk) = targetSegmentPos(k);
           k = k + 1;  
           kk = kk + 1;
           continue;
        end
        
        if targetSegmentPos(k) > bakIndex
            ii = ii + 1; 
            continue;
        end
        
        while k <= length(targetSegmentPos) && targetSegmentPos(k) >= preIndex && targetSegmentPos(k) <= bakIndex
            flag = 1;
            k = k + 1;
           % ii = ii + 1;
        end
        if flag == 1
           res(m) = curPos; 
           flag = 0;
           m = m + 1;
        end
    end
    
    while ii < length(predictedMutation)
        res(m) = predictedMutation(ii);
        ii = ii + 1;
    end
    
    
    res = res(1: m-1);
    
    mm = 1;
    nn = 1;
    oo = 1;
    while mm <= length(predictedMutation) && nn <= length(res)
       if predictedMutation(mm) == res(nn)
          nn = nn + 1;
          mm = mm + 1;
          continue;
       end      
       remPredictedMutation(oo) = predictedMutation(mm);
       mm = mm + 1;
       oo = oo + 1;
    end
    
    while mm <= length(predictedMutation) && nn > length(res)
       remPredictedMutation(oo) = predictedMutation(mm);
       mm = mm + 1;
       oo = oo + 1;
    end
    
    remPredictedMutation = remPredictedMutation(1:oo-1);
    remTargetSegmentPos = remTargetSegmentPos(1:kk-1);
end

function [resArray] = getStrongPossibility2(predictedMutation, targetSegmentPos, checkWin)
    [resArray, resFlag] = mergeWithRevisedPos(predictedMutation, targetSegmentPos, checkWin);
    
end

function [preIndex, bakIndex] = getIndexTmp(dataLen, curIndex, checkWin)
    preIndex = curIndex - checkWin;
    bakIndex = curIndex + checkWin;
    if preIndex < 1
        preIndex = 1;
    end
    if bakIndex > dataLen
        bakIndex = dataLen;
    end
end

function pos = locateLabel8(array)
    pos = zeros(1, length(array));
    index = 1;
    addin = 1;
    while index <= length(array)
       if array(index) == 8
          while index <= length(array) && array(index) == 8
              index = index + 1;
          end
          pos(addin) = index-1;
          addin = addin + 1;
       end
       index = index + 1;
    end
    pos = pos(1:addin-1);
end

function drawActivities(axis_data, x_title_str, sampling_rate, time_window)
    activity_count = 8;
    moving_average_win_len = 50;
    moving_average_axis_data = smooth(axis_data, moving_average_win_len);
    
    t = (1/sampling_rate) * (0:length(axis_data)-1)';
    figure;
    plot(t, axis_data, '-b', 'LineWidth', 1);
    hold on;
    plot(t,moving_average_axis_data, '-r', 'LineWidth',0.5);
    hold on;
    axis([0 time_window*activity_count min(axis_data) max(axis_data)]); % 去除作图后的空白区域

    title(x_title_str);
    xlabel('Time(sec)');
    set(gca, 'XTick', 0: time_window: time_window*activity_count);   % 设置x轴的刻度为每隔40个数显示一次
    ylabel('{Acceleration(m/s^2)}');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小
    hl = legend('Raw signal', 'Moving average', 'Location', 'southeast');
    set(hl, 'Orientation', 'horizon'); % 设置水平显示图线标志

end

function res_label= getRawLabelForTarget(cachedData, targetId)
    id_data = cachedData(:,1);
    acti_label = cachedData(:,2);  
    res_label = acti_label(id_data == targetId);
end
    
function segmentPos = getSegment(mapForSegmentation, targetName)
    segmentPos = mapForSegmentation.(targetName);
end

function targetId = getId(mapForNameAndId ,targetName)
     targetId = str2num(mapForNameAndId.(targetName)(3:end));    
end

function targetName = getName(mapForIdAndName, testId)
    keyName = strcat('id',num2str(testId));
    targetName = mapForIdAndName.(keyName);
    ttmp = strsplit(targetName, '.');
    targetName = ttmp{1,1};
end
    
function res = extractIndiData(cachedData, target_id)
    condition = cachedData(:,1) == target_id;
    res = cachedData(condition,:);
end

function [real_mutation_pos] = findRealMutationPosition(raw_labels)
        t_array = zeros(length(raw_labels),1);
        k = 1;
        for i = 2 : length(raw_labels)
            if raw_labels(i) - raw_labels(i-1) ~= 0
               t_array(k) = i;
               k = k + 1;
            end
        end
        real_mutation_pos = t_array(1:k-1);
end

function [targetName, targetId, predictedLabel, targetSegmentPos, targetRawLabel] = loadData(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation)
    targetName = getName(mapForIdAndName, testId);
    predictionResPath = sprintf('%s%s%s','E:\matlab_workspace\dataset\predictionResleft\predictionResult_', targetName, '.txt')
    %fprintf(predictionResPath);
    file = textscan(fopen(predictionResPath), '%d', 'Delimiter',',');
    
    predictedLabel = file{1,1};
    fprintf('length of predictedLabel: %d\n', length(predictedLabel));
    targetId = getId(mapForNameAndId, targetName);
    targetSegmentPos = getSegment(mapForSegmentation, targetName);
    targetRawLabel = getRawLabelForTarget(cachedData, targetId);
    fprintf('length of rawLabel: %d\n', length(targetRawLabel));
    fclose('all');
end