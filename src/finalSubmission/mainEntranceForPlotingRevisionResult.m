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

%% ��ȡĿ���ʶ������ƽ����Ľ��,��ͼ���õ��û�idΪ��22
testId = 22;
[predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);
[canSwitchedPosFromSmoothedRecResult, smoothedRecLabel] = ...
getCanPosFromRecResult(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);

plotRevisionResult(predictedLabel, smoothedRecLabel, revisedLabel);