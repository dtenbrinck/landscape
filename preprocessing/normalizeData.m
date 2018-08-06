function normalized = normalizeData( data )

maxi = 255.0;

% if the input data is a struct we normalize each channel data set
if isstruct(data)

  % copy input struct
  normalized = data;
  
  % normalize Dapi channel
  Dapi = normalized.Dapi;
  normalized.Dapi = ( Dapi - min(Dapi(:)) ) / ( max(Dapi(:)) - min(Dapi(:)) ) * maxi;
  
  % normalize GFP channel
  GFP = normalized.GFP;
  normalized.GFP = ( GFP - min(GFP(:)) ) / ( max(GFP(:)) - min(GFP(:)) ) * maxi;
  
  if isfield(normalized,'mCherry')
      % normalize mCherry channel
      mCherry = normalized.mCherry;
      normalized.mCherry = ( mCherry - min(mCherry(:)) ) / ( max(mCherry(:)) - min(mCherry(:)) ) * maxi;
  end
% otherwise we assume we normalize only one channel
else
  
  normalized = ( data - min(data(:)) ) / ( max(data(:)) - min(data(:)) ) * maxi;

end

end

