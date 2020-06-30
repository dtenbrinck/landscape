function p = adjustParameters(p, changes)

if isequal(changes, 0)
    return
else
    p.datatype = changes.datatype;
    p.resolution = changes.resolution;
    p.mCherryseg.cellSize = changes.mCherryseg.cellSize;
    
    p.ellipsoidFitting.regularisationParams.mu0 = changes.ellipsoidFitting.regularisationParams.mu0;
    p.ellipsoidFitting.regularisationParams.mu1 = changes.ellipsoidFitting.regularisationParams.mu1;
    p.ellipsoidFitting.regularisationParams.mu2 = changes.ellipsoidFitting.regularisationParams.mu2;
    p.ellipsoidFitting.pcaType = changes.ellipsoidFitting.pcaType;
    p.reg.characteristicWeight = changes.reg.characteristicWeight;
    p.reg.reference_point = changes.reg.reference_point;
    p.reg.reference_vector = changes.reg.reference_vector;
    p.samples_cube = changes.samples_cube;
    
    p.sizeOfPixel = p.resolution(1);
    
    p.gridSize = changes.gridSize;
    p.option.cellradius = changes.option.cellradius;
    p.option.shellHeatmapResolution = changes.option.shellHeatmapResolution;
    
    
    p.mappingtype = changes.mappingtype;
    p.rmbg.mCherryDiskSize = changes.rmgb.mCherryDiskSize;
end
end