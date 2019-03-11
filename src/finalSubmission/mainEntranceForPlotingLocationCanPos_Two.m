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

%% 获取目标的识别结果和平滑后的结果,作图所用的用户id为：10, 21
testId = 10;
[targetName, predictedLabel, targetSegmentPos, targetRawLabel] = ...
    loadDataFromRecResult(testId, cachedData, mapForIdAndName, mapForSegmentation);

[canSwitchedPosFromSmoothedRecResult, smoothedRecLabel] = ...
getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);

realSwitchedPos = getRealSwitchedPos(targetRawLabel);

%plotSmoothedRecResultForSingleOne(predictedLabel, smoothedRecLabel);
%% 在平滑后的识别结果上寻找动作切换定位点
%plotCanPosForSmoothedRecResult(smoothedRecLabel, realSwitchedPos, canSwitchedPosFromSmoothedRecResult);

%% 计算全部人的混淆矩阵

[truePositiveCount, falsePositiveCount, falseNegativeCount] = ...
    calculateConfusionMatrixForRecResult(cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);

