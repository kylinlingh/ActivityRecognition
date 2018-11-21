function plotRawSignal(fs,cachedData, check_id, check_axis)
figure;
%% Read data
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);
%%
t = (1/fs) * (0:length(acti_label)-1)';
acti_label = acti_label(id_data == check_id);
check_axis = axis_data(id_data == check_id);
acts = unique(acti_label);
nacts = max(length(acts), 1);
% Plan to draw as many subplots as columns available in acc 
nplots = size(check_axis,2);

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
        t = (1/fs) * (0:length(acti_label)-1)';
        try %#ok<TRYNC>
            aid = acts(ka);
        end
        sel = (acti_label == aid);
        tsel = t;
        tsel(~sel) = NaN;
        asel = check_axis(:,kp);
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
    if(length(varargin) >= 1)
        if(iscell(varargin{1}))
            title(varargin{1}{kp})
        elseif(ischar(varargin{1}))
            title(varargin{1})
        end
    end
end

% To minimize visual clutter, only add legend to last plot
addActivityLegend(acts)

end
