function [predict_result, true_result, true_positive, false_positive, false_negative] = ...
    calculateMetricsWithoutLabels(predict_pos, true_pos, len_raw, threshold)
    
    % true_positive represents the predicted location is true segmentation
    % false_positive represents the predicted location is not true segmentation
    % false_negative represents the true segmentation is not predicted
    % true_negative represents 

    % true_positive + false_positive = the number of predicted location
    % true_positive + false_negative = the number of true segmentation
    true_positive = 0;
    false_positive = 0;
    false_negative = 0;
    
    p1 = 1;
    p2 = 1;
    
    predict_result = zeros(1,len_raw);
    true_result = zeros(1, len_raw);
    
    while p1 <= length(predict_pos) && p2 <= length(true_pos)
       up_threshold = true_pos(p2) - threshold;
       down_threshold = true_pos(p2) + threshold;
       if predict_pos(p1) < up_threshold
           predict_result(predict_pos(p1)) = 1;
           false_positive = false_positive + 1;
           if p1 < length(predict_pos)
               p1 = p1 + 1;
           else
               p2 = p2 + 1;
           end
       elseif predict_pos(p1) > down_threshold
           true_result(true_pos(p2)) = 1;
           false_negative = false_negative + 1;
           if p2 < length(true_pos)
               p2 = p2 + 1;
           else
               p1 = p1 + 1;
           end
       elseif predict_pos(p1) >= up_threshold && predict_pos(p1) <= down_threshold
          true_positive = true_positive + 1;
          predict_result(true_pos(p2)) = 1;
          true_result(true_pos(p2)) = 1;
          p1 = p1 + 1;
          p2 = p2 + 1;
       end
    end
    true_negative = len_raw - length(predict_pos) - false_negative;

    precision = true_positive / (true_positive + false_positive);
    tpr = true_positive / (true_positive + false_negative);
    fpr = false_positive / (false_positive + true_negative);
    
    tp = true_positive / length(predict_pos);
    fp = false_positive / length(predict_pos);
    fn = false_negative / length(true_pos);

end