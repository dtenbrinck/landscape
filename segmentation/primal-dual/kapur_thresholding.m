function [threshold p] = kapur_thresholding( data, mask )
%KITTLER_THRESHOLDING Computes threshold according to Kapur algorithm

scaled_data = 0;

% check if mask has been defined
if nargin == 1
  mask = ones(size(data));
end

% check if mask has been defined
if nargin == 1
  mask = ones(size(data));
end

% shift data to have smallest value at 0
data = round(data);
mini = min(data(:));
maxi = max(data(:));

data = data - mini;
L = maxi - mini + 1;

% compute histogram of data
histvector = zeros(1,L);
for i = 1:numel(data)
        histvector(data(i)+1) = histvector(data(i)+1) + mask(i); 
end

% compute a-priori probability
p = histvector / sum(histvector(:));

% compute zeroth-order cumulative moment of histogram
omega = cumsum(p);

% other implementation
% H_0 = zeros(1,L);
% H_1 = H_0;
% for T=1:L
%    for g=1:T    
%        H_0(T) = H_0(T) + ( p(g) / max(omega(T), 1e-5) ) * log( max(p(g), 1e-5) / max(omega(T), 1e-5) );
%    end
%    for g=T+1:L
%        H_1(T) = H_1(T) + ( p(g) / max((1- omega(T)), 1e-5) ) * log( max(p(g), 1e-5) / max(1-omega(T), 1e-5) );
%    end
% end
% 
% H_0 = -H_0;
% H_1 = -H_1;

% compute entropy
H = - cumsum(p .* log(max(p, 1e-5)));

H_0 = log(max(omega,1e-5)) + H ./ max(omega, 1e-5);
H_1 = log(max(1-omega,1e-5)) + (H - H(L)) ./ max(1-omega, 1e-5);

lambda = H_0 + H_1;

lambda(lambda == Inf) = -Inf;
lambda(isnan(lambda)) = -Inf;
threshold = find(lambda == max(lambda(:)));

%if several thresholds are equally well take the one in the middle
first = 0;
count = 0;
for j = 1:numel(lambda)
   if (abs(lambda(j) - max(lambda(:)))) < 1e-5
      if first == 0
       first = j;
      end
       count = count + 1; 
   end
end
threshold = floor(first + count/2);

threshold = threshold + mini;

% normalize threshold if necessary
if scaled_data
  threshold = threshold / 500;
end
end

