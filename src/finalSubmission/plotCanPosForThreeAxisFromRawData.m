function plotCanPosForThreeAxisFromRawData(canPos, realPos, titleStr)

    yAxis = ones(length(canPos),1) * 2;
    plot(ceil(canPos / 50), yAxis, 'b*');
    hold on;
    
    yAxis = ones(length(realPos),1) * 3;
    plot(ceil(realPos / 50), yAxis, 'mo');
    hold on;   
    
    title(titleStr);

    xlabel('Time(sec)');
    ylabel('Position');
    
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小
    hl = legend('Candidated Position', 'Real position', 'Location', 'southeast');
    set(hl, 'Orientation', 'horizon'); % 设置水平显示图线标志
    set(gca,'YLim',[0 5]);%X轴的数据显示范围

end