function drawMergeLabel(rawLabel, segmentPos, predictLabel, targetId)
        figure;
        plot(rawLabel, 'g-', 'LineWidth', 1);
        hold on;
        plot(predictLabel, 'b-', 'LineWidth',1);
        hold on;
        for i = 1 : length(segmentPos)
           plot([segmentPos(i), segmentPos(i)],[0, 10], 'r-','LineWidth',1);
           hold on;
        end
        t_title = [ 'Predicted labels compared to raw labels of target id: ', num2str(targetId) ];
        title(t_title);
        legend('raw labels', 'predicted labels', 'candidate segmentation position');
        hold off;
end