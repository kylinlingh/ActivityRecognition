%% Load cached Data
clear;
curPath = pwd;
[filepath, filename, ext] = fileparts(curPath);
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'cachedRawData.mat');
%cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_ALL_HANDS.mat');
cacheDataPath = fullfile(filepath, filename, 'dataset', 'cachedData', 'HKUST_LEFT_HAND.mat');

load(cacheDataPath);
clearvars -except cachedData

%% Find the minimum length of same activity
raw_label = cachedData(:,2);

min_length = intmax;
pre_label = raw_label(1);
label_count = 1;
for i = 2 : length(raw_label)
    cur_label = raw_label(i);
    if cur_label ~= pre_label 
        if label_count < min_length
           min_length = label_count; 
%           fprintf("%d - %d\n",i, min_length);
        end
        label_count = 1;
        pre_label = cur_label;
    else
        label_count = label_count + 1;
    end
end
clearvars -except cachedData  min_length

%%
%{
Attention: threshold setting includes such below parameters:
    pre_threshold
    bak_threshold
    
    win_check
    valid_deviation
%}
pre_threshold = [5, 6, 7, 8, 9, 10];
bak_threshold = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6];
win_check = [1, 2, 3, 4, 5, 6];
valid_deviation = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
target_id = 25;

tic;
parameters_matrix = cartprod(pre_threshold, bak_threshold, win_check, valid_deviation);
searchParameterMatrix(cachedData, min_length, target_id ,parameters_matrix);
%%

function searchParameterMatrix(cachedData, min_length, target_id, parameter_matrix)
    auc_result = zeros(1, length(parameter_matrix));
    for i = 1 : length(parameter_matrix)
       fprintf('round: %d\n', i);
       pre_threshold = parameter_matrix(i, 1); 
       bak_threshold = parameter_matrix(i, 2);
       win_check = parameter_matrix(i, 3);
       valid_deviation = parameter_matrix(i, 4);
       
       [raw_label, all_predicted_locs, ~, real_locs] = predictSinglePerson(cachedData, min_length, target_id, pre_threshold, bak_threshold, win_check);
       [predict_result, true_result] = calculateMetrics(all_predicted_locs, real_locs, length(raw_label), valid_deviation);
       auc = calAUC(true_result, predict_result);
       auc_result(i) = auc;
       toc;
    end 
end

function [result]=calAUC(test_targets,output)
    %计算AUC值,test_targets为原始样本标签,output为分类器得到的标签
    %均为行或列向量
    [A,I]=sort(output);
    M=0;N=0;
    for i=1:length(output)
        if(test_targets(i)==1)
            M=M+1;
        else
            N=N+1;
        end
    end
    sigma=0;
    for i=M+N:-1:1
        if(test_targets(I(i))==1)
            sigma=sigma+i;
        end
    end
    result=(sigma-(M+1)*M/2)/(M*N);
end

function X = cartprod(varargin)
    %CARTPROD Cartesian product of multiple sets.
    %
    %   X = CARTPROD(A,B,C,...) returns the cartesian product of the sets 
    %   A,B,C, etc, where A,B,C, are numerical vectors.  
    %
    %   Example: A = [-1 -3 -5];   B = [10 11];   C = [0 1];
    % 
    %   X = cartprod(A,B,C)
    %   X =
    % 
    %     -5    10     0
    %     -3    10     0
    %     -1    10     0
    %     -5    11     0
    %     -3    11     0
    %     -1    11     0
    %     -5    10     1
    %     -3    10     1
    %     -1    10     1
    %     -5    11     1
    %     -3    11     1
    %     -1    11     1
    %
    %   This function requires IND2SUBVECT, also available (I hope) on the MathWorks 
    %   File Exchange site.


    numSets = length(varargin);
    for i = 1:numSets
        thisSet = sort(varargin{i});
        if ~isequal(prod(size(thisSet)),length(thisSet))
            error('All inputs must be vectors.')
        end
        if ~isnumeric(thisSet)
            error('All inputs must be numeric.')
        end
        if ~isequal(thisSet,unique(thisSet))
            error(['Input set' ' ' num2str(i) ' ' 'contains duplicated elements.'])
        end
        sizeThisSet(i) = length(thisSet);
        varargin{i} = thisSet;
    end

    X = zeros(prod(sizeThisSet),numSets);
    for i = 1:size(X,1)

        % Envision imaginary n-d array with dimension "sizeThisSet" ...
        % = length(varargin{1}) x length(varargin{2}) x ...

        ixVect = ind2subVect(sizeThisSet,i);

        for j = 1:numSets
            X(i,j) = varargin{j}(ixVect(j));
        end
    end
end

function X = ind2subVect(siz,ndx)
%IND2SUBVECT Multiple subscripts from linear index.
%   IND2SUBVECT is used to determine the equivalent subscript values
%   corresponding to a given single index into an array.
%
%   X = IND2SUBVECT(SIZ,IND) returns the matrix X = [I J] containing the
%   equivalent row and column subscripts corresponding to the index
%   matrix IND for a matrix of size SIZ.  
%
%   For N-D arrays, X = IND2SUBVECT(SIZ,IND) returns matrix X = [I J K ...]
%   containing the equivalent N-D array subscripts equivalent to IND for 
%   an array of size SIZ.
%
%   See also IND2SUB.  (IND2SUBVECT makes a one-line change to IND2SUB so as
%   to return a vector of N indices rather than retuning N individual
%   variables.)%IND2SUBVECT Multiple subscripts from linear index.
%   IND2SUBVECT is used to determine the equivalent subscript values
%   corresponding to a given single index into an array.
%
%   X = IND2SUBVECT(SIZ,IND) returns the matrix X = [I J] containing the
%   equivalent row and column subscripts corresponding to the index
%   matrix IND for a matrix of size SIZ.  
%
%   For N-D arrays, X = IND2SUBVECT(SIZ,IND) returns matrix X = [I J K ...]
%   containing the equivalent N-D array subscripts equivalent to IND for 
%   an array of size SIZ.
%
%   See also IND2SUB.  (IND2SUBVECT makes a one-line change to IND2SUB so as
%   to return a vector of N indices rather than returning N individual
%   variables.)
 

% All MathWorks' code from IND2SUB, except as noted:

    n = length(siz);
    k = [1 cumprod(siz(1:end-1))];
    ndx = ndx - 1;
    for i = n:-1:1,
      X(i) = floor(ndx/k(i))+1;      % replaced "varargout{i}" with "X(i)"
      ndx = rem(ndx,k(i));
    end
end
