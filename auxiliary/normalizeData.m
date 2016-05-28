function normalized = normalizeData( data )
%   Detailed explanation goes here

normalized = ( data - min(data(:)) ) / ( max(data(:)) - min(data(:)) );

end

