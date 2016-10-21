function checkDirectory( path )
%CHECKDIRECTORY Summary of this function goes here
%   Detailed explanation goes here

% check first if we are in root directory
if ~exist('./application','dir')
    error('Please start script only in root directory of software!');
end

% create parent folder
if ~exist(path,'dir')
    mkdir('./', path);
end

% create subdirs for checked data sets
if ~exist([path '/accepted'],'dir')
    mkdir(path, 'accepted');
end

if ~exist([path '/rejected'],'dir')
    mkdir(path, 'rejected');
end

% create subdir for buggy data
if ~exist([path '/bug'],'dir')
    mkdir(path, 'bug');
end


end

