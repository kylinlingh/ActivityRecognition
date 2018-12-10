
function filtered_axis = averageFiltering(input_axis, input_label, win_size, coeff)

    in_arr_len = length(input_axis);
    pre_label = input_label(1);
    filtered_axis = zeros(in_arr_len, 1);
    forward_pointer = 1;
    t_label_count = 0;
    
    % gather data having same label
    for i = 1 : in_arr_len
        cur_label = input_label(i);
        if cur_label ~= pre_label
            t_label_count = t_label_count + 1;
            backward_pointer = i - 1;
            sub_axis = input_axis(forward_pointer : backward_pointer);
            sub_filtered_axis = centeredMovingAverage(sub_axis, win_size, coeff);
            filtered_axis(forward_pointer : backward_pointer) = sub_filtered_axis;
            pre_label = cur_label;
            forward_pointer = i;
        end
    end
    if forward_pointer ~= in_arr_len
        t_label_count = t_label_count + 1;
        sub_axis = input_axis(forward_pointer : in_arr_len);
        sub_filtered_axis = centeredMovingAverage(sub_axis, win_size, coeff);
        filtered_axis(forward_pointer : in_arr_len) = sub_filtered_axis;
    end
    
        
%    fprintf('Length of input_axis: %d \n', in_arr_len);
 %   fprintf('Length of filtered_axis: %d \n', length(filtered_axis));
  %  fprintf('Label count is %d \n', t_label_count);
end

