function plotRawSignal(fs, raw_label, axis_data, target_id, target_axis)

figure;
t = (1/fs) * (0:length(raw_label)-1)';
acts = unique(raw_label);
nacts = max(length(acts), 1);
% Plan to draw as many subplots as columns available in acc 
nplots = size(axis_data,2);

% Define colors to use, using built-in colormap with as many entries as
% the number of available activities
cmap = colormap(lines(nacts));
varargin = {'Vertical acceleration'};
for kp = 1:nplots
    
    % Iterate through all the signals passed as input
    subplot(nplots,1,kp)
    
    % Iterate over activities
    for ka = 1:nacts
        % First select data relevant to each activity
 %       [aid, tsel, asel] = getDataForActivityId(ka, acti_label, check_axis, kp);
        
        aid = 1;
        t = (1/fs) * (0:length(raw_label)-1)';
        try %#ok<TRYNC>
            aid = acts(ka);
        end
        sel = (raw_label == aid);
        tsel = t;
        tsel(~sel) = NaN;
        asel = axis_data(:,kp);
        asel(~sel) = NaN;
    
        % Then plot each activity with a different color
        plot(tsel, asel, 'Color',cmap(aid,:),'LineWidth',1.5);
        % and keep axis on hold to overlay next plot 
        hold on
    end
    
    % Seal plots on current axis - plotting of current signal finished
    hold off
    
    % Customize axis box for current subplot
    grid on
    xlabel('time (s)')
    ylabel('a_z (m s^{-2})')
    xlim([t(1), t(end)])
    t_title = [ 'Raw signal of target axis: ', target_axis, ' of target id: ', num2str(target_id)];
    
    title(t_title);
    %{
    if(length(varargin) >= 1)
        if(iscell(varargin{1}))
            title(varargin{1}{kp})
        elseif(ischar(varargin{1}))
            title(varargin{1})
        end
    end
    %}
end

% To minimize visual clutter, only add legend to last plot
addActivityLegend(acts)

end
