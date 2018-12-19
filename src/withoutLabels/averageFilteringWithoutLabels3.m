function [remain_data, candidate_pos] = averageFilteringWithoutLabels3(raw_label, raw_axis, win_len, target_id, target_axis, pre_threshold, bak_threshold, check_win)
    
    %check_win = 3; % WISDM
    %check_win = 1;
    validated_threshold = 0.1;
    %%pre_threshold = 3;
    %%bak_threshold = 1;
    
 %   pre_threshold = 9;
 %   bak_threshold = 1;
    
    [for_diff, bak_diff, bi_diff, candidate_pos, remain_data] = calDifference(raw_axis, pre_threshold, bak_threshold, 100, validated_threshold, check_win);
    mergeThreshold = 200;
    if ~isempty(candidate_pos)
            candidate_pos = mergeCandidatePos(candidate_pos, mergeThreshold);
    end
    
%    drawDifferencePlot(raw_label, raw_axis, for_diff, bak_diff, pre_threshold, bak_threshold, candidate_pos, target_id, target_axis);
%    drawPlot(for_diff, bak_diff, bi_diff, raw_label, target_id, target_axis);
%    drawPredictedLabel(raw_label, candidate_pos, target_id, target_axis);
%    drawFiltedSignal(raw_axis, remain_data, raw_label, target_id, target_axis);
    
    
    function [for_diff, bak_diff, bi_diff, candidate_pos, remain_data] = calDifference(axis_data, pre_threshold, bak_threshold, coeff, threshold,check_win)
        data_len = length(axis_data);
        for_diff = zeros(data_len, 1);
        bak_diff = zeros(data_len, 1);
        bi_diff = zeros(data_len, 1);

        candidate_pos = zeros(data_len, 1);
        k = 1;
        remain_data = zeros(data_len, 1);
        r = 1;
 %       threshold = 5;

 
        for i = 2 : data_len - 1 - check_win
          %  cur_data = axis_data(i);
            [for_beg_pointer,bak_end_pointer] = calPointer(i, win_len, data_len, check_win);
            for_end_pointer = i - 1;
            %bak_beg_pointer = i + 1;
            bak_beg_pointer = i + check_win;

            for_mean = mean(axis_data(for_beg_pointer: for_end_pointer));
            bak_mean = mean(axis_data(bak_beg_pointer: bak_end_pointer));
            this_mean = mean(axis_data(i : i + check_win -1));

            %{
            t_for_diff = cur_data - for_mean;
            t_bak_diff = cur_data - bak_mean;
            t_bi_diff = abs(bak_mean - for_mean);
%}
            t_for_diff = this_mean - for_mean;
            t_bak_diff = this_mean - bak_mean;
            t_bi_diff = abs(bak_mean - for_mean);
                      
            for_diff(i) = t_for_diff;
            bak_diff(i) = t_bak_diff;
            bi_diff(i) = t_bi_diff;  
%{
            if abs(t_for_diff) > coeff * abs(t_bak_diff)
                candidate_pos(k) = i;
                k = k + 1;
            end    
  %}          
            if abs(t_for_diff) > pre_threshold && abs(t_bak_diff) < bak_threshold
                candidate_pos(k) = i;
                k = k + 1;
            end  
            
            validated = dataValidationCheck(t_for_diff, t_bak_diff, threshold);
            %{
            if validated == 1
                remain_data(r) = cur_data;
                r = r + 1;
            end
            %}
            
            if validated == 0
               remain_data(r) = for_mean;
            else
               remain_data(r) = this_mean;
            end
            r = r + 1;
            %}
            
        end
        candidate_pos = candidate_pos(1:k-1);
        remain_data = remain_data(1:r-1);
    end

    function res = dataValidationCheck(t_for_diff, t_bak_diff, threshold)
        res = 1;
        if abs(t_for_diff) > threshold && abs(t_bak_diff) > threshold
            res = 0;
        end
    end

    function [forward_pointer, backward_pointer] = calPointer( cur_index, win_length, data_len,check_win)
        if cur_index <= win_length
            forward_pointer = 1;
            backward_pointer = cur_index + check_win + win_length;
        elseif cur_index >= data_len - win_length - check_win
            forward_pointer = cur_index - win_length;
            backward_pointer = data_len;
        else
            forward_pointer = cur_index - win_length;
            backward_pointer = cur_index + check_win + win_length;
        end
    end

    function drawPlot(for_diff, bak_diff, bi_diff, raw_label, target_id, target_axis)
        figure;
        subplot(411);
        plot(raw_axis);
        hold on;
        plot(raw_label);
        t_title = [ 'Raw signal of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
          
        subplot(412);
        plot(for_diff);
        hold on;
        plot(raw_label);
        t_title = [ 'Forward difference of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
        
        subplot(413);
        plot(bak_diff);
        hold on;
        plot(raw_label);
        t_title = [ 'Backward difference of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
        
        subplot(414);
        plot(bi_diff);
        hold on;
        plot(raw_label);
        t_title = [ 'Bidirection difference of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
        hold off;
    end

%{
    function drawPredictedLabel(raw_label, predict_loc, target_id, target_axis)
        figure;
        plot(raw_label, 'g-', 'LineWidth', 1);
        hold on;
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 7], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw label of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
        legend('raw_label', 'predicted position');
        hold off;
    end
%}
    function drawFiltedSignal(raw_data, filted_data, raw_label, target_id, target_axis)
       figure;
       plot(raw_data, 'b-');
       hold on;
       plot(filted_data, 'g-');
       hold on;
       plot(raw_label, 'r-');
       t_title = [ 'Raw signal and filtered signal of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
    end

    function drawDifferencePlot(raw_label, raw_data, for_diff, bak_diff, for_threshold, bak_threshold, predict_loc, target_id, target_axis)
        figure;
        subplot(211);
        plot(raw_data, 'b-');
        
        hold on;
  %      plot(for_diff, 'c- ', 'LineWidth', 1);
  %      hold on;
        plot([0, length(raw_data)],[for_threshold,for_threshold], 'r-.', 'LineWidth', 1.5);
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 7], 'g--','LineWidth',1);
           hold on;
        end
        hold on;
        plot(raw_label, 'k-', 'LineWidth', 1.5);
        t_title = ['Difference value of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
%        legend('raw signal', 'for diff', 'for threshold');
        hold off;

        
        subplot(212);
        plot(raw_data, 'b-');
        
        hold on;
    %    plot(bak_diff, 'c-' ,'LineWidth', 1);
    %    hold on;
        plot([0, length(raw_data)],[bak_threshold,bak_threshold], 'r-.', 'LineWidth', 1.5);
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 7], 'g--','LineWidth',1);
           hold on;
        end
        hold on;
        plot(raw_label, 'k-', 'LineWidth', 1.5);
        t_title = ['Difference value of target id: ', num2str(target_id), ' At target axis: ', target_axis];
        title(t_title);
%        legend('raw signal', 'bak diff', 'bak threshold');
        hold off;
    end

    function res = mergeCandidatePos(locs, threshold)
        res = zeros(length(locs), 1);
        pre_data = locs(1);
        res(1) = pre_data;
        k = 2;
        i = 2;
        while i <= length(locs)
            while i <= length(locs) && locs(i) <= pre_data + threshold
                pre_data = locs(i);
                i = i + 1;
            end
            if i <= length(locs)
                pre_data = locs(i);
                res(k) = locs(i);
                k = k + 1; 
                i = i + 1;
            end

        end
        res = res(1:k-1);
    end


end