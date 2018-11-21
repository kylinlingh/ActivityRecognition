
% calculate the absolute different value between tow adjecent window, plot
% the different value and find out the peaks.
half_win = 20;
filted = sec_filted_z;

diff_array_x = findAndDrawPeaks(sec_filted_x, 10);
diff_array_y = findAndDrawPeaks(sec_filted_y, 10);
diff_array_z = findAndDrawPeaks(sec_filted_z, 10);


figure;
subplot(311);
findpeaks(diff_array_x, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
hold on;
plot(sec_labels_x, 'g-','LineWidth',1.5);
title('Peaks of filted_x');
subplot(312);
findpeaks(diff_array_y, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
hold on;
plot(sec_labels_y, 'g-','LineWidth',1.5);
title('Peaks of filted_y');
subplot(313);
findpeaks(diff_array_z, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
hold on;
plot(sec_labels_z, 'g-','LineWidth',1.5);
title('Peaks of filted_z');

[pks_x, locs_x, w_x, p_x] = findpeaks(diff_array_x, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
[pks_y, locs_y, w_y, p_y] = findpeaks(diff_array_y, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);
[pks_z, locs_z, w_z, p_z] = findpeaks(diff_array_z, 'MinPeakHeight', 0.5, 'MinPeakDistance', 100);

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



%{
t_plot = zeros(1, length(sec_labels_x));

t_pre_index = 1;
t_label = 1;
for i = 1 : length(predict_loc)
   t_plot(t_pre_index: predict_loc(i)) = t_label;
   t_pre_index = predict_loc(i) + 1;
   t_label = t_label + 1;
end
%}

figure;
plot(sec_labels_x, 'g-', 'LineWidth', 1.5);
hold on;
for i = 1 : length(predict_loc)
   plot([predict_loc(i), predict_loc(i)],[0, 7], 'r-','LineWidth',1.5);
   hold on;
end
title('Predicted labels compared to average filtering twice');
hold off;

sec_true_labels = findTrueMutation(sec_labels_x);

recover_pos = recoverPositions(predict_loc,win_size, 2);
figure;
plot(check_label_x, 'g-', 'LineWidth', 1.5);
hold on;
for i = 1 : length(recover_pos)
   plot([recover_pos(i), recover_pos(i)],[0, 7], 'r-','LineWidth',1.5);
   hold on;
end
title('Predicted labels compared to recover labels');
hold off;




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

        
function [diff_array] = findAndDrawPeaks(filted, half_win)
        diff_array = [];
        for i = half_win + 1:length(filted) - half_win - 1
           left_win = filted(i - half_win: i);
           right_win = filted(i + 1: i + 1 + half_win);
           left_mean = mean(left_win);
           right_mean = mean(right_win);
           diff = abs(left_mean - right_mean);
           diff_array = [diff_array; diff];
        end
end
    
function [true_labels] = findTrueMutation(raw_labels)
    true_labels = [];
    for i = 2 : length(raw_labels)
        if raw_labels(i) - raw_labels(i-1) ~= 0
           true_labels = [true_labels; i]; 
        end
    end
end
