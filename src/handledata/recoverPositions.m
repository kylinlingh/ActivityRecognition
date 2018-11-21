function  [recover_pos] = recoverPositions(predict_loc, win_size, filter_time)
    recover_pos = [];
    for i = 1 : length(predict_loc)
        cur_pos = predict_loc(i);
        cal_pos = filter_time * i * (win_size - 1) + cur_pos + 11;
        recover_pos = [recover_pos; cal_pos];
    end
end
