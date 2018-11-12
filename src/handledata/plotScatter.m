function plotScatter(cachedData, check_id, check_axis, actstr)

%check_id = 33;
%check_axis = 'z';
%check_acti = 3;
%%
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

%actstr = 'Walking';
actlabels = getActivityNames();
check_acti = find(strcmp(actlabels, actstr));

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);

%%
check_data = axis_data(id_data == check_id & acti_label == check_acti);
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

%addActivityLegend(check_acti);
end