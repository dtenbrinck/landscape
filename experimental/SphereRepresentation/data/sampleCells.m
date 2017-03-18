function [ C_s, counts, indices ] = sampleCells( C, xs, ys, zs, shellInterval )
%SAMPLECELLS This function samples the cells onto the grid points of the
%sphere

%% MAIN CODE

% Only take the cells that are in the shell
C =...
    C((sum(sqrt(sum(C.^2,2))>=shellInterval(2)&...
    sqrt(sum(C.^2,2))<=shellInterval(1),2)~=0),:);

%Normalize all cells from the inner onto the sphere
C = C./repmat(sqrt(sum(C.^2,2)),[1,3]);

% Interpolate the cells onto the nearest point of the sphere.
C_s = zeros(size(C));
sample_indices = zeros(size(C,1),1);
for i=1:size(C,1)
    [~,ind]=min(sqrt(sum(([xs(:),ys(:),zs(:)]-repmat(C(i,:),[size(xs(:),1),1])).^2,2)));
    C_s(i,:) = [xs(ind),ys(ind),zs(ind)];
    sample_indices(i) = ind;
end

% Compute the unique values of the sample_indices to get the number of
% equaivalant values with hist.
[u_sampled_indices,ia,~]=unique(sample_indices);

% Count cells that are on the same sample
[counts,indices] = hist(sample_indices,u_sampled_indices);

% Sort the cell coordinates as counts
C_s = C_s(ia,:);
end

