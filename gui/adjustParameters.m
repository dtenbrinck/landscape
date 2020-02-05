function p = adjustParameters(p, changes)

if isequal(changes, 0)
    return
else
    p.resolution = changes.resolution;
    p.mCherryseg.cellSize = changes.mCherryseg.cellSize;
    p.datatype = changes.datatype;
    p.mappingtype = changes.mappingtype;
end
end