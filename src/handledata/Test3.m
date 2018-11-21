
a = [4 8 6 -1 -2 -3 -1 3 4 5];
m = centered_moving_average(a, 3);


function res_avg_array = centered_moving_average(x, win_size)
    data_length = length(x);
    res_avg_array = zeros(data_length,1);
    if rem(win_size, 2) == 0
        win_size = win_size + 1;
    end
    half_win = (win_size - 1) / 2;
    
    for i = 1 : data_length
       if i <= half_win
           t_array = x(1:i+half_win);
           t_count = i + half_win;
       elseif i >= data_length - half_win
           t_array = x(i-half_win : data_length);
           t_count = data_length - i + half_win + 1;
       else
           t_array = x(i-half_win : i + half_win);
           t_count = 2 * half_win + 1;
       end
       cur_ave = sum(t_array) / t_count;
       res_avg_array(i) = cur_ave;
    end
end
