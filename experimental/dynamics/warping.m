function centroid = warping( segmentation, flow )
% subtracts background flow from mCherry channel
% point of origin is time step 1

% Find centroids
cells=logical(segmentation(step));
centroid=zeros(50,3,size(cells,3));

%% find indices of segmented cells
r=zeros(size(cells,1)*size(cells,2),size(cells,3));
c=zeros(size(cells,1)*size(cells,2),size(cells,3));
for i=1:size(cells,3)
    number=numel(find(cells(:,:,i)));
    [r(1:number,i),c(1:number,i)]=find(cells(:,:,i));
end

for i=1:size(cells,3)
    props=regionprops(cells(:,:,i),'centroid');
    centroid(1:size(props,1),:,i) = cat(1, props.Centroid);
end

%% subtract background flow of centroids (besser flow von segmented cells index abziehen (r und c)!)

centroid_orig=centroid;
bgFlowX=zeros(size(centroid,1),size(centroid,3));
bgFlowY=zeros(size(centroid,1),size(centroid,3));
bgFlowZ=zeros(size(centroid,1),size(centroid,3));

for i=2:size(centroid,3)
    for j=i:size(centroid,3)
        num=sum(centroid(:,1,j)~=0);
        ind1=round(centroid(1:num,1,j));
        ind1(ind1 < 0) = 1;
        ind1(ind1 > 256) = 256;
        ind2=round(centroid(1:num,2,j));
        ind2(ind2 < 0) = 1;
        ind2(ind2 > 256) = 256;
        ind3=round(centroid(1:num,3,j));
        ind3(ind3 < 0) = 1;
        ind3(ind3 > 256) = 256;
        for n=1:num
            bgFlowX(n,j)=flow(2*ind1(n,1),2*ind2(n,1),2*ind3(n,1),j-1,1);
            bgFlowY(n,j)=flow(2*ind1(n,1),2*ind2(n,1),2*ind3(n,1),j-1,2);
            bgFlowZ(n,j)=flow(2*ind1(n,1),2*ind2(n,1),2*ind3(n,1),j-1,3);
        end
        centroid(1:num,1,j)=centroid(1:num,1,j)-bgFlowX(1:num,j);
        centroid(1:num,2,j)=centroid(1:num,2,j)-bgFlowY(1:num,j);
        centroid(1:num,3,j)=centroid(1:num,3,j)-bgFlowY(1:num,j);
    end
end

end