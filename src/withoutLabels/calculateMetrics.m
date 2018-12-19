function [tp, fp, fn] = calculateMetrics(predict_pos, true_pos, threshold)
    
    % true_positive represent the predicted location is true segmentation
    % false_positive represent the predicted location is not true segmentation
    % false_negative represent the true segmentation is not predicted

    % true_positive + false_positive = the number of predicted location
    % true_positive + false_negative = the number of true segmentation
    true_positive = 0;
    false_positive = 0;
    false_negative = 0;
    
    p1 = 1;
    p2 = 1;
    while p1 <= length(predict_pos) || p2 <= length(true_pos)
       up_threshold = true_pos(p2) - threshold;
       down_threshold = true_pos(p2) + threshold;
       if predict_pos(p1) < up_threshold
           false_positive = false_positive + 1;
           if p1 < length(predict_pos)
               p1 = p1 + 1;
           end
       elseif predict_pos(p1) > down_threshold
           false_negative = false_negative + 1;
           if p2 < length(true_pos)
               p2 = p2 + 1;
           end
       elseif predict_pos(p1) >= up_threshold && predict_pos(p1) <= down_threshold
          true_positive = true_positive + 1;
          p1 = p1 + 1;
          p2 = p2 + 1;
       end
    end
    tp = true_positive / length(predict_pos);
    fp = false_positive / length(predict_pos);
    fn = false_negative / length(true_pos);

end