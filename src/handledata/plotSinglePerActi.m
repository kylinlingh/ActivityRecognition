function plotSinglePerActi(cachedData, check_id, check_act, check_axis)
%{
check_axis = 'z';
check_id = 33;
win_size = 20;
 
actstr = 'Walking';
%}
actlabels = getActivityNames();
check_acti = find(strcmp(actlabels, check_act));
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
sel = (id_data == check_id) & (acti_label == check_acti);
check_data = axis_data(sel);

figure;
subplot(311);
plot(check_data);
addActivityLegend( check_acti);

subplot(312);
plotScatter(cachedData, check_id, 'z', check_act);
%addActivityLegend( check_acti);

subplot(313)
histogram(check_data,  'Normalization', 'probability'); 
addActivityLegend( check_acti);

end
