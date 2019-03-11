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

%% ��ȡĿ���ʶ������ƽ����Ľ��,��ͼ���õ��û�idΪ��10, 21
testId = 10;
[targetName, predictedLabel, targetSegmentPos, targetRawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation);

[canSwitchedPosFromSmoothedRecResult, smoothedRecLabel] = ...
getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);

realSwitchedPos = getRealSwitchedPos(targetRawLabel);

%plotSmoothedRecResultForSingleOne(predictedLabel, smoothedRecLabel);
%% ��ƽ�����ʶ������Ѱ�Ҷ����л���λ��
%plotCanPosForSmoothedRecResult(smoothedRecLabel, realSwitchedPos, canSwitchedPosFromSmoothedRecResult);

%% ����ȫ���˵Ļ�������

[truePositiveCount, falsePositiveCount, falseNegativeCount] = ...
    calculateConfusionMatrixForRecResult(cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);

