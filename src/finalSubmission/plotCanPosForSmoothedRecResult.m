function plotCanPosForSmoothedRecResult(smoothedLabel, realSwitchedPos, canPosFromRecResult)

    figure;
    t = (1/50) * (0:length(smoothedLabel)-1)';
    
    plot(t, smoothedLabel, 'b-');
    hold on;

    yAxis = ones(length(realSwitchedPos),1) * 9;
    plot(ceil(realSwitchedPos / 50), yAxis, 'b*');
    hold on;
    
    yAxis = ones(length(canPosFromRecResult),1) * 10;
    plot(ceil(canPosFromRecResult / 50), yAxis, 'mo');
    hold on;   
    
    title('Candidated Positions');

    xlabel('Time(sec)');
    ylabel('Activity Label');
    
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小
%    hl = 
%    set(hl, 'Orientation', 'horizon'); % 设置水平显示图线标志
    for i = 1 : length(realSwitchedPos)
            H =  plot([ceil(realSwitchedPos(i)/50), ceil(realSwitchedPos(i)/50)],[-1, 11], 'c--','LineWidth',1);
            hold on;
    end
        
    legend('Smoothed recognition result', 'Real position', 'Candidated position', 'Real position', 'Location', 'southeast');
    legend(H([1 2 3 4]));
    


end