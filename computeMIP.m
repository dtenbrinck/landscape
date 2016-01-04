function MIP= computeMIP( data )

  % check if data has three dimensions
  if ndims(data) == 3
    MIP = max(data, [], 3);
  else
    error('Data must be three-dimensional to compute a maximum intensity projection (MIP).');
  end
  
end

