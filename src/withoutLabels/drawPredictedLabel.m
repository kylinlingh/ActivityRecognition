function drawPredictedLabel(raw_label, predict_loc, target_id, pre_threshold, bak_threshold, check_win)
       % figure;
        plot(raw_label, 'g-', 'LineWidth', 1);
        hold on;
        for i = 1 : length(predict_loc)
           plot([predict_loc(i), predict_loc(i)],[0, 10], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw label of target id: ', num2str(target_id) ];
        title(t_title);
        xlabel(['pre threshold: ', num2str(pre_threshold),' bak threshold: ', num2str(bak_threshold)]);
        ylabel(['check win: ',num2str(check_win)]);
        legend('raw_label', 'predicted position');
        hold off;
end