function data = removeBackground( data, rmbg_parameter )
%REMOVEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

% TODO: Test best size of structuring element experimentally!

% Generate structural elements for preprocessing
struct_element_dapi = strel('disk',rmbg_parameter.dapiDiskSize);
struct_element_gfp = strel('disk',rmbg_parameter.GFPDiskSize);
struct_element_mCherry = strel('disk',rmbg_parameter.mCherryDiskSize);

% preprocess Dapi data
data.Dapi = imtophat(data.Dapi, struct_element_dapi);

% preprocess GFP data
data.GFP = imtophat(data.GFP, struct_element_gfp);

% preprocess mCherry data
data.mCherry = imtophat(data.mCherry, struct_element_mCherry);
end

