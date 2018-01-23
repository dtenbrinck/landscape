function [opti p] = otsu_thresholding(data, mask)
%OTSU_THRESHOLDING Computes threshold according to Otsu algorithm

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
% -> formula (2),(6) in [1]
omega = cumsum(p);

% compute first-order sumulative moment of historgram
% -> formula (6) in [1]
mu = cumsum( p .* (1:L) );

% compute total mean level of histogram
% -> formula (8) in [1]
mu_t = mu(L);

% compute means
% -> formula (4),(5) in [1]
mu_0 = mu./omega;
mu_1 = (mu_t - mu)./(1 - omega);

% compute class variances
% -> formula (10),(11) in [1]
sigma_0_sq = zeros(1,L);
sigma_1_sq = sigma_0_sq;
for k=1:L
    for i=1:k    
        sigma_0_sq(k) = sigma_0_sq(k) + (i - mu_0(k))^2 * p(i) / max(omega(k),1e-7);
    end
    for i=k+1:L-1    
        sigma_1_sq(k) = sigma_1_sq(k) + (i - mu_1(k))^2 * p(i) / max(1 - omega(k),1e-7);
    end
end


% compute within class variances
% -> formula (13) in [1]
sigma_w_sq = omega .* sigma_0_sq + (1 - omega) .* sigma_1_sq;

% compute between class variances
% -> formula (18) in [1]
sigma_b_sq = (mu_t * omega - mu).^2 ./ max((omega .* (1 - omega)),1e-7);

% compute between class variances
% -> formula (14) in [1]
%omega .* (1 - omega) .* (mu_1 - mu_0).^2;

% compute discriminant measure lambda
% -> formula (12) in [1]
lambda = sigma_b_sq ./ sigma_w_sq;

%figure; hold on; plot(sigma_w_sq, 'b'); plot(sigma_b_sq, 'r'), plot(lambda, 'g'); hold off

% compute best threshold
opti = find(lambda == max(lambda(:)));

%if several thresholds are equally well take the one in the middle
first = 0;
count = 0;
for j = 1:numel(lambda)
   if (abs(lambda(j) - max(lambda(1:end-1)))) < 1e-4
      if first == 0
       first = j;
      end
       count = count + 1; 
   end
end
opti = floor(first + count/2);

% shift threshold according to given data
opti = opti + mini;

% normalize threshold if necessary
if scaled_data
  opti = opti / 500;
end
end