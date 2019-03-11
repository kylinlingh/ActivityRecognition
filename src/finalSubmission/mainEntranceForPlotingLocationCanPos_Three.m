
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

%% �ϲ�ȫ��������ѡ�㲢��ͼ����ͼ�û���27��28��26

figure;
testId = 27;
[predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);
subplot(311);
plotCanPosForThreeAxisFromRawData(validMergeSwitchedPos, realSwitchedPos, 'Merge All Candidated Positions');

testId = 28;
[predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);
subplot(312);
plotCanPosForThreeAxisFromRawData(validMergeSwitchedPos, realSwitchedPos, 'Merge All Candidated Positions');

testId = 26;
[predictedLabel,rawLabel,revisedLabel, canSwitchedPosFromRawData,canSwitchedPosFromSmoothedRecResult, validMergeSwitchedPos, realSwitchedPos ] = ...
    reviseRecognitionResult(testId, cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);
subplot(313);
plotCanPosForThreeAxisFromRawData(validMergeSwitchedPos, realSwitchedPos, 'Merge All Candidated Positions');

%% �����������
[truePositiveCount, falsePositiveCount, falseNegativeCount] = ...
    calculateConfusionMatrixForMergeCanPos(cachedData, mapForIdAndName,mapForNameAndId, mapForSegmentation);



