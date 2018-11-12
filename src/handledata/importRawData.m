%% Get the path of data file.
curPath = pwd
[filepath, filename, ext] = fileparts(curPath);
rawDataPath = fullfile(filepath, filename, 'dataset', 'rawdata');
rawDataFileName = fullfile(rawDataPath, 'WISDM_ar_v1.1_raw.txt');
if (exist(rawDataFileName) == 0)
    disp('Raw file doesnt exist');
else
    fprintf('File %s detected\n', rawDataFileName);
end
%% Read file
delimiter = ',';
startRow = 1;
endRow = inf;
formatSpec = '%f%f%f%f%f%f';
fileID = fopen(rawDataFileName, 'r');
%%
%dataArray = textscan(fileID, formatSpec, endRow(1) - startRow(1) + 1, 'Delimiter', delimiter, 'MultipleDelimsAsOne',true, 'EmptyValue', NaN, 'HeaderLines',startRow(1)-1, 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1) - startRow(1) + 1, 'Delimiter', delimiter, 'MultipleDelimsAsOne',true, 'EmptyValue', NaN);
fclose(fileID);
%% Create output variable
cachedData = [dataArray{1:end}];

%% Plus one to the activity label
cachedData(:,2) = cachedData(:,2) + 1;

%%
savedFileName = 'cachedRawData.mat'
savedFilePath = fullfile(filepath, filename, 'dataset', 'cachedData', savedFileName);
save(savedFilePath, 'cachedData');