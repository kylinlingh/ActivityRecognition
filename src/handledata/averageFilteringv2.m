function [output_raw_data, output_filted_data] = averageFilteringv2(cachedData,check_axis, check_id, win_size, output_file_name)
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
check_axis = axis_data(id_data == check_id);
check_label = acti_label(id_data == check_id);

%% Filter signals within same activity
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
        counts = [0];
        filted_data = [];
       % belief_min, belief_max = calculateBeliefArea(cur_raw_data);
        t_mean = mean(cur_raw_data);
        t_std = 0.5 * std(cur_raw_data);
        up_limit = t_mean + t_std;
        down_limit = t_mean - t_std;
             
        for i = 2 : length(cur_raw_data) + 1
            cur_num = cur_raw_data(i - 1);
            if cur_num >= down_limit && cur_num <= up_limit
                cumsum(i) = cumsum(i-1) + cur_num;   
                counts(i) = counts(i-1) + 1;
            else
                cumsum(i) = cumsum(i-1);
                counts(i) = counts(i-1);
            end
            if i > win_size
                division = counts(i) - counts(i-win_size);
                if division == 0
                    division = 1
                end
                moving_ave = ( cumsum(i) - cumsum(i-win_size)) / division;
                filted_data = [filted_data; moving_ave]; 
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
csvwrite(output_file_name, output_data);
end