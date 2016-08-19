function normalized = normalizeData( data )

% if the input data is a struct we normalize each channel data set
if isstruct(data)

  % copy input struct
  normalized = data;
  
  % normalize Dapi channel
  Dapi = normalized.Dapi;
  normalized.Dapi = ( Dapi - min(Dapi(:)) ) / ( max(Dapi(:)) - min(Dapi(:)) );
  
  % normalize GFP channel
  GFP = normalized.GFP;
  normalized.GFP = ( GFP - min(GFP(:)) ) / ( max(GFP(:)) - min(GFP(:)) );
  
  % normalize mCherry channel
  mCherry = normalized.mCherry;
  normalized.mCherry = ( mCherry - min(mCherry(:)) ) / ( max(mCherry(:)) - min(mCherry(:)) );
  
% otherwise we assume we normalize only one channel
else
  
  normalized = ( data - min(data(:)) ) / ( max(data(:)) - min(data(:)) );

end

end

