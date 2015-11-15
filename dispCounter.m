function dispCounter(current_iteration, max_iteration)

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
for j=0:log10(current_iteration)
    fprintf('\b'); % delete previous counter display
end

% print new iteration counter
fprintf('%d/%d)', current_iteration, max_iteration);

% allow short break to display the update
pause(.01);

end
