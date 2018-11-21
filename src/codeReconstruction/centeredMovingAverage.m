function res_avg_array = centeredMovingAverage(input_array, win_size, coeff)
    data_len = length(input_array);
    res_avg_array = zeros(data_len,1);
    if rem(win_size, 2) == 0
        win_size = win_size + 1;
    end
    half_win = (win_size - 1) / 2;
    
    mean_value = mean(input_array);
    std_value = std(input_array);
    up_limit = mean_value + coeff * std_value;
    down_limit = mean_value - coeff * std_value;
    
    pre_ave_value = mean_value;
    
    for i = 1 : data_len
        sub_win = zeros(win_size,1);
        [forward_p, backward_p] = calPointer(i, half_win, data_len);
        k = 1;
        for j = forward_p : backward_p
            cur_data = input_array(j);
            if cur_data >= down_limit && cur_data <= up_limit
                sub_win(k) = cur_data;
                k = k + 1;
            end
        end
        if k == 1
            res_avg_array(i) = pre_ave_value; 
        else
            cur_ave_value = sum(sub_win) / (k-1);
            res_avg_array(i) = cur_ave_value;
            pre_ave_value = cur_ave_value;
        end        
    end
   
end

function [forward_pointer, backward_pointer] = calPointer( cur_index, half_win, data_len)
    if cur_index <= half_win
        forward_pointer = 1;
        backward_pointer = cur_index + half_win;
    elseif cur_index >= data_len - half_win
        forward_pointer = cur_index - half_win;
        backward_pointer = data_len;
    else
        forward_pointer = cur_index - half_win;
        backward_pointer = cur_index + half_win;
    end
end


