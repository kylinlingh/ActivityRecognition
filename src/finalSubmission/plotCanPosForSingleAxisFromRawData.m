
function plotCanPosForSingleAxisFromRawData(testId, titleStr, rawAxisData, realSwitchedPos, canPosFromRawData)
% ��ͼ������ԭʼ���������ݺͶ����л�������ͼ
    
    figure;
    t = (1/50) * (0:length(rawAxisData)-1)';
    
    plot(t, rawAxisData, 'b-');
    hold on;

    yAxis = ones(length(realSwitchedPos),1) * 35;
    plot(ceil(realSwitchedPos / 50), yAxis, 'b*');
    hold on;
    
    yAxis = ones(length(canPosFromRawData),1) * 38;
    H = plot(ceil(canPosFromRawData / 50), yAxis, 'mo');
    hold on;   
    
    title(titleStr);

    xlabel('Time(sec)');
    ylabel('{Acceleration(m/s^2)}');
    
    set(gca, 'FontSize', 20); % ���������������С
%    hl = 
%    set(hl, 'Orientation', 'horizon'); % ����ˮƽ��ʾͼ�߱�־
    for i = 1 : length(realSwitchedPos)
            plot([ceil(realSwitchedPos(i)/50), ceil(realSwitchedPos(i)/50)],[-10, 40], 'c--','LineWidth',1);
            hold on;
    end
        
    legend('Raw signal', 'Real position', 'Candidated position', 'Real position', 'Location', 'southeast');
    legend(H([1 2 3 4]));
end


