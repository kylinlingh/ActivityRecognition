function plotRevisionResult(predictedLabel, smoothedLabel, revisiedLabel)

    figure;
    t = (1/50) * (0:length(predictedLabel)-1)';
    subplot(311);
    plot(t, predictedLabel, 'b-');
    hold on;
    title('Recognition result');
    xlabel('Time(sec)');
    ylabel('Activity Label');
    legend('predicted label', 'Location', 'southeast');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小  

    subplot(312);
    plot(t, smoothedLabel, 'r-');
    hold on;    
    title('Smoothed recognition result');
    xlabel('Time(sec)');
    ylabel('Activity Label');
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小      
    legend('smoothed label', 'Location', 'southeast')
    
    subplot(313);
    plot(t, revisiedLabel, 'g-');
    hold on;  
    title('Revisied recognition result');
    xlabel('Time(sec)');
    ylabel('Activity Label');   
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小      
    legend('revisied label', 'Location', 'southeast')

end