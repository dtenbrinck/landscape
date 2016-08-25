function data = removeBackground( data )
%REMOVEBACKGROUND Summary of this function goes here
%   Detailed explanation goes here

% TODO: Test best size of structuring element experimentally!

% Generate structural elements for preprocessing
struct_element_dapi = strel('disk',5);
struct_element_gfp = strel('disk',27);
struct_element_mCherry = strel('disk',11);

% preprocess Dapi data
data.Dapi = imtophat(data.Dapi, struct_element_dapi);

% preprocess GFP data
data.GFP = imtophat(data.GFP, struct_element_gfp);

% preprocess mCherry data
data.mCherry = imtophat(data.mCherry, struct_element_mCherry);
end

