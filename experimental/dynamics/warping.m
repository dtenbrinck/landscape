function centroid = warping( coordinates, flow )
% subtracts background flow from mCherry channel
% point of origin is time step 1

% Find centroids
count=zeros(size(coordinates,2),1);
for step=1:size(coordinates,2)
    count(step)=size(coordinates{1,step},2);
end
numCells=max(count);
%cells=logical(coordinates);
% centroid=zeros(numCells,3,size(coordinates,2));

%% find indices of segmented cells
% r=zeros(size(cells,1)*size(cells,2),size(cells,3));
% c=zeros(size(cells,1)*size(cells,2),size(cells,3));
% for i=1:size(cells,3)
%     number=numel(find(cells(:,:,i)));
%     [r(1:number,i),c(1:number,i)]=find(cells(:,:,i));
% end

% for step=1:size(coordinates,2)
% %     props=regionprops(coordinates{1,step},'centroid');
%     centroid(1:size(props,1),:,step) = cat(1, props.Centroid);
% end

%% subtract background flow of centroids
% bgFlowX=zeros(size(centroid,1),size(centroid,3));
% bgFlowY=zeros(size(centroid,1),size(centroid,3));
% bgFlowZ=zeros(size(centroid,1),size(centroid,3));
% for step=2:size(coordinates,2)
%     for j=step:size(coordinates,2)
%         num=sum(centroid(:,1,j)~=0);
%         ind1=round(centroid(1:num,1,j));
%         ind1(ind1 < 0) = 1;
%         ind1(ind1 > 256) = 256;
%         ind2=round(centroid(1:num,2,j));
%         ind2(ind2 < 0) = 1;
%         ind2(ind2 > 256) = 256;
%         ind3=round(centroid(1:num,3,j));
%         ind3(ind3 < 0) = 1;
%         ind3(ind3 > 256) = 256;
%         for n=1:num
%             bgFlowX(n,j)=flow(2*ind1(n,1),2*ind2(n,1),2*ind3(n,1),j-1,1);
%             bgFlowY(n,j)=flow(2*ind1(n,1),2*ind2(n,1),2*ind3(n,1),j-1,2);
%             bgFlowZ(n,j)=flow(2*ind1(n,1),2*ind2(n,1),2*ind3(n,1),j-1,3);
%         end
%         centroid(1:num,1,j)=centroid(1:num,1,j)-bgFlowX(1:num,j);
%         centroid(1:num,2,j)=centroid(1:num,2,j)-bgFlowY(1:num,j);
%         centroid(1:num,3,j)=centroid(1:num,3,j)-bgFlowY(1:num,j);
%     end
% end

centroid=coordinates;
for step=2:size(coordinates,2)
    for j=step:size(coordinates,2)
        for i=1:count(j)
           centroid{1,j}(1,i) = centroid{1,j}(1,i)-flow(coordinates{1,j}(2,i),coordinates{1,j}(1,i),coordinates{1,j}(3,i),j-1,2);
           centroid{1,j}(2,i) = centroid{1,j}(2,i)-flow(coordinates{1,j}(2,i),coordinates{1,j}(1,i),coordinates{1,j}(3,i),j-1,1);
           centroid{1,j}(3,i) = centroid{1,j}(3,i)-flow(coordinates{1,j}(2,i),coordinates{1,j}(1,i),coordinates{1,j}(3,i),j-1,3);
        end
    end
end
for step=1:size(coordinates,2)
    centroid{1,step} = round(centroid{1,step});
end

end