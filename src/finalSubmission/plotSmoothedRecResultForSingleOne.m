function plotSmoothedRecResultForSingleOne(predictedLabel, smoothedLabel)
    figure;
    t = (1/50) * (0:length(predictedLabel)-1)';
    subplot(211);
    plot(t, predictedLabel, 'b-');
    hold on;
    title('Recognition result');
    xlabel('Time(sec)');
    ylabel('Activity Label');
    legend('predicted label', 'Real position', 'Location', 'southeast');
    set(gca, 'FontSize', 20); % ���������������С  

    subplot(212);
    plot(t, smoothedLabel, 'r-');
    hold on;
    
    title('Smoothed recognition result');

    xlabel('Time(sec)');
    ylabel('Activity Label');
    
    set(gca, 'FontSize', 20); % ���������������С      
    legend('smoothed label', 'Real position', 'Location', 'southeast')

end