
load('loaddataforid33.mat');
%%
cachedData = [zaxis, label + 1];
walkingData = cachedData(cachedData(:,2) == 1);

subplot(211);
plot(walkingData);
%% Moving average
win_size = 20;
begin_index = 1136;
end_index 




%%
for acti = 1:6
    actiData = cachedData(cachedData(:,2) == acti);
    
   fprintf('%d\n', acti); 
end
    


%%
