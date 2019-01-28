function [raw_label, all_predicted_locs, merge_locs, real_pos] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold, check_win)

    % Attention:  4,9£¬25
    % Best: 31
    % Worst:
    [raw_axis_x, raw_label] = extractIndividualData(cachedData, 'x', target_id);
    [raw_axis_y, ~] = extractIndividualData(cachedData, 'y', target_id);
    [raw_axis_z, ~] = extractIndividualData(cachedData, 'z', target_id);

    %%
    [~, canpos_x] = averageFilteringWithoutLabels3(raw_label, raw_axis_x, min_length, target_id, 'x', pre_threshold, bak_threshold, check_win);
    [~, canpos_y] = averageFilteringWithoutLabels3(raw_label, raw_axis_y, min_length, target_id, 'y', pre_threshold, bak_threshold, check_win);
    [~, canpos_z] = averageFilteringWithoutLabels3(raw_label, raw_axis_z, min_length, target_id, 'z', pre_threshold, bak_threshold, check_win);
    real_pos = findRealMutationPosition(raw_label);
    
    %mergeThreshold = 200;
    mergeThreshold = 1000;
    all_predicted_locs = [canpos_x; canpos_y; canpos_z];
    
   % all_predicted_locs = mergeCandidatePosWithMeanValue(sort(all_predicted_locs), mergeThreshold);
    all_predicted_locs = mergeCandidatePos(sort(all_predicted_locs), mergeThreshold);
    
    all_predicted_locs = all_predicted_locs(all_predicted_locs >= min_length);
    all_predicted_locs = all_predicted_locs(all_predicted_locs < length(raw_label) - min_length);
    predict_diff = differenceBetweenPrediction(all_predicted_locs);
 %   drawPredictedLabel(raw_label, merge_all, target_id);

    merge_locs = zeros(50,5);
    merge_locs = mergeLocs(merge_locs, canpos_x, 1);
    merge_locs = mergeLocs(merge_locs, canpos_y, 2);
    merge_locs = mergeLocs(merge_locs, canpos_z, 3);
    merge_locs = mergeLocs(merge_locs, all_predicted_locs, 4);
    merge_locs = mergeLocs(merge_locs, predict_diff, 5);
    merge_locs = mergeLocs(merge_locs, real_pos, 6);

    function [merge_locs] =  mergeLocs(merge_locs, locs, ind) 
        for j = 1 : length(locs)
           merge_locs(j, ind) = locs(j); 
        end
    end

    function [real_mutation_pos] = findRealMutationPosition(raw_labels)
        t_array = zeros(length(raw_labels),1);
        k = 1;
        for i = 2 : length(raw_labels)
            if raw_labels(i) - raw_labels(i-1) ~= 0
               t_array(k) = i;
               k = k + 1;
            end
        end
        real_mutation_pos = t_array(1:k-1);
    end

    function res = mergeCandidatePosWithMeanValue(locs, threshold)
        res = zeros(length(locs), 1);
        pre_data = locs(1);
        k = 1;
        i = 2;
        while i <= length(locs) + 1
            cur_sum = [pre_data];
            while i <= length(locs) && locs(i) <= pre_data + threshold
                pre_data = locs(i);
                cur_sum = [cur_sum, pre_data];
                i = i + 1;
            end
            if i <= length(locs)
                pre_data = locs(i);
                res(k) = ceil(mean(cur_sum));
                k = k + 1; 
                i = i + 1;
            else
                res(k) = ceil(mean(cur_sum));
                i = i + 1;
            end

        end
        res = res(1:k);
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

    function res = differenceBetweenPrediction(predict_locs)
        res = zeros(length(predict_locs) - 1);
        k = 1;
        for i = 2 : length(predict_locs)
            res(k) = predict_locs(i) - predict_locs(i-1);
            k = k + 1;
        end
        
    end



end