
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
%% ��ͼչʾ�Ӵ��������ݻ�ö����л�λ��
targetId = 14;
preWinThreshold = 5.5;  
bakWinThreshold = 0.2;
checkWinLen = 3;
minActivityLen = getMinLengthOfSameActivity(cachedData);

[rawAxisOfX, rawLabel]  = extractSingleAxisDataFromRawData(cachedData, 'x', targetId);
[rawAxisOfY, ~]         = extractSingleAxisDataFromRawData(cachedData, 'y', targetId);
[rawAxisOfZ, ~]         = extractSingleAxisDataFromRawData(cachedData, 'z', targetId);

canSwitchedPosOfAxisX = getCanPosFromSingleAxisFromRawData(rawAxisOfX, minActivityLen, preWinThreshold, bakWinThreshold, checkWinLen);
canSwitchedPosOfAxisY = getCanPosFromSingleAxisFromRawData(rawAxisOfY, minActivityLen, preWinThreshold, bakWinThreshold, checkWinLen);
canSwitchedPosOfAxisZ = getCanPosFromSingleAxisFromRawData(rawAxisOfZ, minActivityLen, preWinThreshold, bakWinThreshold, checkWinLen);
[~, allCanSwitchedPos, ~] = ...
    getCanPosForSingleOneFromRawData(cachedData, minActivityLen, targetId, preWinThreshold, bakWinThreshold, checkWinLen);

realSwitchedPos = getRealSwitchedPos(rawLabel);
%clearvars -except targetId canSwitchedPosOfAxisX canSwitchedPosOfAxisY canSwitchedPosOfAxisZ rawAxisOfX rawAxisOfY rawAxisOfZ rawLabel realSwitchedPos allCanSwitchedPos rawLabel
%% չʾһ���������ԭʼ�������зֵ�
% ������ͼ��idΪ
plotCanPosForSingleAxisFromRawData(targetId, '(a)X-axis' ,rawAxisOfX, realSwitchedPos, canSwitchedPosOfAxisX);

%% Ȼ��չʾ������������зֵ㣬����չʾԭʼ����
figure;
subplot(311);
plotCanPosForThreeAxisFromRawData(canSwitchedPosOfAxisX, realSwitchedPos, '(a)X-axis');
subplot(312);
plotCanPosForThreeAxisFromRawData(canSwitchedPosOfAxisY, realSwitchedPos, '(b)Y-axis');
subplot(313);
plotCanPosForThreeAxisFromRawData(canSwitchedPosOfAxisZ, realSwitchedPos, '(c)Z-axis');

%% ���չʾ�ϲ������������л���Ľ��
figure;
plotCanPosForThreeAxisFromRawData(allCanSwitchedPos, realSwitchedPos, 'All Candidated Positions');

%% ����������
[truePositiveCount, falsePositiveCount, falseNegativeCount] = calculateConfusionMatrixFromRawData(cachedData);

