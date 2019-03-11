
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
testId = 17;
[targetRawLabel, predictedLabel, reviseLabel, rreviseLabel, predictedPercision, revisionPercision, lengthRevisionPercision, targetName, mergeLocs] = ...
    reviseSingleOne(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);
%targetSegmentPos = mergeLocs(:,2);
%drawRevisionResult(targetRawLabel,targetSegmentPos, predictedLabel, testId, reviseLabel, rreviseLabel, targetName, predictedPercision, revisionPercision);



% mergeLocs的数据含义：
% 标签为8的数据位置
% 信号处理算法找到的动作切分位置
% 数据的真实切换位置
% 数据修正后的切换位置



%% Get everyone's accuracy percision
peopleCount = 34;
predictedAccuracy = zeros(1, peopleCount);
revisedAccuracy = zeros(1, peopleCount);
lengthRevisedAccuracy = zeros(1, peopleCount);
for i = 1 : peopleCount
    testId = i;
    [~, ~, ~, ~, predictedPercision, revisionPercision, lengthRevisionPercision, targetName, ~] = ...
    reviseSingleOne(testId, mapForIdAndName, mapForNameAndId, mapForSegmentation, cachedData);
    predictedAccuracy(i) = predictedPercision;
    revisedAccuracy(i) = revisionPercision;
    lengthRevisedAccuracy(i) = lengthRevisionPercision;
end
%%
figure;
xAxis = [1:34];
scatter(xAxis ,predictedAccuracy, 'b*');
hold on;
scatter(xAxis ,revisedAccuracy, 'g*');
hold on;
scatter(xAxis, lengthRevisedAccuracy, 'r*');
hold on;
plot(predictedAccuracy,'--o');
hold on;
plot(revisedAccuracy,'--o','LineWidth',1.5);
hold on;
plot(lengthRevisedAccuracy, '--o');
hold on;

legend('predictedAccuracy', 'revisedAccuracy', 'lengthRevisiedAccuracy','Location','SouthEast');
xlabel('target id');
ylabel('accuracy');

%%
%clearvars -except targetRawLabel predictedLabel rreviseLabel predictedPercision revisionPercision targetName mergeLocs


