function [threshold p] = kittler_thresholding( data, mask )
%KITTLER_THRESHOLDING Computes threshold according to Kittler algorithm

scaled_data = 0;

% check if mask has been defined
if nargin == 1
  mask = ones(size(data));
end

% check if data is normalized between 0 and 1
if(max(data(:)) <= 1)
  data = data * 500;
  scaled_data = 1;
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

% compute first-order sumulative moment of historgram
mu = cumsum( p .* (1:L) );

% compute total mean level of histogram
mu_t = mu(L);

% compute means
mu_0 = mu./omega;
mu_1 = (mu_t - mu)./(1 - omega);



% compute class variances
sigma_0 = zeros(1,L);
sigma_1 = sigma_0;
for k=1:L
    for i=1:k    
        sigma_0(k) = sigma_0(k) + (i - mu_0(k))^2 * p(i) / max(omega(k), 1e-5);
    end
    for i=k+1:L    
        sigma_1(k) = sigma_1(k) + (i - mu_1(k))^2 * p(i) / max(1 - omega(k), 1e-5);
    end
end

sigma_0 = sqrt(sigma_0);
sigma_1 = sqrt(sigma_1);


lambda = omega .* log(sigma_0) + (1 - omega) .* log(sigma_1) - omega .* log(omega) - (1-omega) .* log(1-omega);

lambda(lambda == -Inf) = +Inf;
threshold = find(lambda == min(lambda(:)));

%if several thresholds are equally well take the one in the middle
first = 0;
count = 0;
for j = 1:numel(lambda)
   if (abs(lambda(j) - min(lambda(:)))) < 1e-5
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

