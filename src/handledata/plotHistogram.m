function plotHistogram(cachedData, check_id, check_axis)

% Read data
id_data = cachedData(:,1);
acti_label = cachedData(:,2);

switch check_axis
    case 'x', component = 4;
    case 'y', component = 5;
    case 'z', component = 6;
end
axis_data = cachedData(:,component);
check_axis = axis_data(id_data == check_id);
per_label = acti_label(id_data == check_id);

acts = unique(acti_label);
nacts = max(length(acts), 1);
%%


%% Plot histogram
figure;
checkdata = [check_axis, per_label];
subplot(611);
plotSubHistogram('Walking', checkdata);
subplot(612);
plotSubHistogram('Jogging', checkdata);
subplot(613);
plotSubHistogram('Upstairs', checkdata);
subplot(614);
plotSubHistogram('Downstairs', checkdata);
subplot(615);
plotSubHistogram('Sitting', checkdata);
subplot(616);
plotSubHistogram('Standing', checkdata);

function [ha, datasel] = plotSubHistogram(actstr, checkdata)

data = checkdata(:,1);
% Get all activity labels
actlabels = getActivityNames();
% Identify ID of activity in actstr
actid = find(strcmp(actlabels,actstr))  ;
%fprintf('%s : %d\n', actstr, actid);
% Select only relevant data samples
sel = (checkdata(:,2) == actid);
datasel = data(sel);

%{
[mu, sigma] = normfit(datasel);
d = pdf('norm', datasel, mu, sigma);

plot(datasel, d, '.');
%}

% Plot histogram with predefine binwidth
%h = histogram(datasel,'BinWidth',0.5); 

h = histogram(datasel, 'Normalization', 'probability'); 

% Customizations - colouring and labeling
nacts = length(actlabels);

cmap = colormap(lines(nacts));
col = cmap(actid,:);

h.EdgeColor = col;
h.FaceColor = col;
h.FaceAlpha = 0.8;

xlabel('Acceleration Values (m \cdot s^{-2})')
ylabel('Frequencies')
xlim([min(data), max(data)])

addActivityLegend(actid)

ha = h.Parent;
end

end