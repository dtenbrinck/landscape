function normalized = normalizeData( data )

maxi = 255.0;

% copy input struct
normalized = data;

% if the input data is a struct we normalize each channel data set
if isstruct(data)
    
    % determine number of timepoints (in case of dynamic data)
    numberOfTimepoints = size(data.Dapi,4);
    
    % normalize each timepoint separately
    for t = 1:numberOfTimepoints
        
        % normalize Dapi channel
        Dapi = normalized.Dapi(:,:,:,t);
        normalized.Dapi(:,:,:,t) = ( Dapi - min(Dapi(:)) ) / ( max(Dapi(:)) - min(Dapi(:)) ) * maxi;
        
        % normalize GFP channel
        GFP = normalized.GFP(:,:,:,t);
        normalized.GFP(:,:,:,t) = ( GFP - min(GFP(:)) ) / ( max(GFP(:)) - min(GFP(:)) ) * maxi;
        
        % normalize mCherry channel
        mCherry = normalized.mCherry(:,:,:,t);
        normalized.mCherry(:,:,:,t) = ( mCherry - min(mCherry(:)) ) / ( max(mCherry(:)) - min(mCherry(:)) ) * maxi;
        
    end
    
    % otherwise we assume we normalize only one channel
else
    
    % determine number of timepoints (in case of dynamic data)
    numberOfTimepoints = size(data,4);
    
    % normalize each timepoint separately
    for t = 1:numberOfTimepoints
        
        tmp_data = data(:,:,:,t);
        normalized(:,:,:,t) = ( tmp_data - min(tmp_data(:)) ) / ( max(tmp_data(:)) - min(tmp_data(:)) ) * maxi;
        
    end
    
end

