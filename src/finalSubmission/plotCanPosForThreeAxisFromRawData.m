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
    
    set(gca, 'FontSize', 20); % ���������������С
    hl = legend('Candidated Position', 'Real position', 'Location', 'southeast');
    set(hl, 'Orientation', 'horizon'); % ����ˮƽ��ʾͼ�߱�־
    set(gca,'YLim',[0 5]);%X���������ʾ��Χ

end