
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);

%%
check_act = 'Jogging';
check_axis =  'x';
check_id = 1;
actlabels = getActivityNames();
check_acti = find(strcmp(actlabels, check_act));

id_data = cachedData(:,1);
acti_label = cachedData(:,2);

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end

axis_data = cachedData(:,component);

checkd_axis = axis_data(id_data == check_id);
check_label = acti_label(id_data == check_id);

all_sample = axis_data((id_data == check_id) & (acti_label == check_acti)) ;
sample = all_sample(1:300);
%%
Fs = 20;
[C1,lag1] = xcorr(checkd_axis, sample);   
figure

subplot(311);
%plot((0:numel(checkd_axis)-1) /Fs , checkd_axis, 'b');
plot(checkd_axis, 'r');
grid on;

subplot(312);
plot(sample, 'g');

subplot(313);
%plot(C1, 'k');
plot(lag1/Fs,C1,'k')
ylabel('Amplitude')
grid on
title('Cross-correlation between Template 1 and Signal')

%%
[~,I] = max(abs(C1));
SampleDiff = lag1(I)
timeDiff = SampleDiff/Fs
