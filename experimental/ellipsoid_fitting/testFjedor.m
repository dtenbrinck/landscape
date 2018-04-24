function testFjedor (W, v)
A = W;
tic
for i=1:1000
A = W*v;
end
toc
tic
for i=1:1000
A = W';
end
toc

tic
for i=1:1000
A = W.';
end
toc
end