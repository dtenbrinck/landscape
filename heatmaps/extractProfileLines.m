function profileLines = extractProfileLines(mercatorProjections)

% get resolution of mercator projections
[height, width, shells] = size(mercatorProjections);

% compute profile line locations relative to chosen resolution
head_location = round(30/90 * width);
neck_location = round(38/90 * width);
notochord_location = round(48/90 * width);

% create container for profile line data
profileLines = zeros(height,3,shells);

% exract profile lines per shell
for currentShell=1:shells
    
    if currentShell==5
        stop = 1;
    end
    
    % head
    profileLines(:,1,currentShell) = mean(mercatorProjections(:,head_location-1:head_location+1,currentShell),2);
    
    % neck
    profileLines(:,2,currentShell) = mean(mercatorProjections(:,neck_location-1:neck_location+1,currentShell),2);
    
    % notochord
    profileLines(:,3,currentShell) = mean(mercatorProjections(:,notochord_location-1:notochord_location+1,currentShell),2);
end

end