function [predict_locs, real_mutation_pos, locs_x, locs_y, locs_z] =  rawDataFindPeak(half_win, filtered_x, filtered_y, filtered_z, raw_label, target_id, minPeakHeight)

diff_array_x = computeDifferenceValue(filtered_x, half_win);
diff_array_y = computeDifferenceValue(filtered_y, half_win);
diff_array_z = computeDifferenceValue(filtered_z, half_win);

minPeakProminence = 0;
minPeakDistance = 200;
deviation = 10;

    figure;
    subplot(311);
    findpeaks(diff_array_x, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted X, Time 1');
    subplot(312); 
    findpeaks(diff_array_y, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Y');
    subplot(313);
    findpeaks(diff_array_z, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Z');
  
%{
diff_array_x = computeDifferenceValueSecondTime(diff_array_x, half_win / 2);
diff_array_y = computeDifferenceValueSecondTime(diff_array_y, half_win / 2);
diff_array_z = computeDifferenceValueSecondTime(diff_array_z, half_win / 2);

%minPeakHeight =1;


minPeakHeight = 1;
    figure;
    subplot(311);
    findpeaks(diff_array_x, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted X, Time 2');
    subplot(312); 
    findpeaks(diff_array_y, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Y');
    subplot(313);
    findpeaks(diff_array_z, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Z');

    diff_array_x = computeDifferenceValueSecondTime(diff_array_x, half_win / 2);
diff_array_y = computeDifferenceValueSecondTime(diff_array_y, half_win / 2);
diff_array_z = computeDifferenceValueSecondTime(diff_array_z, half_win / 2);

%minPeakHeight =1;
deviation = 20;

minPeakHeight = 1;
    figure;
    subplot(311);
    findpeaks(diff_array_x, 'MinPeakHeight',minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted X, Time 3');
    subplot(312); 
    findpeaks(diff_array_y, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Y');
    subplot(313);
    findpeaks(diff_array_z, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', minPeakDistance, 'MinPeakProminence', minPeakProminence);
    hold on;
    plot(raw_label, 'g-','LineWidth',1.5);
    title('Peaks of filted Z');
%}


[~, locs_x, ~, ~] = findpeaks(diff_array_x, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', 100);
[~, locs_y, ~, ~] = findpeaks(diff_array_y, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', 100);
[~, locs_z, ~, ~] = findpeaks(diff_array_z, 'MinPeakHeight', minPeakHeight, 'MinPeakDistance', 100);

predict_locs = getPredictedPosition(locs_x, locs_y, locs_z);
real_mutation_pos = findRealMutationPosition(raw_label);
drawPredictedLabel(raw_label, predict_locs, target_id);


    function predict_loc = getPredictedPosition(locs_x, locs_y, locs_z)
        candidate_loc = [];
        candidate_loc = voteForCandidateWith2Axis(locs_x, locs_y, deviation, candidate_loc);
        candidate_loc = voteForCandidateWith2Axis(locs_y, locs_z, deviation, candidate_loc);
        candidate_loc = voteForCandidateWith2Axis(locs_x, locs_z, deviation, candidate_loc);
        predict_loc = mergeCandidate(candidate_loc, deviation);
        %{
        candidate_loc = [];
        candidate_count = [];

        [candidate_loc, candidate_count] = voteForCandidate(locs_x, candidate_loc, candidate_count, deviation);
        [candidate_loc, candidate_count] = voteForCandidate(locs_y, candidate_loc, candidate_count, deviation);
        [candidate_loc, candidate_count] = voteForCandidate(locs_z, candidate_loc, candidate_count, deviation);

        predict_loc = [];
        predict_count = [];

        for i = 1 : length(candidate_count)
           if candidate_count(i) >= 2
              predict_loc = [predict_loc; candidate_loc(i)]; 
              predict_count = [predict_count; candidate_count(i)];
           end
        end
        
        %}
    end

    function drawPredictedLabel(raw_label, predict_loc, target_id)
        figure;
        plot(raw_label, 'g-', 'LineWidth', 1);
        hold on;
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 7], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw label of target id: ', num2str(target_id), ' Using peak height: ', num2str(minPeakHeight)];
        title(t_title);
        legend('raw_label', 'predicted position');
        hold off;
    end

    function [candidate_res] = voteForCandidateWith2Axis(candidate_locA, candidate_locB, deviation, candidate_res)
        for i = 1 : length(candidate_locA)
            curA = candidate_locA(i);
           for j = 1 : length(candidate_locB)
               curB = candidate_locB(j);
              if curB >= curA - deviation && curB <= curA + deviation
                  candidate_res = [candidate_res; ceil((curA + curB) / 2)];
              end
           end
        end
    end

    function merge_res = mergeCandidate(candidate_res, deviation)
        t_merge = sort(candidate_res);
        merge_res = [];
        for i = 1 : length(t_merge)
           curA = t_merge(i);
           t_cache = [curA];
           k = i;
           for j = i+1 : length(t_merge)
              curB = t_merge(j);
              if curB >= curA - deviation && curB <= curA + deviation
                  t_cache = [t_cache; curB];
                  k = k + 1;
              end
           end
           i = k + 1;
           merge_res = [merge_res; ceil(mean(t_cache))];
        end
    end


function [candidate_loc, candidate_count] =  voteForCandidate(locs, candidate_loc, candidate_count,deviation )

end

%{
    function [diff_array] = computeDifferenceValue(filted, half_win)
            diff_array = zeros(length(filted), 1);
            for i = 1 : length(filted)
               if i <= half_win
                  t_mean = mean(filted(1:i-1));
               else
                  t_mean = mean(filted(i-half_win: i-1));
               end
               diff_array(i) = abs(filted(i) - t_mean);
            end
    end
  %}  

    function [diff_array] = computeDifferenceValue(filted, half_win)
        half_win = ceil(half_win);
        diff_array = zeros(length(filted), 1);
        for i = half_win + 1:length(filted) - half_win - 1
           left_win = filted(i - half_win: i-1);
           right_win = filted(i : i + ceil(half_win / 2));
           left_mean = mean(left_win);
           right_mean = mean(right_win);
           diff = abs(left_mean - right_mean);
           diff_array(i) =  diff;
        end
    end

    function [diff_array] = computeDifferenceValueSecondTime(filted, half_win)
            half_win = ceil(half_win);
            diff_array = zeros(length(filted), 1);
            for i = half_win + 1:length(filted) - half_win - 1
               left_win = filted(i - half_win: i-1);
               right_win = filted(i : i + half_win);
               %right_win = filted(i);
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

    function [candidate_loc, candidate_count] =  voteForCandidate_outdated(locs, candidate_loc, candidate_count,deviation )
        for i = 1 : length(locs)
            detected = 0;
            for j = 1 : length(candidate_loc)
                if detected == 1
                    break;
                end
               if (candidate_loc(j) >= locs(i) - deviation) && (candidate_loc(j) <= locs(i) + deviation)
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

end