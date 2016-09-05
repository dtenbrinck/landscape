function labels = k_means_clustering(f,k,valency)
% K_MEANS_CLUSTERING Performs k-means clustering on a given input image f for
% a given number of output classes k. With the additional parameter the
% valency of the data can be specified, i.e., 'real' or 'vectorial'.
% The image f can have any amount of channels, i.e., one for grayscale
% images, three for RGB images, or even more for hyperspectral images.
% If the valency of the data struct f is vectorial the last dimension is
% interpreted as dimension of image space, e.g., for RGB color images.
% Without specification real-valued data is assumed.
%
% ATTENTION: The output of this algorithm is not deterministic as the
% labels are initialized randomly.
%
% author: Daniel Tenbrinck
% last version: 08/13/16

% set default case of real-valued data if uses didn't specify
if nargin == 2
  valency = 'real';
end

% determine size of given data struct f
size_f = size(f);


% interprete last dimension as range in case of vectorial-valued data
if strcmp(valency, 'vectorial')
  
  % get number of channels
  channels = size_f(end);
  
  % get number of elements to be processed
  nb_elements = prod(size_f(1:end-1));
  
else % the real-valued case
  
  % the range is one-dimensional
  channels = 1;
  
   % get number of elements to be processed
  nb_elements = prod(size_f);
  
end

% restructure data to be a vector of elements
f = reshape(f, [nb_elements, channels]);

% initialize container for cluster centers
cluster_centers = zeros(channels,k);

% initialize random labels in {1,...,k} for each pixel
labels = ceil(rand(nb_elements,1) * k);

% set parameters for terminating condition of iterative loop
threshold = 1e-12;  % threshold for relative changes per iteration
max_iteration = 50;  % maximum number of iterations

% initialize termination variables of iterative loop
iteration = 0;
rel_change = Inf;
fprintf(['Performing k-means clustering in iteration (0/' num2str(max_iteration) ')']);
while iteration < max_iteration && rel_change > threshold
  
  % save current labels as old labels
  labels_old = labels;
  
  % for each label compute new cluster center
  for label=1:k
    
    % get indices of elements with current label
    indices = find(labels == label);
    
    % if no element is associated to this label reinitialize cluster center
    % randomly
    if isempty(indices)
      cluster_centers(:,label) = rand(channels,1) * ...
         (max(f(:)) - min(f(:))) + min(f(:));
      continue;
    end
    
    % compute mean over all elements labeled with current label
    cluster_centers(:,label) = mean(f(indices,:))';
  end
  
  % compute norm of cluster centers
  cluster_centers_norm = sqrt(sum(cluster_centers.^2,1));
  
  % get indices for ordered cluster centers wrt. their norm
  [~, I] = sort(cluster_centers_norm);
  
  % sort cluster centers according to their norm
  cluster_centers = cluster_centers(:,I);
  
  % compute squared distances to all cluster centers
  sq_differences = ( repmat(f, [1 1 k]) - repmat(reshape(cluster_centers, [1 channels k]), [nb_elements 1 1]) ).^2;
  
  % compute Euclidean distances
  differences = sqrt(sum(sq_differences,2));
  
  % get indices for ordered distances
  [~, I] = sort(differences,3);
  
  % reshape I to a common structure
  %I = reshape(I,prod(size_omega) * channels, k);
  
  % reassign labels
  labels = reshape(I(:,:,1),[nb_elements, 1]);
  
  % compute relative change induced by new labeling
  rel_change = norm(labels(:) - labels_old(:)) / norm(labels_old(:));
  
  % update iteration counter
  iteration = iteration+1;
  
  % display current iteration
  dispCounter(iteration,max_iteration);
end
disp(' ... finished!');

% reshape labels into same data structure as the input data f
if strcmp(valency, 'vectorial')
  labels = reshape(labels, size_f(1:end-1));
else
  labels = reshape(labels, size_f); 
end

end