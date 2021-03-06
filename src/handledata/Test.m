%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
load(cacheDataPath);
%%
check_axis = 'z';
check_id = 33;
win_size = 40;

%actstr = 'Walking';
actstr = 'Sitting';
actlabels = getActivityNames();
check_acti = find(strcmp(actlabels, actstr));
%% Read data
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);
check_axis = axis_data(id_data == check_id);
check_label = acti_label(id_data == check_id);
%%
%{
sel = (id_data == check_id) & (acti_label == check_acti);
check_data = axis_data(sel);

figure;
subplot(311);
plot(check_data);
addActivityLegend( check_acti);

subplot(312);
plotScatter(cachedData, check_id, 'z', actstr);
%addActivityLegend( check_acti);

subplot(313)
histogram(check_data,  'Normalization', 'probability'); 
addActivityLegend( check_acti);
%}
%%
win_size = 20;
cumsum = [0];
filted_data = [];
counts = [0];

sel = (id_data == check_id) & (acti_label == check_acti);
check_data = axis_data(sel);

t_mean = mean(check_data);
t_std = std(check_data);
up_limit = t_mean + 2*t_std;
down_limit = t_mean - 2*t_std;

%j = 2;
for i = 2 : length(check_data)
    cur_num = check_data(i - 1);
    if cur_num >= down_limit && cur_num <= up_limit
        cumsum(i) = cumsum(i-1) + cur_num;     
        counts(i) = counts(i-1) + 1;
  %      j = j + 1;
    else
        cumsum(i) = cumsum(i-1);
        counts(i) = counts(i-1);
    end
    if i > win_size
        division = counts(i) - counts(i-win_size);
        if division == 0
            division = 1;
        end
        moving_ave = ( cumsum(i) - cumsum(i-win_size)) / division ;
        filted_data = [filted_data; moving_ave];
    end
end

fprintf('Length of raw data: %d\n', length(check_data));
fprintf('Length of filted data: %d\n', length(filted_data));

figure;
subplot(311);
plot(check_data); 
title('Raw signal data');
hold on;
plot(filted_data, 'r-.', 'LineWidth',2);
addActivityLegend( check_acti);


subplot(312);
plotscatter(check_data, actstr);
title('Scatter of raw signal data');
subplot(313);
plotscatter(filted_data, actstr);
title('Scatter of filted signal data');
%%
    function plotscatter(check_data,actstr)
        space = linspace(0, length(check_data), length(check_data));
        scatter(space, check_data, 1);

        t_mean = mean(check_data);
        t_std = std(check_data);

        hold on;
        t_mean_xaxis = 1 : length(check_data);
        t_mean_yaxis = t_mean + zeros(length(check_data), 1);
        p1 = plot(t_mean_xaxis, t_mean_yaxis, '-.g', 'LineWidth',2);

        t_std_xaxis = 1 : length(check_data);
        t_std_yaxis_up = (t_mean  + t_std) + zeros(length(check_data), 1);
        t_std_yaxis_down = (t_mean - t_std) + zeros(length(check_data), 1);
        p2 = plot(t_std_xaxis, t_std_yaxis_up, '-.r');
        plot(t_std_xaxis, t_std_yaxis_down, '-.r');
        hold off;
        legend(actstr ,'平均值', '标准差');
    end

%% Filter signals within same activity
%{

pre_label = check_label(1);
output_raw_data = [];
output_raw_label = [];
output_filted_data = [];

cur_raw_data = [];
cur_raw_label = [];

for da_index = 1 : length(check_axis)
    cur_label = check_label(da_index);
    if cur_label == pre_label
       cur_raw_data = [cur_raw_data; check_axis(da_index)];
       cur_raw_label = [cur_raw_label; check_label(da_index)];
    else
        cumsum = [0];
        filted_data = [];
       % belief_min, belief_max = calculateBeliefArea(cur_raw_data);
        
        for i = 2 : length(cur_raw_data)+1
            cumsum(i) = (cumsum(i-1) + cur_raw_data(i-1));
            if i > win_size
                moving_ave = ( cumsum(i) - cumsum(i-win_size)) / win_size;
                filted_data = [filted_data; moving_ave];
%                output_raw_label = [output_raw_label; pre_label];
            end
        end
        output_raw_data = [output_raw_data; cur_raw_data(1: end-win_size+1)];
        output_raw_label = [output_raw_label; cur_raw_label(1: end-win_size+1)];
        output_filted_data = [output_filted_data; filted_data];
        cur_raw_data = [];
        cur_raw_label = [];
        pre_label = cur_label;
    end
end
fprintf('Length of output_raw_data: %d\n', length(output_raw_data));
fprintf('Length of output_raw_label: %d\n', length(output_raw_label));
fprintf('Length of output_filted_data: %d\n', length(output_filted_data));
output_data = [output_raw_data, output_filted_data, output_raw_label ];

%}
%%
%{
    function [min, max] = calculateBeliefArea(dataArray)
        a=0.01; %0.01 对应99%置信区间， 0.05 对应95%置信区间 ，0.1 对应90%置信区间
        if a==0.01
            n=2.576; % 2.576 对应99%置信区间， 1.96 对应95%置信区间 ，1.645 对应90%置信区间
        elseif a==0.05
            n=1.96;
        elseif a==0.1
            n=1.645;
        end
        %计算对应百分位值
        meana=mean(sampledata);
        stda=std(sampledata);
        sorta=sort(sampledata);  %对数据从小到大排序
        leng=size(sampledata,1);
        CIa(1:2,1)=[sorta(leng*a/2);sorta(leng*(1-a/2))];
        %利用公式计算置信区间
        CIf(1:2,1)=[meana-n*stda;meana+n*stda];
        min = CIf(1,1);
        max = CIf(1,2);
    end
%}
%csvwrite(output_file_name, output_data);
%%
