
%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);

%% Plot raw signal
% function plotRawSignal(fs,cachedData, check_id, axis)
fs = 20;
check_id = 1;
check_axis = 'x';
plotRawSignal(fs,cachedData, check_id, check_axis);

%% Plot scatter
% function plotScatter(cachedData, check_id, check_axis, actstr)
check_id = 33;
check_axis = 'z';
check_acti = 'Walking'; % Walking
plotScatter(cachedData, check_id, check_axis, check_acti);

%% Plot histogram
check_id = 33;
check_axis = 'z';
% function plotHistogram(cachedData, check_id, axis)
%plotHistogram(cachedData, check_id, 'x');
%plotHistogram(cachedData, check_id, 'y');
plotHistogram(cachedData, check_id, check_axis);

%% Plot single activity of single one
% function plotSinglePerActi(cachedData, check_id, check_act, check_axis)
check_id = 1;
check_act = 'Walking';
check_act = 'Upstairs';
check_axis = 'z';
plotSinglePerActi(cachedData, check_id, check_act, check_axis);
%% Average Filter v1
%{
% For the reason that bug existing.
% function averageFiltering(cachedData,check_axis, check_id, win_size, output_file_name)
win_size = 20;
check_id = 33;
check_axis = 'x';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',check_axis,'axis','_v1.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);
averageFiltering(cachedData, check_axis, check_id, win_size, output_file_name);
%}
%% Average Filter v2
%{
% For the reason that bug existing.
% function averageFiltering(cachedData,check_axis, check_id, win_size, output_file_name)
%win_size = 20; % fixed length
win_size = fix(507 / 20);
check_id = 33;
check_axis = 'z';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',check_axis,'axis','v2.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);

[raw, filted, labels, min_len] = averageFilteringv2(cachedData, check_axis, check_id, win_size, output_file_name);
figure;
plot(raw, 'b-');
hold on;
plot(filted, 'r-.', 'LineWidth',1);
plot(labels, 'g-', 'LineWidth',2);
hold off;
fprintf('Min length of the same activity is %d\n', min_len);
%}
%% Average Filter v3
%{
% For the reason that bug existing.
win_size = fix(507 / 20);
check_id = 33;
axis_str = 'z';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',axis_str,'axis','v2.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);

% function [res_axis, res_label] = extractIndividualData(cachedData, check_axis, check_id)
[check_axis, check_label] = extractIndividualData(cachedData, axis_str, check_id);
% function [output_raw_data, output_filted_data, output_raw_label,min_acti_length] = 
%                  averageFilteringv3(check_axis, check_label,  win_size, output_file_name)

[raw_axis, filted, raw_label, min_len] = averageFilteringv3(check_axis, check_label, win_size, output_file_name);
figure;
plot(raw_axis, 'b-');
hold on;
plot(filted, 'r-.', 'LineWidth',1);
plot(raw_label, 'g-', 'LineWidth',2);
hold off;
title('The result of average filtering');
fprintf('Min length of the same activity is %d\n', min_len);

fir_avg_axis = filted;
%}
%% Average Filter v4
% win_size = fix(507 / 20);
win_size = 20;
check_id = 1;
axis_str = 'x';
std_coeff = 1;
tmp_file = ['averageFiltering_',mat2str(check_id),'_',axis_str,'axis','v2.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);

[check_axis, check_label] = extractIndividualData(cachedData, axis_str, check_id);
[raw_axis, filted, raw_label] = averageFilteringv4(check_axis, check_label, win_size, std_coeff, output_file_name);

figure;
plot(check_label);
hold on;
plot(raw_label);
legend('filted label', 'raw label');

figure;
plot(raw_axis, 'b-');
hold on;
plot(filted, 'r-.', 'LineWidth',1);
plot(raw_label, 'g-', 'LineWidth',2);
hold off;
title('The result of average filtering removing zero value.');

%fprintf('Min length of the same activity is %d\n', min_len);

fir_avg_axis = filted;

fir_filted_pos = findMutationPosition(raw_label);
true_raw_pos = findMutationPosition(check_label);

%% Double average filtering
%{
[fir_filted, doub_filted, raw_labels] = averageFilteringv4(fir_avg_axis, raw_label, win_size,std_coeff, output_file_name);
fprintf('\n Length of first filted input data: %d\n', length(filted));

figure;
%plot(raw_axis);
%hold on;
plot(fir_avg_axis, 'b-','LineWidth',1);
hold on;
plot(doub_filted, 'r-.', 'LineWidth',1);
plot(raw_labels, 'g-', 'LineWidth',2);
title('The result of double average filtering');
%fprintf('Min length of the same activity is %d\n', min_len);

%{
% remove zero value
non_zero = [];
for i = 1:length(doub_filted)
    if doub_filted(i) ~= 0
        non_zero = [non_zero; doub_filted(i)];
    end
end
subplot(212);
plot(non_zero, 'r-');
title('The result of double average filtering and removing zero value');
hold off;
%}
%}
%% Double average filtering and detect mutation

win_size = 20;
check_id = 10;
std_coeff = 1;

axis_str = 'x';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',axis_str,'axis','v2.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);

[check_axis_x, check_label_x] = extractIndividualData(cachedData, axis_str, check_id);
[raw_x, filted_x, labels_x] = averageFilteringv4(check_axis_x, check_label_x, win_size, std_coeff, output_file_name);

axis_str = 'y';
[check_axis_y, check_label_y] = extractIndividualData(cachedData, axis_str, check_id);
[raw_y, filted_y, labels_y] = averageFilteringv4(check_axis_y, check_label_y, win_size, std_coeff, output_file_name);

axis_str = 'z';
[check_axis_z, check_label_z] = extractIndividualData(cachedData, axis_str, check_id);
[raw_z, filted_z, labels_z] = averageFilteringv4(check_axis_z, check_label_z, win_size, std_coeff, output_file_name);

fir_filted_pos = findMutationPosition(labels_x);
true_raw_pos = findMutationPosition(check_label_x);

axis_str = 'x';
tmp_file = ['averageFiltering_',mat2str(check_id),'_',axis_str,'axis','v2.csv'];
output_file_name = fullfile(filepath, filename, 'dataset', 'tempData', tmp_file);

%[check_axis_x, check_label_x] = extractIndividualData(cachedData, axis_str, check_id);
[fir_filt_x, sec_filted_x, sec_labels_x] = averageFilteringv4(filted_x, labels_x, win_size, std_coeff, output_file_name);

%[check_axis_y, check_label_y] = extractIndividualData(cachedData, axis_str, check_id);
[fir_filt_y, sec_filted_y, sec_labels_y] = averageFilteringv4(filted_y, labels_y, win_size, std_coeff, output_file_name);

%[check_axis_z, check_label_z] = extractIndividualData(cachedData, axis_str, check_id);
[fir_filt_z, sec_filted_z, sec_labels_z] = averageFilteringv4(filted_z, labels_z, win_size, std_coeff, output_file_name);

%{
figure;
subplot(311);
%plot(fir_filt_x, 'b-');
%hold on;
plot(sec_filted_x, 'r-');
hold on;
plot(sec_labels_x, 'g-', 'LineWidth',1.5);
title('Data of x axis');
hold off;

subplot(312);
%plot(fir_filt_y, 'b-');
%hold on;
plot(sec_filted_y, 'r-');
hold on;
plot(sec_labels_y, 'g-', 'LineWidth',1.5);
title('Data of y axis');
hold off;

subplot(313);
%plot(fir_filt_z, 'b-');
%hold on;
plot(sec_filted_z, 'r-');
hold on;
plot(sec_labels_z, 'g-', 'LineWidth',1.5);
title('Data of z axis');
hold off;

%}
threshold = 2;
half_win = 10;

predict_label_x = mutationDetectionv1(half_win, filted_x, threshold);
predict_label_y = mutationDetectionv1(half_win, filted_y, threshold);
predict_label_z = mutationDetectionv1(half_win, filted_z, threshold);

mutationDetectionv2;

%{
figure;
plot(predict_label_x, 'r-');
hold on;
plot(predict_label_y, 'g-');
hold on;
plot(predict_label_z, 'b-');
hold on;
plot(labels_x, 'k-', 'LineWidth',1.5);
hold off;
legend('pre_x','pre_y','pre_z','true_label');
%}
%% mutation

function [true_labels] = findMutationPosition(raw_labels)
    true_labels = [];
    for i = 2 : length(raw_labels)
        if raw_labels(i) - raw_labels(i-1) ~= 0
           true_labels = [true_labels; i]; 
        end
    end
end




