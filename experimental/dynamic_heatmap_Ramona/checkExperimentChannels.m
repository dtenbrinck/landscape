function experimentSets = checkExperimentChannels( fileNames )
%CHECKEXPERIMENTCHANNELS Summary of this function goes here
%   Detailed explanation goes here

% search for underscores in filenames
indices = strfind(fileNames,'_');

% get the experiment numbers from file names
experimentNumbers = zeros(size(fileNames));
for i=1:size(fileNames,1)
    
    % get number of underscores in current file name
    nb_underscores = size(indices{i,1},2);
    
    % get the integer number between first and second underscore
    experimentNumbers(i) ...
        = str2double(...
        fileNames{i}(indices{i,1}(1)+1:indices{i,1}(2)-1));
end

% initialize cell array assuming each experiment has two data sets
experimentSets = cell(max(experimentNumbers),2);

% extract number of experiments
nb_experiments = unique(experimentNumbers)';

% iterate over all experiments and check for validity
for i = nb_experiments
    
    % get indices of data sets of current experiment
    indices = find(experimentNumbers==i);
    
    % validity check if current experiment has exactly 3 data sets
    if size(indices,1) ~= 2
        warning(['Experiment #',num2str(i),' does not have two data sets! Will be ignored!'])
        continue;
    end 
    
    % get Dapi / BFP data set for current experiment
    index = strfind(fileNames(indices),'BFP');
    rightind = find(~cellfun(@isempty,index));
    experimentSets{i,1} = fileNames(indices(rightind));
    
    % get GFP data set for current experiment
    index = strfind(fileNames(indices),'GFP');
    rightind = find(~cellfun(@isempty,index));
    experimentSets{i,2} = fileNames(indices(rightind));
    
end

% TODO: The whole experiment row would have to be deleted instead!

% delete empty cells
experimentSets = reshape(experimentSets(~cellfun('isempty',experimentSets)),[],2);

end

