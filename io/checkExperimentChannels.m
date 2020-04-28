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
    
    % if more than one underscore is present abort
    if nb_underscores > 1
        error("Inconsistent file naming scheme. Please name your file <experiment_number>_<channel>.tif");
    end
    
    % get the integer number between second-last and last underscore
    experimentNumbers(i) ...
        = str2double(...
        fileNames{i}(1:indices{i,1}(nb_underscores)-1));
end

% initialize cell array assuming each experiment has three data sets
experimentSets = cell(max(experimentNumbers),3);

% extract number of experiments
nb_experiments = unique(experimentNumbers)';

% iterate over all experiments and check for validity
for i = nb_experiments
    
    % get indices of data sets of current experiment
    indices = find(experimentNumbers==i);
    
    % validity check if current experiment has exactly 3 data sets
    if size(indices,1) ~= 3
        warning(['Experiment #',num2str(i),' does not have three data sets! Will be ignored!'])
        continue;
    end
    
    % TODO: There is no exception handling for the following lines!
    % ATTENTION: Having an experiment called "DAPI" will cause a bug  
    
    % get Dapi data set for current experiment
    index = strfind(fileNames(indices),'Dapi');
    rightind = find(~cellfun(@isempty,index));
    experimentSets{i,1} = fileNames(indices(rightind));
    
    % get GFP data set for current experiment
    index = strfind(fileNames(indices),'GFP');
    rightind = find(~cellfun(@isempty,index));
    experimentSets{i,2} = fileNames(indices(rightind));
    
    % get mCherry data set for current experiment
    index = strfind(fileNames(indices),'mCherry');
    rightind = find(~cellfun(@isempty,index));
    experimentSets{i,3} = fileNames(indices(rightind));
end

% TODO: The whole experiment row would have to be deleted instead!

% delete empty cells
experimentSets = reshape(experimentSets(~cellfun('isempty',experimentSets)),[],3);

% Warning message if no experiments could be found
if isempty(experimentSets)
    error('No valid experiment data could be found in chosen directory. Make sure you name the files containing strings like ''GFP'', ''DAPI'', or ''mCherry''.');
end

end