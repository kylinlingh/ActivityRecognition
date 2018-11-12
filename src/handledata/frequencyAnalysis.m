
figure;
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);

%% Parameter setting
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

fs = 20;
check_id = 33;
actstr = 'Walking';
%actstr = 'Upstairs';
actlabels = getActivityNames();
check_acti = find(strcmp(actlabels, actstr));
check_axis = 'z';

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);

sel = (id_data == check_id) & (acti_label == check_acti);
check_data = axis_data(sel);

figure;
subplot(211);
plot(check_data);
addActivityLegend( check_acti);
subplot(212);
pwelch(check_data, [], [], [], fs);
addActivityLegend( check_acti);


figure;
subplot(211);
plot(check_data(1:length(check_data) / 2));
addActivityLegend( check_acti);
subplot(212);
pwelch(check_data(1:length(check_data) / 2), [], [], [], fs);
addActivityLegend( check_acti);

figure;
subplot(211);
plot(check_data(1:length(check_data) / 4));
addActivityLegend( check_acti);
subplot(212);
pwelch(check_data(1:length(check_data) / 4), [], [], [], fs);
addActivityLegend( check_acti);

figure;
subplot(211);
plot(check_data(1:length(check_data) / 8));
addActivityLegend( check_acti);
subplot(212);
pwelch(check_data(1:length(check_data) / 8), [], [], [], fs);
addActivityLegend( check_acti);