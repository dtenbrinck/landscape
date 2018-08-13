function dispCounter(current_iteration, max_iteration)
% DISPCOUNTER Displays current iteration number and maximum iteration
% number as an iteration scheme progresses by writing into the same output
% line.
%
% author: Daniel Tenbrinck
% last version: 08/12/16

% delete the last bracket
fprintf('\b');

% determine how many characters have to be deleted for number of maximum
% iterations
for j=0:log10(max_iteration)
    fprintf('\b'); % delete previous counter display
end

% delete the / character
fprintf('\b');

% determine how many characters have to be deleted for current iteration
% number
% the logical operation is necessary for the case: current_iteration == 1
for j=0:log10(current_iteration-1 + ~(current_iteration-1))
    fprintf('\b'); % delete previous counter display
end

% print new iteration counter
fprintf('\n(%d/%d)', current_iteration, max_iteration);

% allow short break to display the update
pause(.0001);

end
