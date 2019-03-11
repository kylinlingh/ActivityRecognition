
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

%% 计算单人使用修正算法前后的准确率：24，5，10，31
testId = 6;
plotLabel = 0;
[predictedPercision, revisedPercision] = reviseLabelWithPos(testId, plotLabel,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);

%% 计算全部人使用修正算法前后准确率的对比图
peopleCount = 34;
predictedAccuracy = zeros(1, peopleCount);
revisedAccuracy = zeros(1, peopleCount);
plotLabel = 0;
for i = 1 : peopleCount
    testId = i;
    [predictedPercision, revisedPercision] = reviseLabelWithPos(testId, plotLabel,cachedData, mapForIdAndName, mapForNameAndId, mapForSegmentation);
    predictedAccuracy(i) = predictedPercision;
    revisedAccuracy(i) = revisedPercision;
end
%%
meanPredictedPercision = mean(predictedAccuracy);
meanRevisiedPercision = mean(revisedAccuracy);
%%
figure;
xAxis = [1:34];
scatter(xAxis ,predictedAccuracy, 'b*');
hold on;
scatter(xAxis ,revisedAccuracy, 'g*');
hold on;
plot(predictedAccuracy,'--o');
hold on;
plot(revisedAccuracy,'--o','LineWidth',1.5);
hold on;

legend('predictedAccuracy', 'revisedAccuracy', 'Location','SouthEast');
xlabel('target id');
ylabel('accuracy');