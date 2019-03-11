
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
% һ���������л���������¼��������

% ���״���������
% 1. �õ㱻�����л���λ�㷨�ҳ���
% 2. �õ㱻ʶ���������ǩΪ8��
% 3. �õ㼴û�б���λ�㷨�ҳ�����Ҳû�б�ʶ��������������ߵı�ǩ�ܸɾ��Ҳ���ͬ

% ���Դ���������
% �õ�����಻�ɾ�����Ȼ�б�ǩ��ͻ�䣬���ǲ����ܿ϶�


% ԭ��
% ʶ����Ϊ8�ͱ�ʾ�ô�����ʣ����������ԣ���Ϊʶ����������ܴ��ڴ��󣩴���һ���������з�λ��
% �����з��㷨�ҵ����з�λ�ñ�ʾ�ô�����ʣ��������ԣ���Ϊԭʼ�źŴ�����������Ӱ���з��㷨��׼ȷ�ԣ�����һ���������з�λ��

% �㷨���̣�
% �����ҵ�ʶ����Ϊ8��λ�ã�Ȼ����ǰ������һ���������Ƿ�����зֺ�ѡ�㣬���ڵĻ�����Ϊ�ô�����һ���зֵ㣬��������ڣ�
%   ����ǰ�����������Ƿ����һ���ɾ���ʶ�����ı任�㣨��ν�ɾ���ָ��������任���ǰ�󴰿���û�е�ƽ�ĸ�Ƶ�ʱ任��
% ͬ���أ��Ӻ�ѡ���л�����ǰ��������һ���ɾ���ʶ�����任�㣬������ھ���Ϊ�ô�Ҳ��һ���������л���
% ��ѡ���ѡ��Ӧ�����Ų�������ı�ǩ�Ƿ���ͬ�������ͬ������ú�ѡ����Ч
% 
% �л���ѡ��ԭ���Ǿ�������ɾ��ĺ�ѡλ�ÿ�£
% 

% ���򿪷�ʱʹ�õ�testId=5

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
%% �ϲ�ȫ����ѡ��, Ч����ʾ�Ϻõ���32��
% �ҳ����������ĺ�ѡ�㣬��Ϊ�º�ѡ��
% ��ѯ����ǰ�ĺ�ѡ�㣬����������ڵĺ�ѡ��֮�����һ���µĺ�ѡ��Ͳ��ã�������ڶ���һ���ĺ�ѡ�㣬���������ʣ�����ÿ����2000����Ϊ�µĺ�ѡ����Ч
% ��������ѡ��֮��ı�ǩ�����������Ӷ�����ԭ��ͶƱ

[resMergeAll, resMergeAllFlag] = mergeWithRevisedPos(mMergeAllPos, revisedMutationPos, 1000);
%drawPredictionMergeAll(testId,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation, realMutationPos, mMergeAllPos, revisedMutationPos, resMergeAll );

%% ��ʶ������ԭʼ��ǩ���з����ۺ�����

% �Ա�ʵ��һ
% ֱ�Ӻϲ�ԭʼ�ź�����л�������������л���
% �����ʾƽ����0.7��2���ٷֵ㣬һ����0.997��0.989������

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
% ��Ԥ��ı�ǩ�ϼ���Ƿ���������ĺ�ѡ�㣺����ı�ǩ���ɾ������Ҳ���ͬ
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
% ����л�������ı�ǩ�Ƿ�һ�£����һ�����������л�����Ч
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
% ���ʶ���ǩΪ8�ĵ㸽���Ƿ�ɾ����ɾ��Ķ��������ǰ��һ����鴰����û��������ǩ�Ľ��
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
% ���ʶ���ǩΪ8�ĵ㸽���Ƿ�ɾ����ɾ��Ķ��������ǰ��һ����鴰����û��������ǩ�Ľ��
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
    axis([0 time_window*activity_count min(axis_data) max(axis_data)]); % ȥ����ͼ��Ŀհ�����

    title(x_title_str);
    xlabel('Time(sec)');
    set(gca, 'XTick', 0: time_window: time_window*activity_count);   % ����x��Ŀ̶�Ϊÿ��40������ʾһ��
    ylabel('{Acceleration(m/s^2)}');
    set(gca, 'FontSize', 20); % ���������������С
    hl = legend('Raw signal', 'Moving average', 'Location', 'southeast');
    set(hl, 'Orientation', 'horizon'); % ����ˮƽ��ʾͼ�߱�־

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