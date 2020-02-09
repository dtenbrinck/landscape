function profileLines = extractProfileLines(mercatorProjections)

% get resolution of mercator projections
[height, width, shells] = size(mercatorProjections);

% compute profile line locations relative to chosen resolution
head_location = round(28/90 * width);
neck_location = round(38/90 * width);
notochord_location = round(48/90 * width);

% create container for profile line data
profileLines = zeros(height,3,shells);

% exract profile lines per shell
for currentShell=1:shells
    
    % head
    profileLines(:,1,currentShell) = mercatorProjections(:,head_location,currentShell);
    
    % neck
    profileLines(:,2,currentShell) = mercatorProjections(:,neck_location,currentShell);
    
    % notochord
    profileLines(:,3,currentShell) = mercatorProjections(:,notochord_location,currentShell);
end

end