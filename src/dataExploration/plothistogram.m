load('loaddataforid33.mat');
%%
labeladd = label + 1;
%labeladd = label ;
checkdata = [zaxis, labeladd]

%%
subplot(611);
plotHistogram('Walking', checkdata);
subplot(612);
plotHistogram('Jogging', checkdata);
subplot(613);
plotHistogram('Upstairs', checkdata);
subplot(614);
plotHistogram('Downstairs', checkdata);
subplot(615);
plotHistogram('Sitting', checkdata);
subplot(616);
plotHistogram('Standing', checkdata);

%%
function [ha, datasel] = plotHistogram(actstr, checkdata)

data = checkdata(:,1);
% Get all activity labels
actlabels = getActivityNames();
% Identify ID of activity in actstr
actid = find(strcmp(actlabels,actstr))  ;
fprintf('%s : %d\n', actstr, actid);
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
h = histogram(datasel); 

% Customizations - colouring and labeling
nacts = length(actlabels);

cmap = colormap(lines(nacts));
col = cmap(actid,:);

h.EdgeColor = col;
h.FaceColor = col;
h.FaceAlpha = 0.8;

xlabel('Acceleration Values (m \cdot s^{-2})')
ylabel('Occurencies')
xlim([min(data), max(data)])

addActivityLegend(actid)

ha = h.Parent;

end

%%
