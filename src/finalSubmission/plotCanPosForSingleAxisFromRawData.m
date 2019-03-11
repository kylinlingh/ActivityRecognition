
function plotCanPosForSingleAxisFromRawData(testId, titleStr, rawAxisData, realSwitchedPos, canPosFromRawData)
% 作图，画出原始传感器数据和动作切换点的组合图
    
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
    
    set(gca, 'FontSize', 20); % 设置坐标轴字体大小
%    hl = 
%    set(hl, 'Orientation', 'horizon'); % 设置水平显示图线标志
    for i = 1 : length(realSwitchedPos)
            plot([ceil(realSwitchedPos(i)/50), ceil(realSwitchedPos(i)/50)],[-10, 40], 'c--','LineWidth',1);
            hold on;
    end
        
    legend('Raw signal', 'Real position', 'Candidated position', 'Real position', 'Location', 'southeast');
    legend(H([1 2 3 4]));
end


