function [predict_locs, real_mutation_pos] =  mutationDetection(half_win, filtered_x, filtered_y, filtered_z, raw_label, target_id)

diff_array_x = computeDifferenceValue(filtered_x, half_win);
diff_array_y = computeDifferenceValue(filtered_y, half_win);
diff_array_z = computeDifferenceValue(filtered_z, half_win);


    figure;
    subplot(311);
    findpeaks(diff_array_x, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted X');
    subplot(312); 
    findpeaks(diff_array_y, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Y');
    subplot(313);
    findpeaks(diff_array_z, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Z');
%}

[~, locs_x, ~, ~] = findpeaks(diff_array_x, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
[~, locs_y, ~, ~] = findpeaks(diff_array_y, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
[~, locs_z, ~, ~] = findpeaks(diff_array_z, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);

predict_locs = getPredictedPosition(locs_x, locs_y, locs_z);
real_mutation_pos = findRealMutationPosition(raw_label);
drawPredictedLabel(raw_label, predict_locs, target_id);


    function predict_loc = getPredictedPosition(locs_x, locs_y, locs_z)
        candidate_loc = [];
        candidate_count = [];

        [candidate_loc, candidate_count] = voteForCandidate(locs_x, candidate_loc, candidate_count);
        [candidate_loc, candidate_count] = voteForCandidate(locs_y, candidate_loc, candidate_count);
        [candidate_loc, candidate_count] = voteForCandidate(locs_z, candidate_loc, candidate_count);

        predict_loc = [];
        predict_count = [];

        for i = 1 : length(candidate_count)
           if candidate_count(i) >= 2
              predict_loc = [predict_loc; candidate_loc(i)]; 
              predict_count = [predict_count; candidate_count(i)];
           end
        end
    end

    function drawPredictedLabel(raw_label, predict_loc, target_id)
        figure;
        plot(raw_label, 'g-', 'LineWidth', 1);
        hold on;
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 7], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw label of target id: ', num2str(target_id)];
        title(t_title);
        legend('raw_label', 'predicted position');
        hold off;
    end

    function [candidate_loc, candidate_count] =  voteForCandidate(locs, candidate_loc, candidate_count)
        for i = 1 : length(locs)
            detected = 0;
            for j = 1 : length(candidate_loc)
               if candidate_loc(j) == locs(i)
                  candidate_count(j) = candidate_count(j) + 1; 
                  detected = 1;
               end
            end 
            if detected == 0
               candidate_loc = [candidate_loc; locs(i)];
               candidate_count = [candidate_count; 1];
            end
        end
    end

    function [diff_array] = computeDifferenceValue(filted, half_win)
            diff_array = zeros(length(filted), 1);
            for i = half_win + 1:length(filted) - half_win - 1
               left_win = filted(i - half_win: i);
               right_win = filted(i + 1: i + 1 + half_win);
               left_mean = mean(left_win);
               right_mean = mean(right_win);
               diff = abs(left_mean - right_mean);
               diff_array(i) =  diff;
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

end