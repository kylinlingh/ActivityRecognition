function [predict_label] = mutationDetectionv1(half_win, filted, threshold)
%%
%half_win = 10;
pre_label = 0;
predict_label = [];
for i = half_win + 1:length(filted) - half_win - 1
   left_win = filted(i - half_win: i);
   right_win = filted(i + 1: i + 1 + half_win);
   left_mean = mean(left_win);
   right_mean = mean(right_win);
   predict_label = [predict_label; pre_label];
   
   if abs(right_mean - left_mean) > threshold
       pre_label = pre_label + 1;
   end   
end

end

