function checkDirectory( path )
%CHECKDIRECTORY Summary of this function goes here
%   Detailed explanation goes here

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

