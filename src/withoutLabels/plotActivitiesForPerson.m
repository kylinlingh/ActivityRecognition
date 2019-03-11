clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_ALL_HANDS.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');
mapPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'mapForIdAndName.mat');

load(cacheDataPath);
load(mapPath);
clearvars -except cachedData mapForIdAndName

%% 3 5 7 10 20 29 30 33
target_id = 5;
target_id_data = extractIndiData(cachedData, target_id);

acti_unique = unique(target_id_data(:,2));
if length(acti_unique) ~= 8
   disp("not this one");
end
%% �����ֲ鿴�����ķ�����һ���ǵ���ÿ��������ͼ����һ���ǽ�ȫ������ƴ�ӵ�ͬһ��ͼ��(ÿ��������Ҫ��ȡһ����ʱ�����޷�����ȫ��������)
% ���ڵ������ǽ�ȫ������ƴ�ӵ�ͬһ��ͼ��
sampling_rate = 50;
time_window = 40; % ÿ������չʾ10���ӵ�ʱ����һ��8��������ƴ����������80���ӵ�����
activity_count = 8;

show_length = sampling_rate * time_window * activity_count;
joint_axis_x = zeros(show_length,1);
joint_axis_y = zeros(show_length,1);
joint_axis_z = zeros(show_length,1);

acti_array = [2, 1, 3, 4, 6, 5, 8, 7]; % ����������ƴ��˳���ò�ͬ�Ķ���֮�俴����������

for i = 1 : 8
    acti_label = acti_array(i);
    condition = target_id_data(:,2) == acti_label;
    raw_axis_x = target_id_data(condition,4);
    raw_axis_y = target_id_data(condition,5);
    raw_axis_z = target_id_data(condition,6);
    
    bak = i * sampling_rate * time_window;
    pre = (i - 1) * sampling_rate * time_window + 1;
    
    joint_axis_x(pre : bak) = raw_axis_x(1:sampling_rate*time_window);
    joint_axis_y(pre : bak) = raw_axis_y(1:sampling_rate*time_window);
    joint_axis_z(pre : bak) = raw_axis_z(1:sampling_rate*time_window);
end


axis_data = joint_axis_x;
drawActivities(joint_axis_x, '(a) X-axis', sampling_rate, time_window);
drawActivities(joint_axis_y, '(b) Y-axis', sampling_rate, time_window);
drawActivities(joint_axis_z, '(c) Z-axis', sampling_rate, time_window);
%%

function drawActivities(axis_data, x_title_str, sampling_rate, time_window)
    activity_count = 8;
    moving_average_win_len = 50;
    moving_average_axis_data = smooth(axis_data, moving_average_win_len);
    
    t = (1/sampling_rate) * (0:length(axis_data)-1)';
    figure;
    plot(t, axis_data, '-b', 'LineWidth', 1);
    hold on;
    plot(t,moving_average_axis_data, '-r', 'LineWidth',0.5);
    hold on;
    axis([0 time_window*activity_count min(axis_data) max(axis_data)]); % ȥ����ͼ��Ŀհ�����

    title(x_title_str);
    xlabel('Time(sec)');
    set(gca, 'XTick', 0: time_window: time_window*activity_count);   % ����x��Ŀ̶�Ϊÿ��40������ʾһ��
    ylabel('{Acceleration(m/s^2)}');
    set(gca, 'FontSize', 20); % ���������������С
    hl = legend('Raw signal', 'Moving average', 'Location', 'southeast');
    set(hl, 'Orientation', 'horizon'); % ����ˮƽ��ʾͼ�߱�־

end
%%
function check_all()

    figure;
    subplot(311);
    plot(joint_axis_x);
    title_array_x = [ 'Raw signal of target id: ', num2str(target_id), ' At target axis: x '];
    title(title_array_x);

    hold on;
    subplot(312);
    plot(joint_axis_y);
    title_array_y = [ 'Raw signal of target id: ', num2str(target_id), ' At target axis: y '];
    title(title_array_y);


    hold on;
    subplot(313);
    plot(joint_axis_z);
    title_array_z = [ 'Raw signal of target id: ', num2str(target_id), ' At target axis: z '];
    title(title_array_z);

    hold off;
end
%%


%% ��������
function res = extractIndiData(cachedData, target_id)
    condition = cachedData(:,1) == target_id;
    res = cachedData(condition,:);
end