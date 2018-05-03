function stop = outfun(x, optimValues, state)
stop = false;
hold on;
iter = optimValues.iteration;
plot(iter,x(1),'r.');
plot(iter,x(2),'b.');
plot(iter,x(3),'g.');
drawnow
end