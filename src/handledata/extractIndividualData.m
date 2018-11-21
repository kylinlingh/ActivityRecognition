function [res_axis, res_label] = extractIndividualData(cachedData, check_axis, check_id)
%check_axis = 'z';
%check_id = 33;
%check_acti = 2;
%win_size = 20;
%% Read data
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);

res_axis = axis_data(id_data == check_id);
res_label = acti_label(id_data == check_id);

end